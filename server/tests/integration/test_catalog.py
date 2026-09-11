"""Catalog + inventory API integration tests."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _owner_token(client: TestClient) -> str:
    r = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    )
    assert r.status_code == 200, r.text
    return r.json()["tokens"]["access_token"]


def _units(client: TestClient, token: str) -> dict[str, str]:
    r = client.get("/units", headers={"Authorization": f"Bearer {token}"})
    return {u["name"]: u["id"] for u in r.json()}


def test_create_list_adjust_flow(client: TestClient) -> None:
    token = _owner_token(client)
    h = {"Authorization": f"Bearer {token}"}
    units = _units(client, token)

    created = client.post(
        "/products",
        headers=h,
        json={"sku": "A1", "name": "Rice", "unit_id": units["kg"], "sell_price_minor": 52000, "barcodes": ["5001"]},
    )
    assert created.status_code == 200, created.text
    pid = created.json()["id"]
    assert created.json()["on_hand"] == 0
    assert created.json()["barcodes"] == ["5001"]

    # duplicate sku / barcode
    dup_sku = client.post(
        "/products", headers=h,
        json={"sku": "A1", "name": "x", "unit_id": units["kg"], "sell_price_minor": 1},
    )
    assert dup_sku.status_code == 409 and dup_sku.json()["error"]["code"] == "PRODUCT_DUPLICATE_SKU"
    dup_bc = client.post(
        "/products", headers=h,
        json={"sku": "A2", "name": "Oil", "unit_id": units["piece"], "sell_price_minor": 85000, "barcodes": ["5001"]},
    )
    assert dup_bc.status_code == 409 and dup_bc.json()["error"]["code"] == "BARCODE_DUPLICATE"

    # search
    found = client.get("/products", headers=h, params={"search": "Ric"}).json()
    assert len(found) == 1 and found[0]["sku"] == "A1"

    # adjust stock -> derived on_hand
    a1 = client.post("/stock/adjust", headers=h, json={"product_id": pid, "qty_delta": 40})
    assert a1.status_code == 200 and a1.json()["on_hand"] == 40
    a2 = client.post("/stock/adjust", headers=h, json={"product_id": pid, "qty_delta": -3})
    assert a2.json()["on_hand"] == 37

    # add barcode
    bc = client.post(f"/products/{pid}/barcodes", headers=h, json={"code": "5002"})
    assert bc.status_code == 200 and "5002" in bc.json()["barcodes"]


def test_price_change_updates_and_is_owner_allowed(client: TestClient) -> None:
    token = _owner_token(client)
    h = {"Authorization": f"Bearer {token}"}
    units = _units(client, token)
    pid = client.post(
        "/products", headers=h,
        json={"sku": "P", "name": "Tea", "unit_id": units["piece"], "sell_price_minor": 16000},
    ).json()["id"]
    r = client.patch(f"/products/{pid}", headers=h, json={"sell_price_minor": 18000})
    assert r.status_code == 200 and r.json()["sell_price_minor"] == 18000


def test_cashier_cannot_manage_products(client: TestClient) -> None:
    token = _owner_token(client)
    h = {"Authorization": f"Bearer {token}"}
    units = _units(client, token)
    client.post(
        "/users", headers=h,
        json={"username": "c1", "password": "pw12345678", "display_name": "C", "role_name": "cashier"},
    )
    cashier = client.post("/auth/login", json={"username": "c1", "password": "pw12345678"}).json()
    ch = {"Authorization": f"Bearer {cashier['tokens']['access_token']}"}
    r = client.post(
        "/products", headers=ch,
        json={"sku": "Z", "name": "z", "unit_id": units["piece"], "sell_price_minor": 1},
    )
    assert r.status_code == 403 and r.json()["error"]["code"] == "ACCESS_DENIED"
