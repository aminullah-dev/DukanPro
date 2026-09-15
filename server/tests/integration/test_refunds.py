"""Returns (docs/domain/sales.md): a new negative sale naming the sale it takes
goods back from. Stock comes back only if the sale took it, what the customer
still owes comes off first, the rest is paid out (cash from the refunder's own
drawer), the returns add up to the sale, and a sale with returns is past voiding."""

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
TRANSFER = "transfer"


def _code(r: Response) -> tuple[int, str]:
    return r.status_code, r.json()["error"]["code"]


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

    def cashier(self) -> dict[str, str]:
        r = self.client.post("/users", headers=self.owner, json={
            "username": "kamal", "password": PW, "display_name": "Kamal", "role_name": "cashier",
        })
        assert r.status_code == 200, r.text
        tokens = self.client.post(
            "/auth/login", json={"username": "kamal", "password": PW}
        ).json()["tokens"]
        return {"Authorization": f"Bearer {tokens['access_token']}"}

    def product(self, *, track: bool = True, stock: int = 0) -> str:
        r = self.client.post("/products", headers=self.owner, json={
            "sku": "S" + str(uuid.uuid4())[:8], "name": "Item", "unit_id": PIECE,
            "sell_price_minor": 5000, "track_stock": track,
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
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def open_shift(self) -> str:
        r = self.client.post("/shifts", headers=self.owner, json={"opening_float_minor": 0})
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def sell(
        self, pid: str, qty: int, *, pay: int = 0, method: str = "cash",
        customer: str | None = None, shift: str | None = None, discount: int = 0,
    ) -> str:
        r = self.client.post("/sales", headers=self.owner, json={
            "lines": [{"product_id": pid, "qty_minor": qty}],
            "payments": [{"method": method, "amount_minor": pay}] if pay else [],
            "customer_id": customer, "shift_id": shift, "discount_minor": discount,
        })
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def refund(
        self, sale: str, lines: dict[str, int], *, method: str = "cash",
        shift: str | None = None, reason: str = "damaged",
        headers: dict[str, str] | None = None,
    ) -> Response:
        return self.client.post(f"/sales/{sale}/refunds", headers=headers or self.owner, json={
            "lines": [{"product_id": p, "qty_minor": q} for p, q in lines.items()],
            "reason": reason, "method": method, "shift_id": shift,
        })

    def void(self, sale: str) -> Response:
        return self.client.post(f"/sales/{sale}/void", headers=self.owner, json={"reason": "back"})

    def balance(self, customer: str) -> int:
        r = self.client.get(f"/customers/{customer}", headers=self.owner)
        return int(r.json()["balance_minor"])

    def on_hand(self, pid: str) -> int:
        return int(self.client.get(f"/products/{pid}", headers=self.owner).json()["on_hand"])


def test_a_cash_return_pays_out_of_the_refunders_drawer_and_restocks(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    shift = shop.open_shift()
    sale = shop.sell(pid, 3, pay=15000, shift=shift)
    assert shop.on_hand(pid) == 7
    r = shop.refund(sale, {pid: 1}, shift=shift)
    assert r.status_code == 200, r.text
    body = r.json()
    assert (body["refund_of"], body["total_minor"], body["paid_minor"]) == (sale, -5000, -5000)
    assert [(x["qty_minor"], x["line_total_minor"]) for x in body["lines"]] == [(-1, -5000)]
    assert shop.on_hand(pid) == 8
    r = client.post(f"/shifts/{shift}/close", headers=shop.owner, json={"counted_cash_minor": 10000})
    assert r.json()["expected_cash_minor"] == 10000  # 150.00 taken, 50.00 handed back
    after = _audit_after(client, sale, "sale.refunded")
    assert (after["total"], after["money_back"], after["reason"]) == (5000, 5000, "damaged")


def test_returns_add_up_to_the_sale_and_never_take_back_more(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    shift = shop.open_shift()
    sale = shop.sell(pid, 3, pay=14000, shift=shift, discount=1000)  # 150.00 less 10.00
    first = shop.refund(sale, {pid: 1}, shift=shift).json()
    assert first["total_minor"] == -4667  # 50.00 less its 3.33 share of the discount
    second = shop.refund(sale, {pid: 2}, shift=shift).json()
    assert second["total_minor"] == -(14000 - 4667)  # the last return takes what is left
    assert _code(shop.refund(sale, {pid: 1}, shift=shift)) == (422, "REFUND_QTY_INVALID")


def test_what_the_customer_still_owes_comes_off_first(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    shift = shop.open_shift()
    sale = shop.sell(pid, 2, customer=customer, shift=shift)  # 100.00 on credit
    r = shop.refund(sale, {pid: 1}, shift=shift)
    assert r.status_code == 200, r.text
    assert r.json()["paid_minor"] == 0  # nothing handed over: the debt went down
    assert shop.balance(customer) == 5000
    # They pay 30.00 of the 50.00 still owed, then bring the other one back.
    r = client.post(f"/customers/{customer}/payments", headers=shop.owner, json={"amount_minor": 3000})
    assert r.status_code == 200, r.text
    r = shop.refund(sale, {pid: 1}, shift=shift)
    assert r.json()["paid_minor"] == -3000  # what they paid comes back in cash
    assert shop.balance(customer) == 0


def test_cash_back_needs_the_refunders_open_drawer_a_transfer_does_not(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, pay=10000)
    assert _code(shop.refund(sale, {pid: 1})) == (409, "SHIFT_NOT_OPEN")
    r = shop.refund(sale, {pid: 1}, method=TRANSFER)
    assert r.status_code == 200, r.text
    assert r.json()["paid_minor"] == -5000


def test_goods_that_never_left_stock_do_not_come_back_to_it(client: TestClient) -> None:
    shop = Shop(client)
    service = shop.product(track=False)
    sale = shop.sell(service, 2, pay=10000, method=TRANSFER)
    assert shop.refund(sale, {service: 1}, method=TRANSFER).status_code == 200
    assert shop.on_hand(service) == 0


def test_a_sale_with_returns_is_past_voiding_and_a_return_is_final(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, pay=10000, method=TRANSFER)
    refund = shop.refund(sale, {pid: 1}, method=TRANSFER).json()["id"]
    assert _code(shop.void(sale)) == (409, "SALE_NOT_VOIDABLE")
    assert _code(shop.void(refund)) == (409, "SALE_NOT_VOIDABLE")
    assert _code(shop.refund(refund, {pid: 1}, method=TRANSFER)) == (409, "SALE_NOT_REFUNDABLE")
    voided = shop.sell(pid, 1, pay=5000, method=TRANSFER)
    assert shop.void(voided).status_code == 200
    assert _code(shop.refund(voided, {pid: 1}, method=TRANSFER)) == (409, "SALE_NOT_REFUNDABLE")


def test_a_return_needs_a_manager_a_reason_and_a_way_to_pay_back(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    sale = shop.sell(pid, 2, pay=10000, method=TRANSFER)
    assert shop.refund(sale, {pid: 1}, method=TRANSFER, headers=shop.cashier()).status_code == 403
    assert _code(shop.refund(sale, {pid: 1}, method=TRANSFER, reason=" ")) == (
        422, "REFUND_REASON_REQUIRED",
    )
    assert _code(shop.refund(sale, {pid: 1}, method="cheque")) == (422, "REFUND_METHOD_INVALID")
    assert _code(shop.refund(sale, {}, method=TRANSFER)) == (422, "REFUND_EMPTY")
