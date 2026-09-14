"""Insights + notifications API integration test (Phase 9)."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _seed(client: TestClient) -> dict:
    token = client.post(
        "/auth/bootstrap",
        json={"setup_token": "test-setup-token", "username": "owner", "password": "pw12345678", "display_name": "Owner", "shop_name": "Dukan"},
    ).json()["tokens"]["access_token"]
    h = {"Authorization": f"Bearer {token}"}
    units = {u["name"]: u["id"] for u in client.get("/units", headers=h).json()}
    piece = units["piece"]

    # Product 1: stocked (+40), sold 35 → low on-hand with sales velocity ⇒ reorder.
    p1 = client.post(
        "/products", headers=h,
        json={"sku": "P1", "name": "Soap", "unit_id": piece, "sell_price_minor": 52000},
    ).json()["id"]
    client.post(
        "/goods-receipts", headers=h,
        json={"lines": [{"product_id": p1, "qty_minor": 40, "unit_cost_minor": 40000}]},
    )
    client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": p1, "qty_minor": 35}],
              "payments": [{"method": "cash", "amount_minor": 1820000, "tendered_minor": 1820000}]},
    )

    # Product 2: stocked (+10), never sold ⇒ dead stock.
    p2 = client.post(
        "/products", headers=h,
        json={"sku": "P2", "name": "Rope", "unit_id": piece, "sell_price_minor": 10000},
    ).json()["id"]
    client.post(
        "/goods-receipts", headers=h,
        json={"lines": [{"product_id": p2, "qty_minor": 10, "unit_cost_minor": 5000}]},
    )

    # Customer at 80% of credit limit ⇒ debt-risk warning.
    customer = client.post(
        "/customers", headers=h, json={"name": "Karim", "credit_limit_minor": 130000}
    ).json()
    client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": p1, "qty_minor": 2}], "payments": [], "customer_id": customer["id"]},
    )
    return h


def test_insights_surface_reorder_dead_stock_and_debt(client: TestClient) -> None:
    h = _seed(client)
    r = client.get("/insights", headers=h)
    assert r.status_code == 200, r.text
    by_code = {i["code"]: i for i in r.json()["insights"]}
    assert "insight.reorder" in by_code
    assert by_code["insight.reorder"]["entity_type"] == "product"
    assert by_code["insight.reorder"]["data"]["suggested_minor"] > 0
    assert "insight.dead_stock" in by_code
    assert by_code["insight.debt_risk"]["severity"] == "warning"
    assert "insight.digest" in by_code


def test_notifications_refresh_is_idempotent_and_markable(client: TestClient) -> None:
    h = _seed(client)
    first = client.post("/notifications/refresh", headers=h)
    assert first.status_code == 200
    created = first.json()["created"]
    assert created == 3  # reorder + dead_stock + debt_risk (digest is live-only)

    # Re-running the same day creates nothing new.
    assert client.post("/notifications/refresh", headers=h).json()["created"] == 0

    feed = client.get("/notifications", headers=h).json()["notifications"]
    assert len(feed) == 3
    assert all(n["read"] is False for n in feed)

    marked = client.patch(f"/notifications/{feed[0]['id']}/read", headers=h)
    assert marked.status_code == 200
    unread = client.get("/notifications?unread_only=true", headers=h).json()["notifications"]
    assert len(unread) == 2


def test_insights_require_report_view(client: TestClient) -> None:
    oh = _seed(client)  # owner headers
    client.post(
        "/users", headers=oh,
        json={"username": "c1", "password": "pw12345678", "display_name": "C", "role_name": "cashier"},
    )
    cashier = client.post("/auth/login", json={"username": "c1", "password": "pw12345678"}).json()
    ch = {"Authorization": f"Bearer {cashier['tokens']['access_token']}"}
    assert client.get("/insights", headers=ch).status_code == 403
    assert client.post("/notifications/refresh", headers=ch).status_code == 403
