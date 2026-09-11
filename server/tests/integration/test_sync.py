"""Sync (push/pull) API integration tests."""

from __future__ import annotations

import uuid

from fastapi.testclient import TestClient


def _uuid() -> str:
    return str(uuid.uuid4())


def _setup(client: TestClient) -> tuple[dict, str, str]:
    boot = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    ).json()
    h = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
    branch = boot["user"]["default_branch_id"]
    unit = {u["name"]: u["id"] for u in client.get("/units", headers=h).json()}["piece"]
    return h, branch, unit


def test_push_applies_rows_and_is_idempotent(client: TestClient) -> None:
    h, branch, unit = _setup(client)
    pid, mid = _uuid(), _uuid()
    ops = [
        {"op_id": _uuid(), "table": "products", "row_id": pid, "op": "insert",
         "data": {"sku": "SYNC1", "name": "Synced", "unit_id": unit, "sell_price_minor": 52000,
                  "sell_currency": "AFN", "track_stock": True, "is_active": True}},
        {"op_id": _uuid(), "table": "stock_movements", "row_id": mid, "op": "insert",
         "data": {"product_id": pid, "branch_id": branch, "qty_delta": 10, "reason": "purchase"}},
    ]
    r = client.post("/sync/push", headers=h, json={"device_id": "dev1", "ops": ops})
    assert r.status_code == 200, r.text
    assert [x["outcome"] for x in r.json()["results"]] == ["applied", "applied"]

    got = client.get(f"/products/{pid}", headers=h).json()
    assert got["name"] == "Synced" and got["on_hand"] == 10

    # Replaying the same ops changes nothing (idempotent).
    r2 = client.post("/sync/push", headers=h, json={"device_id": "dev1", "ops": ops})
    assert [x["outcome"] for x in r2.json()["results"]] == ["applied", "applied"]
    assert len(client.get("/products", headers=h, params={"search": "Synced"}).json()) == 1


def test_master_version_conflict(client: TestClient) -> None:
    h, branch, unit = _setup(client)
    pid = _uuid()
    client.post("/sync/push", headers=h, json={"device_id": "d", "ops": [
        {"op_id": _uuid(), "table": "products", "row_id": pid, "op": "insert",
         "data": {"sku": "M1", "name": "Master", "unit_id": unit, "sell_price_minor": 100, "sell_currency": "AFN"}},
    ]})
    # Update with a stale base_version → conflict.
    conflict = client.post("/sync/push", headers=h, json={"device_id": "d", "ops": [
        {"op_id": _uuid(), "table": "products", "row_id": pid, "op": "update", "base_version": 999,
         "data": {"name": "Changed"}},
    ]})
    result = conflict.json()["results"][0]
    assert result["outcome"] == "conflict"
    assert result["code"] == "PRODUCTS_VERSION_CONFLICT"


def test_pull_returns_changes_since_watermark(client: TestClient) -> None:
    h, branch, unit = _setup(client)
    pid = _uuid()
    client.post("/sync/push", headers=h, json={"device_id": "d", "ops": [
        {"op_id": _uuid(), "table": "products", "row_id": pid, "op": "insert",
         "data": {"sku": "PULL1", "name": "Pullable", "unit_id": unit, "sell_price_minor": 100, "sell_currency": "AFN"}},
    ]})
    pull = client.get("/sync/pull", headers=h, params={"since": 0}).json()
    assert pull["watermark"] >= 1
    tables = {c["table"] for c in pull["changes"]}
    assert "products" in tables
    # Nothing new after the watermark.
    empty = client.get("/sync/pull", headers=h, params={"since": pull["watermark"]}).json()
    assert empty["changes"] == []
