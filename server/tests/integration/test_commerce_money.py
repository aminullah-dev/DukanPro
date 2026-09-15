"""Theme 7a, sale money.

A void takes back the debt a credit sale made; credit goes only to an open
account, in the customer's currency; a write-off forgives debt within the
balance; online, a sale never takes stock the branch does not have; profit is
what the sales took, less what the goods cost; a device writes off debt with
debt.write_off, and a credit sale to a closed account is kept and flagged."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient
from httpx import Response
from sqlalchemy import Engine, select, update
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import AuditEntryModel, CustomerLedgerModel, CustomerModel

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"


def _uuid() -> str:
    return str(uuid.uuid4())


def _engine(client: TestClient) -> Engine:
    engine: Engine = client.app.state.engine  # type: ignore[attr-defined]
    return engine


def _code(r: Response) -> tuple[int, str]:
    return r.status_code, r.json()["error"]["code"]


class Shop:
    def __init__(self, client: TestClient) -> None:
        boot = client.post("/auth/bootstrap", json={
            "setup_token": "test-setup-token", "username": "owner", "password": PW,
            "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.client = client
        self.owner = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
        self.branch: str = boot["user"]["default_branch_id"]

    def product(
        self, *, price: int = 5000, stock: int = 0, cost: int | None = None, track: bool = True
    ) -> str:
        pid: str = self.client.post("/products", headers=self.owner, json={
            "sku": "S" + _uuid()[:8], "name": "Soap", "unit_id": PIECE,
            "sell_price_minor": price, "track_stock": track,
        }).json()["id"]
        if cost is not None:  # a receipt brings the stock in at a cost
            r = self.client.post("/goods-receipts", headers=self.owner, json={
                "lines": [{"product_id": pid, "qty_minor": stock, "unit_cost_minor": cost}],
            })
            assert r.status_code == 200, r.text
        elif stock:
            r = self.client.post("/stock/adjust", headers=self.owner, json={
                "product_id": pid, "qty_delta": stock,
            })
            assert r.status_code == 200, r.text
        return pid

    def customer(self) -> str:
        cid: str = self.client.post(
            "/customers", headers=self.owner, json={"name": "Karim"}
        ).json()["id"]
        return cid

    def cashier(self) -> dict[str, str]:
        r = self.client.post("/users", headers=self.owner, json={
            "username": "cash1", "password": PW, "display_name": "Cashier", "role_name": "cashier",
        })
        assert r.status_code == 200, r.text
        tokens = self.client.post(
            "/auth/login", json={"username": "cash1", "password": PW}
        ).json()["tokens"]
        return {"Authorization": f"Bearer {tokens['access_token']}"}

    def sell(
        self, lines: list[tuple[str, int]], *, cash: int = 0, customer: str | None = None,
        discount: int = 0,
    ) -> Response:
        payments = (
            [{"method": "cash", "amount_minor": cash, "tendered_minor": cash}] if cash else []
        )
        return self.client.post("/sales", headers=self.owner, json={
            "lines": [{"product_id": p, "qty_minor": q} for p, q in lines],
            "payments": payments, "customer_id": customer, "discount_minor": discount,
        })

    def balance(self, customer: str) -> int:
        body = self.client.get(f"/customers/{customer}", headers=self.owner).json()
        return int(body["balance_minor"])

    def push(self, headers: dict[str, str], *ops: dict[str, Any]) -> list[tuple[str, Any]]:
        r = self.client.post(
            "/sync/push", headers=headers, json={"device_id": "dev-1", "ops": list(ops)}
        )
        assert r.status_code == 200, r.text
        return [(x["outcome"], x.get("code")) for x in r.json()["results"]]


def _op(table: str, data: dict[str, Any], row_id: str | None = None) -> dict[str, Any]:
    return {"op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": "insert",
            "data": data}


def test_voiding_a_credit_sale_takes_its_debt_back(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    r = shop.sell([(pid, 2)], customer=customer)
    assert r.status_code == 200, r.text
    sale = r.json()["id"]
    assert shop.balance(customer) == 10000
    r = client.post(f"/sales/{sale}/void", headers=shop.owner, json={"reason": "wrong customer"})
    assert r.status_code == 200, r.text
    assert shop.balance(customer) == 0
    with Session(_engine(client)) as s:
        back = s.scalars(select(CustomerLedgerModel).where(
            CustomerLedgerModel.ref_id == sale, CustomerLedgerModel.type == "adjustment"
        )).all()
        assert [(b.amount_minor, b.ref_type) for b in back] == [(-10000, "void")]
    pull = client.get("/sync/pull", headers=shop.owner, params={"since": 0}).json()
    assert any(
        c["table"] == "customer_ledger" and c["data"]["ref_type"] == "void"
        for c in pull["changes"]
    )


def test_credit_goes_only_to_an_open_account_in_its_currency(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    r = client.put(f"/customers/{customer}/status", headers=shop.owner,
                   json={"is_active": False, "version": 1})
    assert r.status_code == 200, r.text
    assert (r.json()["is_active"], r.json()["version"]) == (False, 2)
    assert _code(shop.sell([(pid, 1)], customer=customer)) == (409, "CUSTOMER_INACTIVE")
    stale = client.put(f"/customers/{customer}/status", headers=shop.owner,
                       json={"is_active": True, "version": 1})
    assert _code(stale) == (409, "CUSTOMER_VERSION_CONFLICT")
    r = client.put(f"/customers/{customer}/status", headers=shop.owner,
                   json={"is_active": True, "version": 2})
    assert r.status_code == 200, r.text
    # A customer who owes in dollars takes no afghani sale on credit.
    with Session(_engine(client)) as s:
        s.execute(update(CustomerModel).where(CustomerModel.id == customer).values(currency="USD"))
        s.commit()
    assert _code(shop.sell([(pid, 1)], customer=customer)) == (409, "DEBT_CURRENCY_MISMATCH")
    # Paid in full, a sale to them needs no credit at all.
    assert shop.sell([(pid, 1)], customer=customer, cash=5000).status_code == 200


def test_a_write_off_forgives_debt_within_the_balance(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    assert shop.sell([(pid, 3)], customer=customer).status_code == 200  # owes 150.00
    path = f"/customers/{customer}/write-offs"
    cashier = shop.cashier()
    assert _code(client.post(path, headers=cashier, json={"amount_minor": 1000})) == (
        403, "ACCESS_DENIED"
    )
    assert _code(client.post(path, headers=shop.owner, json={"amount_minor": 20000})) == (
        409, "DEBT_WRITE_OFF_EXCEEDS_BALANCE"
    )
    assert _code(client.post(path, headers=shop.owner, json={"amount_minor": 0})) == (
        422, "DEBT_WRITE_OFF_INVALID"
    )
    r = client.post(path, headers=shop.owner, json={"amount_minor": 5000})
    assert r.status_code == 200, r.text
    assert r.json()["balance_minor"] == 10000
    with Session(_engine(client)) as s:
        audit = s.scalar(select(AuditEntryModel).where(AuditEntryModel.action == "debt.written_off"))
        assert audit is not None and audit.after == {"amount": 5000, "balance": 15000}


def test_online_a_sale_never_takes_stock_the_branch_does_not_have(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=2)
    assert _code(shop.sell([(pid, 3)], cash=15000)) == (409, "STOCK_INSUFFICIENT")
    # Two lines of one product count together.
    assert _code(shop.sell([(pid, 1), (pid, 2)], cash=15000)) == (409, "STOCK_INSUFFICIENT")
    assert shop.sell([(pid, 2)], cash=10000).status_code == 200
    # A product whose stock is not tracked is not counted.
    untracked = shop.product(track=False)
    assert shop.sell([(untracked, 5)], cash=25000).status_code == 200


def test_profit_is_what_the_sales_took_less_what_the_goods_cost(client: TestClient) -> None:
    shop = Shop(client)
    costed = shop.product(price=5000, stock=10, cost=4000)
    uncosted = shop.product(price=3000, stock=10)
    # 2 x 50.00 + 30.00 = 130.00, less a 10.00 discount: 120.00 taken.
    r = shop.sell([(costed, 2), (uncosted, 1)], cash=12000, discount=1000)
    assert r.status_code == 200, r.text
    d = client.get("/reports/dashboard", headers=shop.owner).json()
    assert d["profit_today_minor"] == 12000 - 2 * 4000
    assert d["unknown_cost_lines"] == 1


def test_a_device_writes_off_debt_with_debt_write_off(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    assert shop.sell([(pid, 2)], customer=customer).status_code == 200  # owes 100.00

    def write_off(amount: int) -> dict[str, Any]:
        return _op("customer_ledger", {
            "customer_id": customer, "type": "adjustment", "amount_minor": amount,
            "currency": "AFN", "ref_type": "write_off",
        })

    assert shop.push(shop.cashier(), write_off(-4000)) == [("rejected", "ACCESS_DENIED")]
    assert shop.push(shop.owner, write_off(4000)) == [("rejected", "SYNC_FIELD_INVALID")]
    assert shop.push(shop.owner, write_off(-4000)) == [("applied", None)]
    assert shop.balance(customer) == 6000


def test_a_credit_sale_to_a_closed_account_is_kept_and_flagged(client: TestClient) -> None:
    shop = Shop(client)
    pid, customer = shop.product(stock=10), shop.customer()
    r = client.put(f"/customers/{customer}/status", headers=shop.owner,
                   json={"is_active": False, "version": 1})
    assert r.status_code == 200, r.text
    # A till that had not heard of the closing sold on credit meanwhile.
    sale = _uuid()
    ops = [
        _op("sales", {
            "number": "INV-X-1", "branch_id": shop.branch, "shift_id": None,
            "customer_id": customer, "status": "settled", "currency": "AFN",
            "discount_minor": 0, "subtotal_minor": 5000, "tax_minor": 0, "total_minor": 5000,
            "paid_minor": 0, "change_minor": 0,
        }, row_id=sale),
        _op("sale_lines", {
            "sale_id": sale, "product_id": pid, "name": "Soap", "qty_minor": 1,
            "decimal_places": 0, "unit_price_minor": 5000, "unit_cost_minor": 0,
            "line_total_minor": 5000, "currency": "AFN",
        }),
        _op("customer_ledger", {
            "customer_id": customer, "type": "charge", "amount_minor": 5000, "currency": "AFN",
            "ref_type": "sale", "ref_id": sale,
        }),
    ]
    assert shop.push(shop.owner, *ops) == [("applied", None)] * 3
    assert shop.balance(customer) == 5000
    with Session(_engine(client)) as s:
        audit = s.scalar(select(AuditEntryModel).where(AuditEntryModel.action == "debt.charge_posted"))
        assert audit is not None and audit.after["customer_inactive"] is True
