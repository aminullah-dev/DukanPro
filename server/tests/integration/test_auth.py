"""Auth flow integration tests against a temporary SQLite database."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _bootstrap(client: TestClient) -> dict:
    r = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    )
    assert r.status_code == 200, r.text
    return r.json()


def test_bootstrap_issues_tokens_and_is_idempotent_once(client: TestClient) -> None:
    data = _bootstrap(client)
    assert data["user"]["username"] == "owner"
    assert data["user"]["branches"][0]["role_name"] == "owner"
    assert data["tokens"]["access_token"] and data["tokens"]["refresh_token"]

    again = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner"},
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


def test_refresh_rotation_and_logout_revoke(client: TestClient) -> None:
    data = _bootstrap(client)
    access = data["tokens"]["access_token"]
    refresh = data["tokens"]["refresh_token"]

    rotated = client.post("/auth/refresh", json={"refresh_token": refresh})
    assert rotated.status_code == 200
    new_refresh = rotated.json()["refresh_token"]
    assert new_refresh != refresh

    # The presented refresh token is now revoked (rotation) — reuse fails.
    assert client.post("/auth/refresh", json={"refresh_token": refresh}).status_code == 401

    # Rotation revoked the original session, so its access token is rejected.
    me = client.get("/auth/me", headers={"Authorization": f"Bearer {access}"})
    assert me.status_code == 401
    assert me.json()["error"]["code"] == "SESSION_REVOKED"

    # Logout revokes the rotated session's refresh too.
    assert client.post("/auth/logout", json={"refresh_token": new_refresh}).status_code == 200
    assert client.post("/auth/refresh", json={"refresh_token": new_refresh}).status_code == 401
