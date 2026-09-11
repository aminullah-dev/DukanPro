"""Reports API integration test."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_dashboard_reflects_today_sales_profit_and_debt(client: TestClient) -> None:
    token = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    ).json()["tokens"]["access_token"]
    h = {"Authorization": f"Bearer {token}"}
    units = {u["name"]: u["id"] for u in client.get("/units", headers=h).json()}
    pid = client.post(
        "/products", headers=h,
        json={"sku": "P1", "name": "Soap", "unit_id": units["piece"], "sell_price_minor": 52000},
    ).json()["id"]
    # Receiving sets stock (+40) and the product's last cost (40000).
    client.post(
        "/goods-receipts", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 40, "unit_cost_minor": 40000}]},
    )
    # Cash sale of 2.
    client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 2}],
              "payments": [{"method": "cash", "amount_minor": 104000, "tendered_minor": 104000}]},
    )
    # Credit sale of 1.
    customer = client.post("/customers", headers=h, json={"name": "Karim", "credit_limit_minor": 200000}).json()
    client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 1}], "payments": [], "customer_id": customer["id"]},
    )

    d = client.get("/reports/dashboard", headers=h)
    assert d.status_code == 200, d.text
    body = d.json()
    assert body["sales_today_minor"] == 156000  # 104000 cash + 52000 credit
    assert body["profit_today_minor"] == (52000 - 40000) * 3
    assert body["outstanding_debt_minor"] == 52000
    assert body["top_sellers"][0]["qty_minor"] == 3


def test_dashboard_requires_report_view(client: TestClient) -> None:
    token = client.post(
        "/auth/bootstrap",
        json={"username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    ).json()["tokens"]["access_token"]
    h = {"Authorization": f"Bearer {token}"}
    client.post(
        "/users", headers=h,
        json={"username": "c1", "password": "pw12345678", "display_name": "C", "role_name": "cashier"},
    )
    cashier = client.post("/auth/login", json={"username": "c1", "password": "pw12345678"}).json()
    ch = {"Authorization": f"Bearer {cashier['tokens']['access_token']}"}
    assert client.get("/reports/dashboard", headers=ch).status_code == 403
