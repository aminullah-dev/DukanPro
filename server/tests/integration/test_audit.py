"""Audit trail + security hardening integration tests (Phase 10)."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _owner(client: TestClient) -> dict:
    token = client.post(
        "/auth/bootstrap",
        json={"setup_token": "test-setup-token", "username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    ).json()["tokens"]["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_audit_lists_and_filters_actions(client: TestClient) -> None:
    h = _owner(client)
    client.post(
        "/users", headers=h,
        json={"username": "c1", "password": "pw12345678", "display_name": "C", "role_name": "cashier"},
    )
    # A failed login is recorded for security visibility.
    client.post("/auth/login", json={"username": "owner", "password": "wrong-password"})

    entries = client.get("/audit", headers=h)
    assert entries.status_code == 200, entries.text
    actions = {e["action"] for e in entries.json()["entries"]}
    assert {"owner.bootstrapped", "user.created", "user.login_failed"} <= actions

    only_failed = client.get("/audit?action=user.login_failed", headers=h).json()["entries"]
    assert only_failed and all(e["action"] == "user.login_failed" for e in only_failed)


def test_audit_export_returns_csv(client: TestClient) -> None:
    h = _owner(client)
    r = client.get("/audit/export", headers=h)
    assert r.status_code == 200
    assert r.headers["content-type"].startswith("text/csv")
    lines = r.text.strip().splitlines()
    assert lines[0] == "occurred_at,actor_id,action,entity_type,entity_id"
    assert any("owner.bootstrapped" in ln for ln in lines[1:])


def test_audit_requires_audit_view(client: TestClient) -> None:
    h = _owner(client)
    client.post(
        "/users", headers=h,
        json={"username": "m1", "password": "pw12345678", "display_name": "M", "role_name": "manager"},
    )
    mgr = client.post("/auth/login", json={"username": "m1", "password": "pw12345678"}).json()
    mh = {"Authorization": f"Bearer {mgr['tokens']['access_token']}"}
    # A manager has report.view but not audit.view.
    assert client.get("/audit", headers=mh).status_code == 403
    assert client.get("/audit/export", headers=mh).status_code == 403


def test_weak_password_is_rejected(client: TestClient) -> None:
    r = client.post(
        "/auth/bootstrap",
        json={"setup_token": "test-setup-token", "username": "owner", "password": "short", "display_name": "Owner", "shop_name": "Dukan"},
    )
    assert r.status_code == 422
    assert r.json()["error"]["code"] == "WEAK_PASSWORD"


def test_weak_employee_password_is_rejected(client: TestClient) -> None:
    h = _owner(client)
    r = client.post(
        "/users", headers=h,
        json={"username": "c1", "password": "123", "display_name": "C", "role_name": "cashier"},
    )
    assert r.status_code == 422
    assert r.json()["error"]["code"] == "WEAK_PASSWORD"


def test_security_headers_present(client: TestClient) -> None:
    r = client.get("/health")
    assert r.headers["x-content-type-options"] == "nosniff"
    assert r.headers["x-frame-options"] == "DENY"
    assert r.headers["referrer-policy"] == "no-referrer"
