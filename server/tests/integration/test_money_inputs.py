"""Money and quantity inputs over REST: quantities are positive, payments are
real tenders that never exceed the total, debt payments and receipt lines are
positive, bills are in the supplier's currency, and prices are zero or more in
a shop currency."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient
from httpx import Response
from sqlalchemy import select
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import AuditEntryModel

PW = "pw12345678"


def _code(r: Response) -> tuple[int, str]:
    return r.status_code, r.json()["error"]["code"]


class Shop:
    def __init__(self, client: TestClient) -> None:
        self.c = client
        boot = client.post("/auth/bootstrap", json={
            "setup_token": "test-setup-token", "username": "owner", "password": PW,
            "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.h = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
        self.units = {u["name"]: u["id"] for u in client.get("/units", headers=self.h).json()}
        self.pid: str = client.post("/products", headers=self.h, json={
            "sku": "P1", "name": "Soap", "unit_id": self.units["piece"], "sell_price_minor": 52000,
        }).json()["id"]
        client.post("/stock/adjust", headers=self.h, json={"product_id": self.pid, "qty_delta": 40})

    def sell(self, qty: int, *payments: dict[str, Any]) -> Response:
        return self.c.post("/sales", headers=self.h, json={
            "lines": [{"product_id": self.pid, "qty_minor": qty}], "payments": list(payments),
        })

    def receive(self, qty: int, cost: int, supplier: str | None = None) -> Response:
        return self.c.post("/goods-receipts", headers=self.h, json={
            "supplier_id": supplier,
            "lines": [{"product_id": self.pid, "qty_minor": qty, "unit_cost_minor": cost}],
        })

    def on_hand(self) -> int:
        return int(self.c.get(f"/products/{self.pid}", headers=self.h).json()["on_hand"])


def test_a_sale_sells_positive_quantities_for_real_payments(client: TestClient) -> None:
    shop = Shop(client)
    attempts = [
        shop.sell(-5, {"method": "cash", "amount_minor": 1}),
        shop.sell(0, {"method": "cash", "amount_minor": 1}),
        shop.sell(1, {"method": "cash", "amount_minor": -1000},
                  {"method": "cash", "amount_minor": 53000}),
        shop.sell(1, {"method": "credit", "amount_minor": 52000}),
        shop.sell(1, {"method": "bogus", "amount_minor": 52000}),
        shop.sell(1, {"method": "cash", "amount_minor": 52000, "tendered_minor": 50000}),
        shop.sell(1, {"method": "card", "amount_minor": 52000, "tendered_minor": 60000}),
        shop.sell(1, {"method": "cash", "amount_minor": 60000}),
    ]
    assert [_code(r) for r in attempts] == [
        (422, "SALE_LINE_INVALID_QTY"), (422, "SALE_LINE_INVALID_QTY"),
        (422, "SALE_PAYMENT_INVALID"), (422, "SALE_PAYMENT_INVALID"),
        (422, "SALE_PAYMENT_INVALID"), (422, "SALE_PAYMENT_INVALID"),
        (422, "SALE_PAYMENT_INVALID"), (409, "SALE_OVERPAID"),
    ]
    assert shop.on_hand() == 40


def test_change_is_cash_handed_back(client: TestClient) -> None:
    shop = Shop(client)
    cash = shop.sell(1, {"method": "cash", "amount_minor": 52000, "tendered_minor": 60000})
    assert cash.status_code == 200 and cash.json()["change_minor"] == 8000
    card = shop.sell(1, {"method": "card", "amount_minor": 52000})
    assert card.status_code == 200 and card.json()["change_minor"] == 0


def test_a_debt_payment_is_a_positive_amount(client: TestClient) -> None:
    shop = Shop(client)
    customer = client.post("/customers", headers=shop.h, json={
        "name": "Karim", "credit_limit_minor": 100000,
    }).json()
    url = f"/customers/{customer['id']}/payments"
    attempts = [client.post(url, headers=shop.h, json={"amount_minor": a}) for a in (-500000, 0)]
    assert [_code(r) for r in attempts] == [(422, "DEBT_PAYMENT_INVALID")] * 2
    assert client.get(f"/customers/{customer['id']}", headers=shop.h).json()["balance_minor"] == 0


def test_a_receipt_line_is_a_positive_quantity_at_a_cost_of_zero_or_more(
    client: TestClient,
) -> None:
    shop = Shop(client)
    attempts = [shop.receive(-5000, 6000), shop.receive(0, 6000), shop.receive(5, -1)]
    assert [_code(r) for r in attempts] == [(422, "GRN_LINE_INVALID")] * 3
    assert shop.on_hand() == 40


def test_a_bill_is_in_the_suppliers_currency_and_cost_changes_are_audited(
    client: TestClient,
) -> None:
    shop = Shop(client)
    usd = str(uuid.uuid4())  # a supplier the app created offline, trading in dollars
    push = client.post("/sync/push", headers=shop.h, json={"device_id": "d1", "ops": [{
        "op_id": str(uuid.uuid4()), "table": "suppliers", "row_id": usd, "op": "insert",
        "data": {"name": "Dubai Trading", "currency": "USD"},
    }]})
    assert push.json()["results"][0]["outcome"] == "applied"
    assert _code(shop.receive(10, 6000, usd)) == (409, "PURCHASE_CURRENCY_MISMATCH")

    afn = client.post("/suppliers", headers=shop.h, json={"name": "Kabul Wholesale"}).json()["id"]
    assert shop.receive(10, 6000, afn).status_code == 200
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        changed = s.scalars(
            select(AuditEntryModel).where(AuditEntryModel.action == "cost.valuation_changed")
        ).all()
    assert [(e.before, (e.after or {}).get("cost_minor")) for e in changed] == [
        ({"cost_minor": None}, 6000)
    ]


def test_prices_are_zero_or_more_in_a_shop_currency(client: TestClient) -> None:
    shop = Shop(client)

    def create(**over: Any) -> Response:
        return client.post("/products", headers=shop.h, json={
            "sku": uuid.uuid4().hex[:8], "name": "Tea", "unit_id": shop.units["piece"],
            "sell_price_minor": 1000, **over,
        })

    attempts = [
        create(sell_price_minor=-1000),
        create(currency="XYZ"),
        create(category_id=str(uuid.uuid4())),
        client.patch(f"/products/{shop.pid}", headers=shop.h, json={"sell_price_minor": -1}),
    ]
    assert [_code(r) for r in attempts] == [
        (422, "CATALOG_PRICE_INVALID"), (422, "PRICE_CURRENCY_INVALID"),
        (404, "CATEGORY_NOT_FOUND"), (422, "CATALOG_PRICE_INVALID"),
    ]
    assert create(sell_price_minor=0).status_code == 200  # a free item is fine
