"""Auth flow integration tests against a temporary SQLite database."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from pydantic import ValidationError as SettingsError
from sqlalchemy import update
from sqlalchemy.orm import Session

from dukan.config import Settings
from dukan.infrastructure.auth_service import REFRESH_RETRY_GRACE
from dukan.infrastructure.db.models import SessionModel


def _bootstrap(client: TestClient) -> dict:
    r = client.post(
        "/auth/bootstrap",
        json={"setup_token": "test-setup-token", "username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    )
    assert r.status_code == 200, r.text
    return r.json()


def _age_sessions(client: TestClient, by: timedelta) -> None:
    """As if every session's last refresh happened `by` ago."""
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        s.execute(update(SessionModel).values(updated_at=datetime.now(UTC) - by))
        s.commit()


def test_bootstrap_issues_tokens_and_is_idempotent_once(client: TestClient) -> None:
    data = _bootstrap(client)
    assert data["user"]["username"] == "owner"
    assert data["user"]["branches"][0]["role_name"] == "owner"
    assert data["tokens"]["access_token"] and data["tokens"]["refresh_token"]

    again = client.post(
        "/auth/bootstrap",
        json={"setup_token": "test-setup-token", "username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    )
    assert again.status_code == 409
    assert again.json()["error"]["code"] == "BOOTSTRAP_ALREADY_DONE"


def test_me_and_bad_password(client: TestClient) -> None:
    data = _bootstrap(client)
    access = data["tokens"]["access_token"]

    me = client.get("/auth/me", headers={"Authorization": f"Bearer {access}"})
    assert me.status_code == 200
    assert me.json()["username"] == "owner"

    assert client.get("/auth/me").status_code == 401  # no token

    bad = client.post("/auth/login", json={"username": "owner", "password": "nope"})
    assert bad.status_code == 401
    assert bad.json()["error"]["code"] == "INVALID_CREDENTIALS"


def test_permission_denied_for_cashier(client: TestClient) -> None:
    owner_access = _bootstrap(client)["tokens"]["access_token"]
    created = client.post(
        "/users",
        headers={"Authorization": f"Bearer {owner_access}"},
        json={"username": "cashier1", "password": "pw12345678", "display_name": "Cashier", "role_name": "cashier"},
    )
    assert created.status_code == 200

    cashier_access = client.post(
        "/auth/login", json={"username": "cashier1", "password": "pw12345678"}
    ).json()["tokens"]["access_token"]

    denied = client.post(
        "/users",
        headers={"Authorization": f"Bearer {cashier_access}"},
        json={"username": "x", "password": "pw12345678", "display_name": "X", "role_name": "cashier"},
    )
    assert denied.status_code == 403
    assert denied.json()["error"]["code"] == "ACCESS_DENIED"


def test_refresh_rotates_in_place_and_reuse_revokes_the_session(client: TestClient) -> None:
    data = _bootstrap(client)
    access = {"Authorization": f"Bearer {data['tokens']['access_token']}"}
    refresh = data["tokens"]["refresh_token"]

    rotated = client.post("/auth/refresh", json={"refresh_token": refresh})
    assert rotated.status_code == 200
    new_refresh = rotated.json()["refresh_token"]
    assert new_refresh != refresh
    # Same session: the access token issued before the refresh still works.
    assert client.get("/auth/me", headers=access).status_code == 200

    # Past the retry grace, the rotated-out token coming back means it was copied:
    # the session is revoked, so neither the thief nor the device keeps it.
    _age_sessions(client, REFRESH_RETRY_GRACE + timedelta(seconds=1))
    assert client.post("/auth/refresh", json={"refresh_token": refresh}).status_code == 401
    me = client.get("/auth/me", headers=access)
    assert me.status_code == 401 and me.json()["error"]["code"] == "SESSION_REVOKED"
    assert client.post("/auth/refresh", json={"refresh_token": new_refresh}).status_code == 401


def test_a_lost_refresh_answer_can_be_retried(client: TestClient) -> None:
    data = _bootstrap(client)
    access = {"Authorization": f"Bearer {data['tokens']['access_token']}"}
    refresh = data["tokens"]["refresh_token"]
    lost = client.post("/auth/refresh", json={"refresh_token": refresh})
    assert lost.status_code == 200  # ...but the answer never reaches the device

    retry = client.post("/auth/refresh", json={"refresh_token": refresh})
    assert retry.status_code == 200
    assert client.get("/auth/me", headers=access).status_code == 200
    # The lost answer's token is now the rotated-out one: showing up later, it was copied.
    _age_sessions(client, REFRESH_RETRY_GRACE + timedelta(seconds=1))
    stolen = client.post("/auth/refresh", json={"refresh_token": lost.json()["refresh_token"]})
    assert stolen.status_code == 401
    assert client.get("/auth/me", headers=access).json()["error"]["code"] == "SESSION_REVOKED"


def test_logout_revokes_the_session(client: TestClient) -> None:
    refresh = _bootstrap(client)["tokens"]["refresh_token"]
    assert client.post("/auth/logout", json={"refresh_token": refresh}).status_code == 200
    assert client.post("/auth/refresh", json={"refresh_token": refresh}).status_code == 401


def test_bootstrap_needs_the_servers_setup_code(client: TestClient) -> None:
    body = {"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"}
    assert client.post("/auth/bootstrap", json=body).status_code == 422
    wrong = client.post("/auth/bootstrap", json={**body, "setup_token": "not-the-code-000"})
    assert wrong.status_code == 401 and wrong.json()["error"]["code"] == "SETUP_TOKEN_INVALID"
    right = client.post("/auth/bootstrap", json={**body, "setup_token": "test-setup-token"})
    assert right.status_code == 200


def test_access_tokens_must_be_complete_and_match_their_session(client: TestClient) -> None:
    owner = _bootstrap(client)
    created = client.post(
        "/users",
        headers={"Authorization": f"Bearer {owner['tokens']['access_token']}"},
        json={"username": "c1", "password": "pw12345678", "display_name": "C", "role_name": "cashier"},
    )
    assert created.status_code == 200, created.text
    token = client.post(
        "/auth/login", json={"username": "c1", "password": "pw12345678"}
    ).json()["tokens"]["access_token"]
    claims = jwt.decode(token, options={"verify_signature": False})
    secret = client.app.state.settings.secret_key
    without_exp = jwt.encode({k: v for k, v in claims.items() if k != "exp"}, secret, "HS256")
    # The cashier's session, relabelled as the owner: the key alone must not do it.
    relabelled = jwt.encode({**claims, "sub": owner["user"]["id"]}, secret, "HS256")
    for forged in (without_exp, relabelled):
        r = client.get("/auth/me", headers={"Authorization": f"Bearer {forged}"})
        assert r.status_code == 401 and r.json()["error"]["code"] == "TOKEN_INVALID"


@pytest.mark.parametrize(
    "weak",
    ["short", "a" * 40, "abcabcabcabcabcabcabcabcabcabcabc", "change-me-to-a-long-random-string"],
)
def test_the_secret_key_must_be_strong(weak: str) -> None:
    with pytest.raises(SettingsError):
        Settings(secret_key=weak, database_url="sqlite://")
