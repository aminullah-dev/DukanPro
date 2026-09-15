"""A till voids a sale and takes goods back offline: the rows reach the server as
one device transaction and are checked there (docs/domain/sales.md). Stock comes
back only as far as the sale took it, a return never takes back more than was
sold, and a sale with returns is past voiding."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient
from httpx import Response
from sqlalchemy import select
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import AuditEntryModel

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"
ABORTED = "SYNC_TX_ABORTED"


def _uuid() -> str:
    return str(uuid.uuid4())


def _op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, tx: str | None = None,
    kind: str = "insert", base_version: int | None = None,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": kind, "data": data,
    }
    if tx is not None:
        body["tx_id"] = tx
    if base_version is not None:
        body["base_version"] = base_version
    return body


def _audit_after(client: TestClient, entity_id: str, action: str) -> dict[str, Any]:
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        after = s.scalars(
            select(AuditEntryModel.after)
            .where(AuditEntryModel.entity_id == entity_id, AuditEntryModel.action == action)
            .order_by(AuditEntryModel.occurred_at.desc())
        ).first()
    assert after is not None, f"no {action} audit entry for {entity_id}"
    return dict(after)


class Shop:
    def __init__(self, client: TestClient) -> None:
        boot = client.post("/auth/bootstrap", json={
            "setup_token": "test-setup-token", "username": "owner", "password": PW,
            "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.client = client
        self.owner = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
        self.branch: str = boot["user"]["default_branch_id"]

    def product(self, *, stock: int = 0) -> str:
        r = self.client.post("/products", headers=self.owner, json={
            "sku": "S" + _uuid()[:8], "name": "Soap", "unit_id": PIECE,
            "sell_price_minor": 5000, "track_stock": True,
        })
        assert r.status_code == 200, r.text
        pid: str = r.json()["id"]
        if stock:
            r = self.client.post(
                "/stock/adjust", headers=self.owner, json={"product_id": pid, "qty_delta": stock}
            )
            assert r.status_code == 200, r.text
        return pid

    def customer(self) -> str:
        r = self.client.post("/customers", headers=self.owner, json={"name": "Karim"})
        return str(r.json()["id"])

    def shift(self) -> str:
        r = self.client.post("/shifts", headers=self.owner, json={"opening_float_minor": 0})
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def sell(
        self, pid: str, qty: int, *, cash: int = 0, customer: str | None = None,
        shift: str | None = None,
    ) -> str:
        r = self.client.post("/sales", headers=self.owner, json={
            "lines": [{"product_id": pid, "qty_minor": qty}],
            "payments": [{"method": "cash", "amount_minor": cash}] if cash else [],
            "customer_id": customer, "shift_id": shift,
        })
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def push(self, *ops: dict[str, Any]) -> list[tuple[str, Any]]:
        r = self.client.post(
            "/sync/push", headers=self.owner, json={"device_id": "dev-1", "ops": list(ops)}
        )
        assert r.status_code == 200, r.text
        return [(x["outcome"], x.get("code")) for x in r.json()["results"]]

    def status(self, sale: str) -> str:
        return str(self.client.get(f"/sales/{sale}", headers=self.owner).json()["status"])

    def on_hand(self, pid: str) -> int:
        return int(self.client.get(f"/products/{pid}", headers=self.owner).json()["on_hand"])

    def balance(self, customer: str) -> int:
        return int(self.client.get(f"/customers/{customer}", headers=self.owner).json()["balance_minor"])

    def close(self, shift: str, counted: int) -> Response:
        return self.client.post(
            f"/shifts/{shift}/close", headers=self.owner, json={"counted_cash_minor": counted}
        )


def _void(shop: Shop, sale: str, pid: str, qty: int, *, reason: str = "rang up twice",
          debt: tuple[str, int] | None = None) -> list[dict[str, Any]]:
    """A void as a till records it: the sale, the stock it took, the debt it put on."""
    tx = _uuid()
    ops = [
        _op("sales", {"status": "voided", "void_reason": reason}, row_id=sale, tx=tx,
            kind="update", base_version=0),
        _op("stock_movements", {
            "product_id": pid, "branch_id": shop.branch, "qty_delta": qty, "reason": "returned",
            "ref_type": "void", "ref_id": sale,
        }, tx=tx),
    ]
    if debt is not None:
        customer, amount = debt
        ops.append(_op("customer_ledger", {
            "customer_id": customer, "type": "adjustment", "amount_minor": -amount,
            "currency": "AFN", "ref_type": "void", "ref_id": sale,
        }, tx=tx))
    return ops


def _return(shop: Shop, sale: str, pid: str, qty: int, *, worth: int, shift: str | None,
            number: str, reason: str = "torn wrapper") -> tuple[str, list[dict[str, Any]]]:
    """A return as a till records it: a negative sale, its line, the stock back, the cash out."""
    tx, refund = _uuid(), _uuid()
    ops = [
        _op("sales", {
            "number": number, "branch_id": shop.branch, "shift_id": shift, "customer_id": None,
            "status": "settled", "currency": "AFN", "discount_minor": 0,
            "subtotal_minor": -worth, "tax_minor": 0, "total_minor": -worth,
            "paid_minor": -worth, "change_minor": 0, "refund_of": sale, "refund_reason": reason,
        }, row_id=refund, tx=tx),
        _op("sale_lines", {
            "sale_id": refund, "product_id": pid, "name": "Soap", "qty_minor": -qty,
            "decimal_places": 0, "unit_price_minor": 5000, "unit_cost_minor": 0,
            "line_total_minor": -worth, "currency": "AFN",
        }, tx=tx),
        _op("stock_movements", {
            "product_id": pid, "branch_id": shop.branch, "qty_delta": qty, "reason": "returned",
            "ref_type": "refund", "ref_id": refund,
        }, tx=tx),
        _op("payments", {
            "sale_id": refund, "method": "cash", "amount_minor": -worth, "currency": "AFN",
            "tendered_minor": None, "change_minor": None,
        }, tx=tx),
    ]
    return refund, ops


def test_a_void_recorded_offline_applies_whole(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 3, cash=15000)
    assert shop.on_hand(pid) == 7
    assert shop.push(*_void(shop, sale, pid, 3)) == [("applied", None)] * 2
    assert shop.status(sale) == "voided"
    assert shop.on_hand(pid) == 10
    assert _audit_after(client, sale, "sale.voided")["reason"] == "rang up twice"


def test_a_void_takes_the_customers_debt_back(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    sale = shop.sell(pid, 2, customer=customer)
    assert shop.balance(customer) == 10000
    assert shop.push(*_void(shop, sale, pid, 2, debt=(customer, 10000))) == [("applied", None)] * 3
    assert (shop.status(sale), shop.balance(customer)) == ("voided", 0)


def test_a_void_that_returns_more_than_the_sale_took_applies_nothing(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, cash=10000)
    result = shop.push(*_void(shop, sale, pid, 3))
    assert result[1] == ("rejected", "SYNC_REF_MISMATCH")
    assert result[0] == ("rejected", ABORTED)
    assert (shop.status(sale), shop.on_hand(pid)) == ("settled", 8)


def test_a_second_tills_void_of_the_same_sale_returns_no_stock_twice(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, cash=10000)
    assert shop.push(*_void(shop, sale, pid, 2)) == [("applied", None)] * 2
    again = shop.push(*_void(shop, sale, pid, 2))  # another till voided it offline too
    assert again[1] == ("rejected", "SYNC_REF_MISMATCH")
    assert again[0] == ("rejected", ABORTED)
    assert shop.on_hand(pid) == 10


def test_a_return_recorded_offline_applies_whole_and_leaves_the_drawer_right(
    client: TestClient,
) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    shift = shop.shift()
    sale = shop.sell(pid, 3, cash=15000, shift=shift)
    refund, ops = _return(shop, sale, pid, 1, worth=5000, shift=shift, number="INV-D1-R1")
    assert shop.push(*ops) == [("applied", None)] * 4
    assert shop.on_hand(pid) == 8
    body = client.get(f"/sales/{refund}", headers=shop.owner).json()
    assert (body["refund_of"], body["total_minor"]) == (sale, -5000)
    assert shop.close(shift, 10000).json()["expected_cash_minor"] == 10000
    assert _audit_after(client, refund, "sale.refunded")["reason"] == "torn wrapper"


def test_returns_never_take_back_more_than_was_sold(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, cash=10000)
    _, first = _return(shop, sale, pid, 2, worth=10000, shift=None, number="INV-D1-R2")
    first[3]["data"]["method"] = "transfer"  # no drawer on this till
    assert shop.push(*first) == [("applied", None)] * 4
    refund, second = _return(shop, sale, pid, 1, worth=5000, shift=None, number="INV-D1-R3")
    second[3]["data"]["method"] = "transfer"
    result = shop.push(*second)
    # Nothing of the sale is left to give back, so the return is refused at its
    # header and the rest of its rows go with it.
    assert result[0] == ("rejected", "SYNC_REF_MISMATCH")
    assert result[1:] == [("rejected", ABORTED)] * 3
    assert client.get(f"/sales/{refund}", headers=shop.owner).status_code == 404
    assert shop.on_hand(pid) == 10


def test_a_return_never_takes_back_more_of_a_product_than_the_sale_sold(
    client: TestClient,
) -> None:
    shop = Shop(client)
    soap, rice = shop.product(stock=10), shop.product(stock=10)
    r = client.post("/sales", headers=shop.owner, json={
        "lines": [{"product_id": soap, "qty_minor": 1}, {"product_id": rice, "qty_minor": 1}],
        "payments": [{"method": "cash", "amount_minor": 10000}],
    })
    assert r.status_code == 200, r.text
    sale = str(r.json()["id"])
    # Two of the soap, when the sale sold one: worth no more than the sale, but
    # more of that product than it has to give.
    tx, refund = _uuid(), _uuid()
    ops = [
        _op("sales", {
            "number": "INV-D1-R5", "branch_id": shop.branch, "shift_id": None,
            "customer_id": None, "status": "settled", "currency": "AFN", "discount_minor": 0,
            "subtotal_minor": -10000, "tax_minor": 0, "total_minor": -10000,
            "paid_minor": -10000, "change_minor": 0, "refund_of": sale,
            "refund_reason": "the wrong soap",
        }, row_id=refund, tx=tx),
        _op("sale_lines", {
            "sale_id": refund, "product_id": soap, "name": "Soap", "qty_minor": -2,
            "decimal_places": 0, "unit_price_minor": 5000, "unit_cost_minor": 0,
            "line_total_minor": -10000, "currency": "AFN",
        }, tx=tx),
    ]
    result = shop.push(*ops)
    assert result[1] == ("rejected", "REFUND_QTY_INVALID")
    assert result[0] == ("rejected", ABORTED)
    assert client.get(f"/sales/{refund}", headers=shop.owner).status_code == 404
    assert (shop.on_hand(soap), shop.on_hand(rice)) == (9, 9)


def test_a_sale_with_returns_is_past_voiding(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, cash=10000)
    _, ops = _return(shop, sale, pid, 1, worth=5000, shift=None, number="INV-D1-R4")
    ops[3]["data"]["method"] = "transfer"
    assert shop.push(*ops) == [("applied", None)] * 4
    assert shop.push(*_void(shop, sale, pid, 2))[0] == ("rejected", "SALE_NOT_VOIDABLE")
    assert shop.status(sale) == "settled"


def test_a_sale_that_is_not_a_return_keeps_its_signs(client: TestClient) -> None:
    shop = Shop(client)
    assert shop.push(_op("sales", {
        "number": "INV-D1-9", "branch_id": shop.branch, "shift_id": None, "customer_id": None,
        "status": "settled", "currency": "AFN", "discount_minor": 0, "subtotal_minor": -5000,
        "tax_minor": 0, "total_minor": -5000, "paid_minor": -5000, "change_minor": 0,
    })) == [("rejected", "SYNC_FIELD_INVALID")]
