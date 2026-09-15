"""Sales / POS API integration tests."""

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


def test_settle_cash_decrements_stock_and_returns_change(client: TestClient) -> None:
    h, pid = _setup(client)
    r = client.post(
        "/sales", headers=h,
        json={
            "lines": [{"product_id": pid, "qty_minor": 2}],
            "payments": [{"method": "cash", "amount_minor": 104000, "tendered_minor": 110000}],
        },
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["total_minor"] == 104000
    assert body["change_minor"] == 6000
    assert body["number"].startswith("INV-")
    assert body["status"] == "settled"
    assert client.get(f"/products/{pid}", headers=h).json()["on_hand"] == 38


def test_underpaid_cash_rejected(client: TestClient) -> None:
    h, pid = _setup(client)
    r = client.post(
        "/sales", headers=h,
        json={
            "lines": [{"product_id": pid, "qty_minor": 2}],
            "payments": [{"method": "cash", "amount_minor": 100000}],
        },
    )
    assert r.status_code == 409 and r.json()["error"]["code"] == "SALE_UNDERPAID"


def test_void_reverses_stock(client: TestClient) -> None:
    h, pid = _setup(client)
    sale = client.post(
        "/sales", headers=h,
        json={
            "lines": [{"product_id": pid, "qty_minor": 5}],
            "payments": [{"method": "cash", "amount_minor": 260000}],
        },
    ).json()
    assert client.get(f"/products/{pid}", headers=h).json()["on_hand"] == 35
    voided = client.post(f"/sales/{sale['id']}/void", headers=h, json={"reason": "Returned"})
    assert voided.status_code == 200 and voided.json()["status"] == "voided"
    assert client.get(f"/products/{pid}", headers=h).json()["on_hand"] == 40


def test_shift_open_close_variance(client: TestClient) -> None:
    h, pid = _setup(client)
    shift = client.post("/shifts", headers=h, json={"opening_float_minor": 100000}).json()
    client.post(
        "/sales", headers=h,
        json={
            "lines": [{"product_id": pid, "qty_minor": 1}],
            "payments": [{"method": "cash", "amount_minor": 52000}],
            "shift_id": shift["id"],
        },
    )
    closed = client.post(f"/shifts/{shift['id']}/close", headers=h, json={"counted_cash_minor": 152000}).json()
    assert closed["expected_cash_minor"] == 152000  # 100000 float + 52000 cash sale
    assert closed["variance_minor"] == 0
