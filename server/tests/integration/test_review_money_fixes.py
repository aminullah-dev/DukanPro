"""Review of themes 6-9, money: a void takes back only what is still owed and only
the stock the sale took; a sale that took no cash can still be voided after its
shift closed; someone else's drawer closes only with a manager; a second open
drawer and money synced into a closed one are flagged; a mistyped SKU can be
corrected."""

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
        self.owner_id: str = boot["user"]["id"]
        self.branch: str = boot["user"]["default_branch_id"]

    def user(self, name: str, role: str) -> tuple[dict[str, str], str]:
        r = self.client.post("/users", headers=self.owner, json={
            "username": name, "password": PW, "display_name": name, "role_name": role,
        })
        assert r.status_code == 200, r.text
        tokens = self.client.post(
            "/auth/login", json={"username": name, "password": PW}
        ).json()["tokens"]
        return {"Authorization": f"Bearer {tokens['access_token']}"}, r.json()["id"]

    def product(self, *, track: bool = True, stock: int = 0) -> str:
        r = self.client.post("/products", headers=self.owner, json={
            "sku": "S" + _uuid()[:8], "name": "Item", "unit_id": PIECE,
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

    def sell(
        self, pid: str, qty: int, *, payments: list[dict[str, Any]] | None = None,
        customer: str | None = None, shift: str | None = None,
    ) -> str:
        r = self.client.post("/sales", headers=self.owner, json={
            "lines": [{"product_id": pid, "qty_minor": qty}], "payments": payments or [],
            "customer_id": customer, "shift_id": shift,
        })
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def void(self, sale: str) -> Response:
        return self.client.post(f"/sales/{sale}/void", headers=self.owner, json={"reason": "back"})

    def balance(self, customer: str) -> int:
        return int(self.client.get(f"/customers/{customer}", headers=self.owner).json()["balance_minor"])

    def on_hand(self, pid: str) -> int:
        return int(self.client.get(f"/products/{pid}", headers=self.owner).json()["on_hand"])

    def push(self, headers: dict[str, str], *ops: dict[str, Any]) -> list[tuple[str, Any]]:
        r = self.client.post(
            "/sync/push", headers=headers, json={"device_id": "dev-m", "ops": list(ops)}
        )
        assert r.status_code == 200, r.text
        return [(x["outcome"], x.get("code")) for x in r.json()["results"]]


def _shift(user_id: str, branch: str) -> dict[str, Any]:
    return _op("shifts", {
        "branch_id": branch, "user_id": user_id, "opening_float_minor": 0, "status": "open",
    })


def test_a_void_takes_back_only_what_the_customer_still_owes(client: TestClient) -> None:
    shop = Shop(client)
    pid, forgiven, paying = shop.product(stock=10), shop.customer(), shop.customer()
    first = shop.sell(pid, 2, customer=forgiven)  # 100.00 on credit, then forgiven
    r = client.post(f"/customers/{forgiven}/write-offs", headers=shop.owner,
                    json={"amount_minor": 10000})
    assert r.status_code == 200, r.text
    assert shop.void(first).status_code == 200
    assert shop.balance(forgiven) == 0  # not -100.00: a forgiven debt is not owed back
    second = shop.sell(pid, 2, customer=paying)  # 100.00 on credit, 40.00 paid
    r = client.post(f"/customers/{paying}/payments", headers=shop.owner, json={"amount_minor": 4000})
    assert r.status_code == 200, r.text
    assert shop.void(second).status_code == 200
    assert shop.balance(paying) == 0
    after = _audit_after(client, second, "sale.voided")
    assert (after["debt_reversed"], after["debt_not_reversed"]) == (6000, 4000)  # a refund by hand


def test_a_void_returns_only_the_stock_the_sale_took(client: TestClient) -> None:
    shop = Shop(client)
    service = shop.product(track=False)
    assert shop.void(shop.sell(service, 3, payments=[{"method": "cash", "amount_minor": 15000}])).status_code == 200
    assert shop.on_hand(service) == 0  # a service never had stock
    later = shop.product(track=False)
    sale = shop.sell(later, 4, payments=[{"method": "cash", "amount_minor": 20000}])
    assert client.patch(f"/products/{later}", headers=shop.owner, json={"track_stock": True}).status_code == 200
    r = client.post("/stock/adjust", headers=shop.owner, json={"product_id": later, "qty_delta": 10})
    assert r.status_code == 200, r.text
    assert shop.void(sale).status_code == 200
    assert shop.on_hand(later) == 10  # the sale took none, so the void returns none
    tracked = shop.product(stock=5)
    sale = shop.sell(tracked, 2, payments=[{"method": "cash", "amount_minor": 10000}])
    assert shop.on_hand(tracked) == 3
    assert shop.void(sale).status_code == 200
    assert shop.on_hand(tracked) == 5


def test_after_its_shift_closed_a_sale_that_took_no_cash_can_be_voided(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    shift = client.post("/shifts", headers=shop.owner, json={"opening_float_minor": 0}).json()["id"]
    credit = shop.sell(pid, 2, customer=customer, shift=shift)
    cash = shop.sell(pid, 1, payments=[{"method": "cash", "amount_minor": 5000}], shift=shift)
    r = client.post(f"/shifts/{shift}/close", headers=shop.owner, json={"counted_cash_minor": 5000})
    assert r.status_code == 200, r.text
    assert shop.void(credit).status_code == 200  # no drawer cash involved
    assert shop.balance(customer) == 0
    assert _code(shop.void(cash)) == (409, "SALE_SHIFT_CLOSED")  # its cash was counted


def test_only_a_manager_closes_someone_elses_shift(client: TestClient) -> None:
    shop = Shop(client)
    cashier, cashier_id = shop.user("cash1", "cashier")
    accountant, _ = shop.user("acc1", "accountant")
    manager, _ = shop.user("man1", "manager")
    shift = client.post("/shifts", headers=cashier, json={"opening_float_minor": 10000}).json()["id"]
    r = client.post(f"/shifts/{shift}/close", headers=accountant, json={"counted_cash_minor": 0})
    assert _code(r) == (403, "ACCESS_DENIED")
    synced = _shift(cashier_id, shop.branch)
    assert shop.push(cashier, synced) == [("applied", None)]
    close = _op("shifts", {"status": "closed", "counted_cash_minor": 0}, row_id=synced["row_id"],
                kind="update", base_version=1)
    assert shop.push(accountant, close) == [("rejected", "ACCESS_DENIED")]
    r = client.post(f"/shifts/{shift}/close", headers=manager, json={"counted_cash_minor": 10000})
    assert r.status_code == 200, r.text


def test_a_second_drawer_on_another_till_is_kept_and_flagged(client: TestClient) -> None:
    shop = Shop(client)
    cashier, cashier_id = shop.user("cash1", "cashier")
    first, second = _shift(cashier_id, shop.branch), _shift(cashier_id, shop.branch)
    assert shop.push(cashier, first) == [("applied", None)]
    assert shop.push(cashier, second) == [("applied", None)]
    assert "another_open_shift" not in _audit_after(client, first["row_id"], "shift.opened")
    assert _audit_after(client, second["row_id"], "shift.opened")["another_open_shift"] == first["row_id"]


def test_money_synced_into_a_closed_shift_is_flagged(client: TestClient) -> None:
    shop = Shop(client)
    customer = shop.customer()
    pid = shop.product(track=False)
    shop.sell(pid, 2, customer=customer)  # owes 100.00
    supplier = client.post("/suppliers", headers=shop.owner, json={"name": "Wholesale"}).json()["id"]
    r = client.post("/goods-receipts", headers=shop.owner, json={
        "supplier_id": supplier, "lines": [{"product_id": pid, "qty_minor": 1, "unit_cost_minor": 9000}],
    })
    assert r.status_code == 200, r.text
    shift = _shift(shop.owner_id, shop.branch)
    close = _op("shifts", {"status": "closed", "counted_cash_minor": 0}, row_id=shift["row_id"],
                kind="update", base_version=1)
    assert shop.push(shop.owner, shift, close) == [("applied", None)] * 2
    collection = _op("customer_ledger", {
        "customer_id": customer, "type": "payment", "amount_minor": 4000, "currency": "AFN",
        "ref_type": "manual", "method": "cash", "shift_id": shift["row_id"],
    })
    payout = _op("supplier_ledger", {
        "supplier_id": supplier, "type": "payment", "amount_minor": 3000, "currency": "AFN",
        "method": "cash", "shift_id": shift["row_id"],
    })
    assert shop.push(shop.owner, collection, payout) == [("applied", None)] * 2
    assert _audit_after(client, collection["row_id"], "debt.payment_recorded")["after_shift_close"] is True
    assert _audit_after(client, payout["row_id"], "supplier.payment_recorded")["after_shift_close"] is True


def test_a_mistyped_sku_is_corrected(client: TestClient) -> None:
    shop = Shop(client)
    rice, sugar = shop.product(), shop.product()
    taken = client.get(f"/products/{sugar}", headers=shop.owner).json()["sku"]
    r = client.patch(f"/products/{rice}", headers=shop.owner, json={"sku": "RICE-5KG"})
    assert r.status_code == 200, r.text
    assert r.json()["sku"] == "RICE-5KG"
    r = client.patch(f"/products/{rice}", headers=shop.owner, json={"sku": taken})
    assert _code(r) == (409, "PRODUCT_DUPLICATE_SKU")
    # A till that corrected it offline to a SKU another product got meanwhile: kept, flagged.
    edit = _op("products", {"sku": taken}, row_id=rice, kind="update", base_version=2)
    assert shop.push(shop.owner, edit) == [("applied", None)]
    assert _audit_after(client, rice, "product.updated")["sku_taken"] is True
