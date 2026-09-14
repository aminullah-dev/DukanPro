"""Theme 7b: tenders and shifts.

A payment is cash, card or transfer, and only cash counts in a drawer. A sale or
a debt collection goes into its seller's own open shift, and a seller has one
open shift per branch. A device opens and closes its shift through sync; the
server works out the expected cash itself: the float, the cash of the shift's
settled sales and the debts collected in it in cash."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient
from httpx import Response

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"


def _uuid() -> str:
    return str(uuid.uuid4())


def _code(r: Response) -> tuple[int, str]:
    return r.status_code, r.json()["error"]["code"]


def _op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, kind: str = "insert",
    base_version: int | None = None,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": kind, "data": data,
    }
    if base_version is not None:
        body["base_version"] = base_version
    return body


class Shop:
    def __init__(self, client: TestClient) -> None:
        boot = client.post("/auth/bootstrap", json={
            "setup_token": "test-setup-token", "username": "owner", "password": PW,
            "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.client = client
        self.owner = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
        self.branch: str = boot["user"]["default_branch_id"]
        # Not stock-tracked: these tests are about money, not shelves.
        self.pid: str = client.post("/products", headers=self.owner, json={
            "sku": "S1", "name": "Soap", "unit_id": PIECE, "sell_price_minor": 5000,
            "track_stock": False,
        }).json()["id"]

    def cashier(self, name: str = "cash1") -> tuple[dict[str, str], str]:
        r = self.client.post("/users", headers=self.owner, json={
            "username": name, "password": PW, "display_name": name, "role_name": "cashier",
        })
        assert r.status_code == 200, r.text
        tokens = self.client.post(
            "/auth/login", json={"username": name, "password": PW}
        ).json()["tokens"]
        return {"Authorization": f"Bearer {tokens['access_token']}"}, r.json()["id"]

    def open_shift(self, headers: dict[str, str], float_minor: int = 0) -> Response:
        return self.client.post("/shifts", headers=headers, json={"opening_float_minor": float_minor})

    def sell(
        self, headers: dict[str, str], payments: list[dict[str, Any]], *, qty: int = 1,
        shift: str | None = None, customer: str | None = None,
    ) -> Response:
        return self.client.post("/sales", headers=headers, json={
            "lines": [{"product_id": self.pid, "qty_minor": qty}], "payments": payments,
            "shift_id": shift, "customer_id": customer,
        })

    def customer(self) -> str:
        cid: str = self.client.post(
            "/customers", headers=self.owner, json={"name": "Karim"}
        ).json()["id"]
        return cid

    def push(self, headers: dict[str, str], *ops: dict[str, Any]) -> list[tuple[str, Any]]:
        r = self.client.post(
            "/sync/push", headers=headers, json={"device_id": "dev-1", "ops": list(ops)}
        )
        assert r.status_code == 200, r.text
        return [(x["outcome"], x.get("code")) for x in r.json()["results"]]

    def shift_image(self, shift: str) -> dict[str, Any]:
        pull = self.client.get("/sync/pull", headers=self.owner, params={"since": 0}).json()
        images = [c["data"] for c in pull["changes"] if c["table"] == "shifts" and c["row_id"] == shift]
        return images[-1]


CASH = [{"method": "cash", "amount_minor": 5000}]


def test_card_and_transfer_are_tenders_but_only_cash_is_in_the_drawer(client: TestClient) -> None:
    shop = Shop(client)
    shift = shop.open_shift(shop.owner, 100000).json()["id"]
    # 150.00 paid 50.00 in cash (100.00 handed over), 60.00 by card, 40.00 by transfer.
    r = shop.sell(shop.owner, [
        {"method": "cash", "amount_minor": 5000, "tendered_minor": 10000},
        {"method": "card", "amount_minor": 6000},
        {"method": "transfer", "amount_minor": 4000},
    ], qty=3, shift=shift)
    assert r.status_code == 200, r.text
    assert r.json()["change_minor"] == 5000
    customer = shop.customer()
    assert shop.sell(shop.owner, [], qty=2, shift=shift, customer=customer).status_code == 200
    for method, amount in (("cash", 3000), ("transfer", 2000)):
        r = client.post(f"/customers/{customer}/payments", headers=shop.owner,
                        json={"amount_minor": amount, "method": method, "shift_id": shift})
        assert r.status_code == 200, r.text
    closed = client.post(f"/shifts/{shift}/close", headers=shop.owner,
                         json={"counted_cash_minor": 108000}).json()
    # The float, the cash sale and the cash collection; card and transfer stay out.
    assert closed["expected_cash_minor"] == 100000 + 5000 + 3000
    assert closed["variance_minor"] == 0


def test_a_sale_goes_into_its_sellers_own_open_shift(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.cashier()
    theirs = shop.open_shift(cashier).json()["id"]
    assert _code(shop.sell(shop.owner, CASH, shift=theirs)) == (409, "SHIFT_NOT_OPEN")
    assert _code(shop.sell(cashier, CASH, shift=_uuid())) == (404, "SHIFT_NOT_FOUND")
    assert _code(shop.open_shift(cashier)) == (409, "SHIFT_ALREADY_OPEN")
    assert shop.sell(cashier, CASH, shift=theirs).status_code == 200
    r = client.post(f"/shifts/{theirs}/close", headers=cashier, json={"counted_cash_minor": 5000})
    assert r.status_code == 200, r.text
    assert _code(shop.sell(cashier, CASH, shift=theirs)) == (409, "SHIFT_NOT_OPEN")
    image = shop.shift_image(theirs)
    assert (image["status"], image["expected_cash_minor"], image["variance_minor"]) == (
        "closed", 5000, 0
    )


def test_a_device_opens_sells_into_and_closes_its_shift(client: TestClient) -> None:
    shop = Shop(client)
    cashier, cashier_id = shop.cashier()
    customer = shop.customer()
    assert shop.sell(shop.owner, [], customer=customer).status_code == 200  # owes 50.00
    shift = _uuid()
    opened = _op("shifts", {
        "branch_id": shop.branch, "user_id": cashier_id, "opening_float_minor": 50000,
        "status": "open",
    }, row_id=shift)
    assert shop.push(cashier, opened) == [("applied", None)]
    # A 100.00 sale paid 70.00 in cash and 30.00 by transfer, into the shift.
    sale = _uuid()
    ops = [
        _op("sales", {
            "number": "INV-D1-1", "branch_id": shop.branch, "shift_id": shift,
            "customer_id": None, "status": "settled", "currency": "AFN", "discount_minor": 0,
            "subtotal_minor": 10000, "tax_minor": 0, "total_minor": 10000, "paid_minor": 10000,
            "change_minor": 0,
        }, row_id=sale),
        _op("sale_lines", {
            "sale_id": sale, "product_id": shop.pid, "name": "Soap", "qty_minor": 2,
            "decimal_places": 0, "unit_price_minor": 5000, "unit_cost_minor": 0,
            "line_total_minor": 10000, "currency": "AFN",
        }),
        _op("payments", {
            "sale_id": sale, "method": "cash", "amount_minor": 7000, "currency": "AFN",
            "tendered_minor": 7000, "change_minor": 0,
        }),
        _op("payments", {
            "sale_id": sale, "method": "transfer", "amount_minor": 3000, "currency": "AFN",
        }),
        # 20.00 of the old debt, collected in cash at the till.
        _op("customer_ledger", {
            "customer_id": customer, "type": "payment", "amount_minor": 2000, "currency": "AFN",
            "ref_type": "manual", "method": "cash", "shift_id": shift,
        }),
    ]
    assert shop.push(cashier, *ops) == [("applied", None)] * 5
    close = _op("shifts", {"status": "closed", "counted_cash_minor": 60000},
                row_id=shift, kind="update", base_version=1)
    assert shop.push(cashier, close) == [("applied", None)]
    image = shop.shift_image(shift)
    assert (image["status"], image["expected_cash_minor"], image["variance_minor"]) == (
        "closed", 50000 + 7000 + 2000, 1000
    )
    again = _op("shifts", {"status": "closed", "counted_cash_minor": 0},
                row_id=shift, kind="update", base_version=2)
    assert shop.push(cashier, again) == [("rejected", "SHIFT_ALREADY_CLOSED")]
    # A sale naming another seller's shift is refused.
    other = _uuid()
    stolen = _op("sales", {
        "number": "INV-D2-1", "branch_id": shop.branch, "shift_id": shift, "customer_id": None,
        "status": "settled", "currency": "AFN", "discount_minor": 0, "subtotal_minor": 5000,
        "tax_minor": 0, "total_minor": 5000, "paid_minor": 5000, "change_minor": 0,
    }, row_id=other)
    assert shop.push(shop.owner, stolen) == [("rejected", "SYNC_REF_MISMATCH")]


def test_a_shift_opens_only_for_its_pusher_and_closes_by_them_or_a_manager(
    client: TestClient,
) -> None:
    shop = Shop(client)
    cashier, cashier_id = shop.cashier()
    other, _ = shop.cashier("cash2")
    forged = _op("shifts", {"branch_id": shop.branch, "user_id": cashier_id, "status": "open"})
    assert shop.push(other, forged) == [("rejected", "SYNC_REF_MISMATCH")]
    shift = _uuid()
    assert shop.push(cashier, _op("shifts", {
        "branch_id": shop.branch, "user_id": cashier_id, "status": "open",
    }, row_id=shift)) == [("applied", None)]
    close = {"status": "closed", "counted_cash_minor": 0}
    assert shop.push(other, _op("shifts", close, row_id=shift, kind="update", base_version=1)) == [
        ("rejected", "ACCESS_DENIED")
    ]
    assert shop.push(shop.owner, _op("shifts", close, row_id=shift, kind="update", base_version=1)) == [
        ("applied", None)
    ]
