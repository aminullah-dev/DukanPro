"""Employee & branch administration integration tests (Phase 7)."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _bootstrap(client: TestClient) -> str:
    r = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    )
    assert r.status_code == 200, r.text
    return r.json()["tokens"]["access_token"]


def _h(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _create_cashier(client: TestClient, owner: str, username: str = "cashier1") -> dict:
    r = client.post(
        "/users",
        headers=_h(owner),
        json={"username": username, "password": "pw12345678", "display_name": "Cashier", "role_name": "cashier"},
    )
    assert r.status_code == 200, r.text
    return r.json()


def test_owner_lists_and_creates_employee(client: TestClient) -> None:
    owner = _bootstrap(client)
    listed = client.get("/users", headers=_h(owner))
    assert listed.status_code == 200
    assert len(listed.json()["users"]) == 1  # the owner

    _create_cashier(client, owner)
    assert len(client.get("/users", headers=_h(owner)).json()["users"]) == 2


def test_duplicate_username_conflict(client: TestClient) -> None:
    owner = _bootstrap(client)
    _create_cashier(client, owner)
    dup = client.post(
        "/users",
        headers=_h(owner),
        json={"username": "cashier1", "password": "pw12345678", "display_name": "X", "role_name": "cashier"},
    )
    assert dup.status_code == 409
    assert dup.json()["error"]["code"] == "USER_DUPLICATE_USERNAME"


def test_cashier_cannot_list_or_manage(client: TestClient) -> None:
    owner = _bootstrap(client)
    _create_cashier(client, owner)
    cashier = client.post(
        "/auth/login", json={"username": "cashier1", "password": "pw12345678"}
    ).json()["tokens"]["access_token"]

    assert client.get("/users", headers=_h(cashier)).status_code == 403
    assert client.get("/branches", headers=_h(cashier)).status_code == 403


def test_disable_last_owner_blocked(client: TestClient) -> None:
    owner = _bootstrap(client)
    me = client.get("/auth/me", headers=_h(owner)).json()
    blocked = client.patch(f"/users/{me['id']}/status", headers=_h(owner), json={"active": False})
    assert blocked.status_code == 409
    assert blocked.json()["error"]["code"] == "USER_LAST_OWNER"


def test_disable_employee_revokes_their_sessions(client: TestClient) -> None:
    owner = _bootstrap(client)
    cashier = _create_cashier(client, owner)
    login = client.post("/auth/login", json={"username": "cashier1", "password": "pw12345678"}).json()
    access, refresh = login["tokens"]["access_token"], login["tokens"]["refresh_token"]
    assert client.get("/auth/me", headers=_h(access)).status_code == 200

    disabled = client.patch(f"/users/{cashier['id']}/status", headers=_h(owner), json={"active": False})
    assert disabled.status_code == 200
    assert disabled.json()["status"] == "disabled"

    # The cashier's live session is gone, and they cannot log back in.
    assert client.get("/auth/me", headers=_h(access)).status_code == 401
    assert client.post("/auth/refresh", json={"refresh_token": refresh}).status_code == 401
    relogin = client.post("/auth/login", json={"username": "cashier1", "password": "pw12345678"})
    assert relogin.status_code == 401
    assert relogin.json()["error"]["code"] == "USER_DISABLED"


def test_reset_password_invalidates_old_and_revokes_sessions(client: TestClient) -> None:
    owner = _bootstrap(client)
    cashier = _create_cashier(client, owner)
    access = client.post(
        "/auth/login", json={"username": "cashier1", "password": "pw12345678"}
    ).json()["tokens"]["access_token"]

    reset = client.post(
        f"/users/{cashier['id']}/password", headers=_h(owner), json={"new_password": "newpw987654"}
    )
    assert reset.status_code == 200
    # Old session revoked; old password rejected; new password works.
    assert client.get("/auth/me", headers=_h(access)).status_code == 401
    assert client.post("/auth/login", json={"username": "cashier1", "password": "pw12345678"}).status_code == 401
    ok = client.post("/auth/login", json={"username": "cashier1", "password": "newpw987654"})
    assert ok.status_code == 200


def test_branch_create_rename_and_last_active_guard(client: TestClient) -> None:
    owner = _bootstrap(client)
    branches = client.get("/branches", headers=_h(owner)).json()["branches"]
    assert len(branches) == 1
    original_id = branches[0]["id"]

    created = client.post("/branches", headers=_h(owner), json={"name": "Second"})
    assert created.status_code == 200
    b2 = created.json()["id"]

    renamed = client.patch(f"/branches/{b2}", headers=_h(owner), json={"name": "North Store"})
    assert renamed.status_code == 200
    assert renamed.json()["name"] == "North Store"

    # Two active branches → deactivating one is allowed.
    off = client.patch(f"/branches/{b2}", headers=_h(owner), json={"active": False})
    assert off.status_code == 200
    assert off.json()["is_active"] is False

    # Now only one active branch remains → deactivating it is blocked.
    blocked = client.patch(f"/branches/{original_id}", headers=_h(owner), json={"active": False})
    assert blocked.status_code == 409
    assert blocked.json()["error"]["code"] == "BRANCH_LAST_ACTIVE"


def test_assign_and_revoke_role(client: TestClient) -> None:
    owner = _bootstrap(client)
    cashier = _create_cashier(client, owner)
    b2 = client.post("/branches", headers=_h(owner), json={"name": "Second"}).json()["id"]

    assigned = client.post(
        f"/users/{cashier['id']}/roles", headers=_h(owner),
        json={"branch_id": b2, "role_name": "manager"},
    )
    assert assigned.status_code == 200
    assert len(assigned.json()["branches"]) == 2

    revoked = client.delete(f"/users/{cashier['id']}/roles/{b2}", headers=_h(owner))
    assert revoked.status_code == 200
    assert len(revoked.json()["branches"]) == 1
