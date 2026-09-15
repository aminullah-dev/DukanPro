"""Customers / debt / purchasing API integration tests."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _setup(client: TestClient) -> tuple[dict, str]:
    token = client.post(
        "/auth/bootstrap",
        json={"setup_token": "test-setup-token", "username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    ).json()["tokens"]["access_token"]
    h = {"Authorization": f"Bearer {token}"}
    units = {u["name"]: u["id"] for u in client.get("/units", headers=h).json()}
    pid = client.post(
        "/products", headers=h,
        json={"sku": "P1", "name": "Soap", "unit_id": units["piece"], "sell_price_minor": 52000},
    ).json()["id"]
    client.post("/stock/adjust", headers=h, json={"product_id": pid, "qty_delta": 40})
    return h, pid


def test_credit_sale_posts_ledger_and_payment_reduces_it(client: TestClient) -> None:
    h, pid = _setup(client)
    customer = client.post("/customers", headers=h, json={"name": "Karim", "credit_limit_minor": 200000}).json()

    sale = client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 2}], "payments": [], "customer_id": customer["id"]},
    )
    assert sale.status_code == 200, sale.text

    balance = client.get(f"/customers/{customer['id']}", headers=h).json()["balance_minor"]
    assert balance == 104000  # whole sale on credit

    after = client.post(f"/customers/{customer['id']}/payments", headers=h, json={"amount_minor": 50000}).json()
    assert after["balance_minor"] == 54000


def test_credit_over_limit_rejected(client: TestClient) -> None:
    h, pid = _setup(client)
    customer = client.post("/customers", headers=h, json={"name": "Ali", "credit_limit_minor": 50000}).json()
    r = client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 2}], "payments": [], "customer_id": customer["id"]},
    )
    assert r.status_code == 409 and r.json()["error"]["code"] == "SALE_OVER_CREDIT_LIMIT"


def test_overpayment_rejected(client: TestClient) -> None:
    h, pid = _setup(client)
    customer = client.post("/customers", headers=h, json={"name": "Sara"}).json()
    client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 1}], "payments": [], "customer_id": customer["id"]},
    )  # balance 52000
    r = client.post(f"/customers/{customer['id']}/payments", headers=h, json={"amount_minor": 60000})
    assert r.status_code == 409 and r.json()["error"]["code"] == "DEBT_OVERPAYMENT"


def test_goods_receipt_raises_stock_and_supplier_balance(client: TestClient) -> None:
    h, pid = _setup(client)
    supplier = client.post("/suppliers", headers=h, json={"name": "Wholesaler"}).json()
    receipt = client.post(
        "/goods-receipts", headers=h,
        json={"supplier_id": supplier["id"], "lines": [{"product_id": pid, "qty_minor": 10, "unit_cost_minor": 40000}]},
    )
    assert receipt.status_code == 200, receipt.text
    assert receipt.json()["number"].startswith("GRN-")
    assert receipt.json()["total_cost_minor"] == 400000

    assert client.get(f"/products/{pid}", headers=h).json()["on_hand"] == 50  # 40 + 10
    suppliers = {s["id"]: s for s in client.get("/suppliers", headers=h).json()}
    assert suppliers[supplier["id"]]["balance_minor"] == 400000
