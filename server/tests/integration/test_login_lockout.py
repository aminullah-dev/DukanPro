"""Too many wrong passwords close online sign-in to an account for 15 minutes,
even to the right password; a good sign-in starts the count again, and an
unknown username locks nothing (docs/domain/identity-access.md)."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

from fastapi.testclient import TestClient
from httpx import Response
from sqlalchemy import update
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import AuditEntryModel

PW = "pw12345678"


def _boot(client: TestClient) -> None:
    r = client.post("/auth/bootstrap", json={
        "setup_token": "test-setup-token", "username": "owner", "password": PW,
        "display_name": "Owner", "shop_name": "Dukan",
    })
    assert r.status_code == 200, r.text


def _login(client: TestClient, password: str, username: str = "owner") -> Response:
    return client.post("/auth/login", json={"username": username, "password": password})


def _age_failures(client: TestClient, minutes: int) -> None:
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        s.execute(
            update(AuditEntryModel)
            .where(AuditEntryModel.action == "user.login_failed")
            .values(occurred_at=datetime.now(UTC) - timedelta(minutes=minutes))
        )
        s.commit()


def test_five_wrong_passwords_close_sign_in_for_fifteen_minutes(client: TestClient) -> None:
    _boot(client)
    for _ in range(5):
        assert _login(client, "wrong-password").status_code == 401
    r = _login(client, PW)
    error = r.json()["error"]
    assert (r.status_code, error["code"]) == (429, "LOGIN_LOCKED")
    assert error["context"]["retry_after_minutes"] == 15
    _age_failures(client, minutes=16)
    assert _login(client, PW).status_code == 200


def test_a_good_sign_in_starts_the_count_again(client: TestClient) -> None:
    _boot(client)
    for _ in range(4):
        _login(client, "wrong-password")
    assert _login(client, PW).status_code == 200
    for _ in range(4):
        _login(client, "wrong-password")
    assert _login(client, PW).status_code == 200


def test_an_unknown_username_locks_nothing(client: TestClient) -> None:
    _boot(client)
    for _ in range(6):
        r = _login(client, "whatever-it-is", username="ghost")
        assert (r.status_code, r.json()["error"]["code"]) == (401, "INVALID_CREDENTIALS")
    assert _login(client, PW).status_code == 200
