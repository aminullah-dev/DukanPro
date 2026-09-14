"""Unit decimals on the server: the built-in units carry fixed ids and reading
them never writes; a kg receipt bills its weight; the dashboard ranks by
revenue, labels quantities with their unit, and counts low stock in whole
units."""

from __future__ import annotations

from fastapi.testclient import TestClient

BUILTIN = {
    "piece": "00000000-0000-7000-8000-000000000001",
    "kg": "00000000-0000-7000-8000-000000000002",
    "litre": "00000000-0000-7000-8000-000000000003",
    "dozen": "00000000-0000-7000-8000-000000000004",
    "meter": "00000000-0000-7000-8000-000000000005",
}


def _owner(client: TestClient) -> dict[str, str]:
    boot = client.post("/auth/bootstrap", json={
        "setup_token": "test-setup-token", "username": "owner", "password": "pw12345678",
        "display_name": "Owner", "shop_name": "Dukan",
    }).json()
    return {"Authorization": f"Bearer {boot['tokens']['access_token']}"}


def test_built_in_units_have_fixed_ids_and_reading_them_writes_nothing(
    client: TestClient,
) -> None:
    h = _owner(client)
    first = client.get("/units", headers=h).json()
    assert {u["name"]: u["id"] for u in first} == BUILTIN
    assert client.get("/units", headers=h).json() == first


def test_a_kg_receipt_bills_its_weight_and_the_dashboard_speaks_in_units(
    client: TestClient,
) -> None:
    h = _owner(client)
    rice = client.post("/products", headers=h, json={
        "sku": "R1", "name": "Rice", "unit_id": BUILTIN["kg"], "sell_price_minor": 8000,
    }).json()["id"]
    soap = client.post("/products", headers=h, json={
        "sku": "S1", "name": "Soap", "unit_id": BUILTIN["piece"], "sell_price_minor": 5000,
    }).json()["id"]
    supplier = client.post("/suppliers", headers=h, json={"name": "Wholesaler"}).json()["id"]
    receipt = client.post("/goods-receipts", headers=h, json={
        "supplier_id": supplier,
        "lines": [{"product_id": rice, "qty_minor": 4000, "unit_cost_minor": 4000}],
    })
    assert receipt.status_code == 200, receipt.text
    assert receipt.json()["total_cost_minor"] == 16000  # 4.000 kg at 40.00 is 160.00
    client.post("/stock/adjust", headers=h, json={"product_id": soap, "qty_delta": 40})
    sale = client.post("/sales", headers=h, json={
        "lines": [{"product_id": rice, "qty_minor": 1500}, {"product_id": soap, "qty_minor": 3}],
        "payments": [{"method": "cash", "amount_minor": 27000}],
    })
    assert sale.status_code == 200, sale.text

    d = client.get("/reports/dashboard", headers=h).json()
    assert [
        (t["name"], t["qty_minor"], t["decimal_places"], t["unit_name"]) for t in d["top_sellers"]
    ] == [("Soap", 3, 0, "piece"), ("Rice", 1500, 3, "kg")]  # by revenue: 150.00, 120.00
    assert d["low_stock_count"] == 1  # 2.500 kg of rice is under 5 kg; 37 soaps are not
