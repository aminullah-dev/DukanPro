"""Sync push/pull hardening (review theme 1): per-op authorization per role and
branch, strict per-table schema, compare-and-set, audit, replay codes, R1-6
attribution, scoped + bounded pull, REST input bounds."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from typing import Any

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select, update

import dukan.infrastructure.sync_service as sync_service_module
from dukan.application.sync_policy import READ_FIELDS
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BranchAssignmentModel,
    ProcessedOpModel,
    ProductModel,
)
from dukan.shared.limits import MONEY_MAX

PW = "pw12345678"
SEED_UNITS = [("piece", 0), ("kg", 3), ("litre", 3), ("dozen", 0), ("meter", 2)]


def _uuid() -> str:
    return str(uuid.uuid4())


def op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, kind: str = "insert",
    base_version: int | None = None, **extra: Any,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": kind, "data": data,
    }
    if base_version is not None:
        body["base_version"] = base_version
    body.update(extra)
    return body


def product_op(unit: str, *, sku: str = "P1", row_id: str | None = None, **over: Any) -> dict:
    data = {
        "sku": sku, "name": "Tea", "unit_id": unit, "category_id": None, "sell_price_minor": 5000,
        "sell_currency": "AFN", "cost_minor": None, "cost_currency": None, "track_stock": True,
        "is_active": True,
    }
    data.update(over)
    return op("products", data, row_id=row_id)


def sale_ops(
    branch: str, product_id: str, *, price: int = 5000, qty: int = 2,
    customer_id: str | None = None, cash: int = 0,
) -> tuple[str, list[dict]]:
    """The ops LocalSales.settle records, in the same order (with the sale ref)."""
    sale_id = _uuid()
    total = price * qty
    paid = total if customer_id is None else cash
    ops = [
        op("sales", {
            "number": "INV-20260912-0001", "branch_id": branch, "shift_id": None,
            "customer_id": customer_id, "status": "settled", "currency": "AFN",
            "discount_minor": 0, "subtotal_minor": total, "tax_minor": 0, "total_minor": total,
            "paid_minor": paid, "change_minor": 0,
        }, row_id=sale_id),
        op("sale_lines", {
            "sale_id": sale_id, "product_id": product_id, "name": "Tea", "qty_minor": qty,
            "decimal_places": 0, "unit_price_minor": price, "unit_cost_minor": 0,
            "line_total_minor": total, "currency": "AFN",
        }),
        op("stock_movements", {
            "product_id": product_id, "branch_id": branch, "qty_delta": -qty, "reason": "sale",
            "ref_type": "sale", "ref_id": sale_id,
        }),
    ]
    if paid > 0:
        ops.append(op("payments", {
            "sale_id": sale_id, "method": "cash", "amount_minor": paid, "currency": "AFN",
            "tendered_minor": None if customer_id else paid, "change_minor": 0,
        }))
    if customer_id is not None and total > paid:
        ops.append(op("customer_ledger", {
            "customer_id": customer_id, "type": "charge", "amount_minor": total - paid,
            "currency": "AFN", "ref_type": "sale", "ref_id": sale_id,
        }))
    return sale_id, ops


def seed_ops() -> list[dict]:
    return [op("units", {"name": n, "decimal_places": dp}) for n, dp in SEED_UNITS]


def outcomes(results: list[dict]) -> list[tuple[str, str | None]]:
    return [(r["outcome"], r["code"]) for r in results]


class Shop:
    def __init__(self, client: TestClient) -> None:
        self.c = client
        boot = client.post("/auth/bootstrap", json={"setup_token": "test-setup-token", 
            "username": "owner", "password": PW, "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.owner_id: str = boot["user"]["id"]
        self.owner = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
        self.branch: str = boot["user"]["default_branch_id"]
        self.units = {u["name"]: u["id"] for u in client.get("/units", headers=self.owner).json()}

    def employee(self, username: str, role: str, branch_id: str | None = None) -> tuple[dict, str]:
        body = {"username": username, "password": PW, "display_name": username, "role_name": role}
        if branch_id:
            body["branch_id"] = branch_id
        r = self.c.post("/users", headers=self.owner, json=body)
        assert r.status_code == 200, r.text
        tok = self.c.post("/auth/login", json={"username": username, "password": PW}).json()
        return {"Authorization": f"Bearer {tok['tokens']['access_token']}"}, r.json()["id"]

    def push(self, headers: dict, *ops: dict, branch: str | None = None) -> list[dict]:
        h = {**headers, **({"X-Branch-Id": branch} if branch else {})}
        r = self.c.post("/sync/push", headers=h, json={"device_id": "dev-1", "ops": list(ops)})
        assert r.status_code == 200, r.text
        return r.json()["results"]

    def pull(self, headers: dict, since: int = 0, limit: int = 1000) -> dict:
        r = self.c.get("/sync/pull", headers=headers, params={"since": since, "limit": limit})
        assert r.status_code == 200, r.text
        return r.json()

    def product(self, sku: str = "P1", *, track_stock: bool = True) -> str:
        pid = _uuid()
        res = self.push(self.owner, product_op(
            self.units["piece"], sku=sku, row_id=pid, track_stock=track_stock,
        ))
        assert outcomes(res) == [("applied", None)]
        return pid

    def second_branch(self) -> str:
        b2 = self.c.post("/branches", headers=self.owner, json={"name": "Branch 2"}).json()["id"]
        r = self.c.post(
            f"/users/{self.owner_id}/roles", headers=self.owner,
            json={"branch_id": b2, "role_name": "owner"},
        )
        assert r.status_code == 200, r.text
        return b2


# ── R1-0: authorization per role, per branch ─────────────────────────────────


def test_cashier_pushes_every_flow_the_app_records(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    cashier, _ = shop.employee("c1", "cashier")
    assert set(outcomes(shop.push(cashier, *seed_ops()))) == {("applied", None)}
    cid = _uuid()
    customer = op("customers", {
        "name": "Ahmad", "phone": None, "credit_limit_minor": 100000, "currency": "AFN",
        "is_active": True,
    }, row_id=cid)
    assert outcomes(shop.push(cashier, customer)) == [("applied", None)]
    _, cash_sale = sale_ops(shop.branch, pid)
    _, credit_sale = sale_ops(shop.branch, pid, customer_id=cid, cash=2000)
    payment = op("customer_ledger", {
        "customer_id": cid, "type": "payment", "amount_minor": 1000, "currency": "AFN",
        "ref_type": "manual",
    })
    results = shop.push(cashier, *cash_sale, *credit_sale, payment)
    assert outcomes(results) == [("applied", None)] * (len(cash_sale) + len(credit_sale) + 1)
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["on_hand"] == -4
    debtor = client.get(f"/customers/{cid}", headers=shop.owner).json()
    assert debtor["balance_minor"] == 10000 - 2000 - 1000


def test_cashier_cannot_touch_catalog_stock_or_supplier_rows(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    sid = client.post("/suppliers", headers=shop.owner, json={"name": "Sup"}).json()["id"]
    cashier, _ = shop.employee("c1", "cashier")
    mv = {"product_id": pid, "branch_id": shop.branch}
    results = shop.push(
        cashier,
        op("products", {"sell_price_minor": 1}, row_id=pid, kind="update", base_version=1),
        product_op(shop.units["piece"], sku="C1"),
        op("stock_movements", {**mv, "qty_delta": -999, "reason": "adjustment"}),
        op("stock_movements", {**mv, "qty_delta": 50, "reason": "purchase"}),
        op("supplier_ledger", {"supplier_id": sid, "type": "bill", "amount_minor": 100}),
        op("units", {"name": "box", "decimal_places": 0}),
        op("barcodes", {"product_id": pid, "code": "123", "symbology": "ean13"}),
        op("suppliers", {"name": "X"}),
    )
    assert outcomes(results) == [("rejected", "ACCESS_DENIED")] * 8
    # The review repro: a -999 "sale" movement with no sale behind it.
    orphan = op("stock_movements", {**mv, "qty_delta": -999, "reason": "sale"})
    assert outcomes(shop.push(cashier, orphan)) == [("rejected", "SYNC_FIELD_REQUIRED")]
    got = client.get(f"/products/{pid}", headers=shop.owner).json()
    assert got["sell_price_minor"] == 5000 and got["on_hand"] == 0


def test_sale_children_must_belong_to_the_pushers_own_sale(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    c1, _ = shop.employee("c1", "cashier")
    c2, _ = shop.employee("c2", "cashier")
    sale_id, ops = sale_ops(shop.branch, pid, qty=2)
    assert set(outcomes(shop.push(c1, *ops))) == {("applied", None)}
    out_mv = {"product_id": pid, "branch_id": shop.branch, "qty_delta": -1, "reason": "sale",
              "ref_type": "sale", "ref_id": sale_id}
    pay = {"sale_id": sale_id, "method": "cash", "amount_minor": 1, "currency": "AFN"}
    line = {"sale_id": sale_id, "product_id": pid, "name": "Tea", "qty_minor": 1,
            "decimal_places": 0, "unit_price_minor": 5000, "line_total_minor": 5000}
    stranger = shop.push(c2, op("payments", pay), op("stock_movements", out_mv))
    assert outcomes(stranger) == [("rejected", "SYNC_REF_MISMATCH")] * 2
    extra = shop.push(
        c1, op("stock_movements", out_mv), op("payments", pay), op("sale_lines", line),
        op("sale_lines", {**line, "sale_id": _uuid()}),
    )
    assert outcomes(extra) == [("rejected", "SYNC_REF_MISMATCH")] * 3 + [
        ("rejected", "SALE_NOT_FOUND")
    ]


def test_stock_keeper_flows_and_limits(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    untracked = shop.product("U1", track_stock=False)
    sid = client.post("/suppliers", headers=shop.owner, json={"name": "Sup"}).json()["id"]
    keeper, _ = shop.employee("k1", "stock_keeper")
    mv = {"product_id": pid, "branch_id": shop.branch}
    ok = shop.push(
        keeper, *seed_ops(),
        op("stock_movements", {**mv, "qty_delta": 5, "reason": "adjustment"}),
        op("stock_movements", {**mv, "qty_delta": 10, "reason": "purchase"}),
    )
    assert set(outcomes(ok)) == {("applied", None)}
    # A bill is a debt to the supplier: purchase.cost, which a stock keeper lacks.
    bill = {"supplier_id": sid, "type": "bill", "amount_minor": 3000, "currency": "AFN"}
    assert outcomes(shop.push(keeper, op("supplier_ledger", bill))) == [
        ("rejected", "ACCESS_DENIED")
    ]
    ghost = {**bill, "supplier_id": _uuid()}
    assert outcomes(shop.push(shop.owner, op("supplier_ledger", ghost))) == [
        ("rejected", "SUPPLIER_NOT_FOUND")
    ]
    bad = shop.push(
        keeper,
        op("stock_movements", {**mv, "qty_delta": 0, "reason": "adjustment"}),
        op("stock_movements", {**mv, "qty_delta": -3, "reason": "purchase"}),
        op("stock_movements", {**mv, "product_id": untracked, "qty_delta": 2,
                               "reason": "adjustment"}),
        op("supplier_ledger", {"supplier_id": sid, "type": "payment", "amount_minor": 10}),
        op("supplier_ledger", {"supplier_id": _uuid(), "type": "bill", "amount_minor": 10}),
        sale_ops(shop.branch, pid)[1][0],
        op("customers", {"name": "X"}),
        product_op(shop.units["piece"], sku="K1"),
    )
    assert outcomes(bad) == [
        ("rejected", "STOCK_INVALID_QTY"), ("rejected", "STOCK_INVALID_QTY"),
        # A supplier payment is money out: purchase.cost, which a stock keeper lacks.
        ("rejected", "PRODUCT_NOT_STOCK_TRACKED"), ("rejected", "ACCESS_DENIED"),
        ("rejected", "ACCESS_DENIED"), ("rejected", "ACCESS_DENIED"),
        ("rejected", "ACCESS_DENIED"), ("rejected", "ACCESS_DENIED"),
    ]
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["on_hand"] == 15


def test_accountant_and_role_less_users_are_denied(client: TestClient) -> None:
    shop = Shop(client)
    cid = _uuid()
    shop.push(shop.owner, op("customers", {"name": "Ahmad"}, row_id=cid))
    accountant, _ = shop.employee("a1", "accountant")
    res = shop.push(
        accountant,
        op("customer_ledger", {"customer_id": cid, "type": "payment", "amount_minor": 100}),
        op("units", {"name": "piece", "decimal_places": 0}),  # the device seed: any member
    )
    assert outcomes(res) == [("rejected", "ACCESS_DENIED"), ("applied", None)]
    cashier, cashier_id = shop.employee("c1", "cashier")
    # The API keeps every user assigned; a role-less user only exists in older data.
    r = client.delete(f"/users/{cashier_id}/roles/{shop.branch}", headers=shop.owner)
    assert r.status_code == 409 and r.json()["error"]["code"] == "USER_LAST_ASSIGNMENT"
    with client.app.state.session_factory() as s:
        s.execute(
            update(BranchAssignmentModel)
            .where(BranchAssignmentModel.user_id == cashier_id)
            .values(deleted_at=datetime.now(UTC))
        )
        s.commit()
    pid = shop.product()
    _, ops = sale_ops(shop.branch, pid)
    assert outcomes(shop.push(cashier, ops[0], *seed_ops()[:1])) == [
        ("rejected", "ACCESS_DENIED")
    ] * 2
    pull = client.get("/sync/pull", headers=cashier)
    assert pull.status_code == 403 and pull.json()["error"]["code"] == "ACCESS_DENIED"


def test_branch_rows_are_authorized_in_their_own_branch(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    b2 = shop.second_branch()
    c2, _ = shop.employee("c2", "cashier", branch_id=b2)
    _, b1_sale = sale_ops(shop.branch, pid)
    _, b2_sale = sale_ops(b2, pid)
    assert outcomes(shop.push(c2, b1_sale[0])) == [("rejected", "ACCESS_DENIED")]
    assert set(outcomes(shop.push(c2, *b2_sale))) == {("applied", None)}
    # Shop-wide rows: the active branch (default B2) is allowed, X-Branch-Id B1 is not.
    assert outcomes(shop.push(c2, op("customers", {"name": "A"}))) == [("applied", None)]
    denied = shop.push(c2, op("customers", {"name": "B"}), branch=shop.branch)
    assert outcomes(denied) == [("rejected", "ACCESS_DENIED")]


# ── R1-1 / R1-104 / R1-102: strict per-table schema, per-op rejection ────────


@pytest.mark.parametrize(
    "field",
    ["id", "version", "created_by", "updated_by", "created_at", "updated_at", "deleted_at", "foo"],
)
def test_server_owned_and_unknown_fields_are_rejected(client: TestClient, field: str) -> None:
    shop = Shop(client)
    bad = product_op(shop.units["piece"], sku="S1")
    bad["data"][field] = 77 if field == "version" else (
        "2020-01-01T00:00:00+00:00" if field.endswith("_at") else "spoofed"
    )
    assert outcomes(shop.push(shop.owner, bad)) == [("rejected", "SYNC_FIELD_NOT_ALLOWED")]
    assert client.get("/products", headers=shop.owner, params={"search": "Tea"}).json() == []


def test_backdating_and_cost_injection_are_rejected(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    res = shop.push(
        shop.owner,
        op("stock_movements", {"product_id": pid, "branch_id": shop.branch, "qty_delta": 1,
                               "reason": "purchase", "occurred_at": "2020-01-01T00:00:00+00:00"}),
        product_op(shop.units["piece"], sku="S2", cost_minor=100),
    )
    assert outcomes(res) == [("rejected", "SYNC_FIELD_NOT_ALLOWED")] * 2


def test_malformed_ops_are_rejected_one_by_one(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    unit = shop.units["piece"]
    cid = _uuid()
    shop.push(shop.owner, op("customers", {"name": "Ahmad"}, row_id=cid))

    def mv(**d: Any) -> dict:
        return op("stock_movements", {"product_id": pid, "branch_id": shop.branch,
                                      "qty_delta": 1, "reason": "purchase", **d})

    cases = [
        (mv(qty_delta="5"), "SYNC_FIELD_INVALID"),
        (op("customer_ledger", {"customer_id": cid, "type": "payment", "amount_minor": 100.7}),
         "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T1", track_stock=1), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T2", sell_price_minor=True), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T3", sell_price_minor=MONEY_MAX + 1), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T4", sell_price_minor=-1), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T5", name="x" * 201), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T6", name="   "), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T7", name="a\x00b"), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T8", sell_currency="afn"), "MONEY_CURRENCY_INVALID"),
        (product_op(unit, sku="T9", unit_id="not-a-uuid"), "SYNC_FIELD_INVALID"),
        (product_op(unit, sku="T10", unit_id=_uuid()), "UNIT_NOT_FOUND"),
        (mv(reason="gift"), "SYNC_FIELD_INVALID"),
        (mv(reason="transfer_in"), "SYNC_OP_UNSUPPORTED"),
        ({**mv(), "op_id": "x" * 37}, "SYNC_OP_INVALID"),
        ({**mv(), "row_id": "short"}, "SYNC_OP_INVALID"),
        ({**mv(), "row_id": _uuid() + "\n"}, "SYNC_OP_INVALID"),
        ({**mv(), "row_id": _uuid().upper()}, "SYNC_OP_INVALID"),
        ({**mv(), "op": "upsert"}, "SYNC_OP_INVALID"),
        (op("users", {"username": "x"}), "UNKNOWN_TABLE"),
        (op("categories", {"name": "Drinks"}), "SYNC_OP_UNSUPPORTED"),
        (op("stock_movements", {"qty_delta": 5}, kind="update", base_version=1),
         "SYNC_OP_UNSUPPORTED"),
        (op("products", {"name": "No sku", "unit_id": unit}), "SYNC_FIELD_REQUIRED"),
        (op("customers", {"name": "A", "phone": "0" * 33}), "SYNC_FIELD_INVALID"),
        (op("sale_lines", {"sale_id": _uuid(), "product_id": pid, "name": "Tea", "qty_minor": 1,
                           "unit_price_minor": 1, "line_total_minor": 1}), "SALE_NOT_FOUND"),
        (op("customer_ledger", {"customer_id": _uuid(), "type": "payment", "amount_minor": 1}),
         "CUSTOMER_NOT_FOUND"),
    ]
    results = shop.push(shop.owner, *[c for c, _ in cases], mv())
    assert outcomes(results) == [("rejected", code) for _, code in cases] + [("applied", None)]


# ── R1-2: master rows — insert-on-existing, base_version, atomic CAS ─────────


def test_master_rows_use_compare_and_set(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()

    def upd(base: int | None, **data: Any) -> dict:
        return {**op("products", data, row_id=pid, kind="update"), "base_version": base}

    results = shop.push(
        shop.owner,
        product_op(shop.units["piece"], sku="P1", row_id=pid),
        upd(None, name="No base"),
        upd(1, name="Renamed"),
        upd(2, version=1),
        upd(2, unit_id=shop.units["kg"]),  # a unit is set once; a SKU may be corrected
        upd(2),
        op("products", {"name": "Ghost"}, kind="update", base_version=1),
    )
    assert outcomes(results) == [
        ("conflict", "PRODUCTS_ALREADY_EXISTS"),
        ("rejected", "SYNC_BASE_VERSION_REQUIRED"),
        ("applied", None),
        ("rejected", "SYNC_FIELD_NOT_ALLOWED"),
        ("rejected", "SYNC_FIELD_NOT_ALLOWED"),
        ("rejected", "SYNC_OP_INVALID"),
        ("rejected", "PRODUCT_NOT_FOUND"),
    ]
    # A stale edit loses its compare-and-set (a push of its own: within one push,
    # the edits after it on the row would be taken as made on top of it).
    stale = shop.push(shop.owner, upd(1, name="Stale"))
    assert outcomes(stale) == [("conflict", "PRODUCTS_VERSION_CONFLICT")]
    last = [c for c in shop.pull(shop.owner)["changes"] if c["row_id"] == pid][-1]
    assert last["op"] == "update"
    assert last["data"]["version"] == 2 and last["data"]["name"] == "Renamed"
    assert last["data"]["sku"] == "P1"  # full post-image, not the partial payload


def test_compare_and_set_catches_a_concurrent_writer(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    shop = Shop(client)
    pid = shop.product()
    real_plan = sync_service_module.plan_op

    def racing_plan(op_in: Any, **kwargs: Any) -> Any:
        plan = real_plan(op_in, **kwargs)
        with client.app.state.session_factory() as other:  # another push commits first
            other.execute(
                update(ProductModel).where(ProductModel.id == pid)
                .values(version=ProductModel.version + 1)
            )
            other.commit()
        return plan

    monkeypatch.setattr(sync_service_module, "plan_op", racing_plan)
    change = op("products", {"sell_price_minor": 1}, row_id=pid, kind="update", base_version=1)
    assert outcomes(shop.push(shop.owner, change)) == [("conflict", "PRODUCTS_VERSION_CONFLICT")]
    monkeypatch.undo()
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["sell_price_minor"] == 5000


# ── idempotency: replays keep outcome + code; state-dependent denials don't stick ──


def test_replays_return_the_original_outcome_and_code(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    mv = {"product_id": pid, "branch_id": shop.branch, "reason": "purchase"}
    stale = op("products", {"name": "x"}, row_id=pid, kind="update", base_version=9)
    invalid = op("stock_movements", {**mv, "qty_delta": "5"})
    good = op("stock_movements", {**mv, "qty_delta": 5})
    first = shop.push(shop.owner, stale, invalid, good)
    again = shop.push(shop.owner, stale, invalid, good)
    assert first == again
    assert outcomes(again) == [
        ("conflict", "PRODUCTS_VERSION_CONFLICT"), ("rejected", "SYNC_FIELD_INVALID"),
        ("applied", None),
    ]
    assert again[2]["server_seq"] is not None
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["on_hand"] == 5


def test_denials_are_not_cached_so_a_granted_role_can_replay(client: TestClient) -> None:
    shop = Shop(client)
    cashier, cashier_id = shop.employee("c1", "cashier")
    create = product_op(shop.units["piece"], sku="LATER")
    assert outcomes(shop.push(cashier, create)) == [("rejected", "ACCESS_DENIED")]
    r = client.post(f"/users/{cashier_id}/roles", headers=shop.owner,
                    json={"branch_id": shop.branch, "role_name": "manager"})
    assert r.status_code == 200, r.text
    assert outcomes(shop.push(cashier, create)) == [("applied", None)]


# ── R1-6: ops apply only under the recording user's token ────────────────────


def test_ops_apply_only_under_the_recording_users_token(client: TestClient) -> None:
    shop = Shop(client)
    cashier, cashier_id = shop.employee("c1", "cashier")
    queued = op("customers", {"name": "Recorded by owner"}, actor_id=shop.owner_id,
                created_at="2026-09-12T08:00:00.000Z")
    assert outcomes(shop.push(cashier, queued)) == [("rejected", "SYNC_ACTOR_MISMATCH")]
    assert outcomes(shop.push(shop.owner, queued)) == [("applied", None)]  # not cached
    own = op("customers", {"name": "Own"}, actor_id=cashier_id)
    assert outcomes(shop.push(cashier, own)) == [("applied", None)]
    with client.app.state.session_factory() as s:
        entry = s.scalar(select(AuditEntryModel).where(AuditEntryModel.entity_id == own["row_id"]))
        assert entry is not None and entry.actor_id == cashier_id
        assert entry.after["_sync"]["recorded_by"] == cashier_id
        rec = s.get(ProcessedOpModel, queued["op_id"])
        assert rec is not None and rec.actor_id == shop.owner_id and rec.device_id == "dev-1"
    bad_time = op("customers", {"name": "T"}, created_at="yesterday")
    assert outcomes(shop.push(cashier, bad_time)) == [("rejected", "SYNC_OP_INVALID")]


# ── R1-5: one audit entry per applied op, same transaction ───────────────────


def test_every_applied_op_writes_one_sync_audit_entry(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    mv = {"product_id": pid, "branch_id": shop.branch, "reason": "adjustment"}
    res = shop.push(
        shop.owner,
        op("products", {"sell_price_minor": 6000, "name": "Tea"}, row_id=pid, kind="update",
           base_version=1),
        op("stock_movements", {**mv, "qty_delta": -2}),
        op("stock_movements", {**mv, "qty_delta": 0}),
    )
    assert outcomes(res) == [("applied", None)] * 2 + [("rejected", "STOCK_INVALID_QTY")]
    with client.app.state.session_factory() as s:
        rows = s.scalars(
            select(AuditEntryModel).where(AuditEntryModel.origin == "sync")
            .order_by(AuditEntryModel.occurred_at)
        ).all()
    assert [r.action for r in rows] == ["product.created", "product.price_changed", "stock.adjusted"]
    price = rows[1]
    assert price.before == {"sell_price_minor": 5000}
    assert price.after is not None and price.after["sell_price_minor"] == 6000
    assert price.actor_id == shop.owner_id and price.actor_role == "owner"
    assert price.after["_sync"]["op_id"] == res[0]["op_id"]
    assert price.after["_sync"]["device_id"] == "dev-1"
    listed = {e["action"] for e in client.get("/audit", headers=shop.owner).json()["entries"]}
    assert {"product.created", "product.price_changed", "stock.adjusted"} <= listed


# ── R1-16: pull scoping, redaction, bounded limit ────────────────────────────


def test_pull_is_scoped_by_permission_and_branch_and_redacts_cost(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    sid = client.post("/suppliers", headers=shop.owner, json={"name": "Sup"}).json()["id"]
    receipt = client.post("/goods-receipts", headers=shop.owner, json={
        "supplier_id": sid, "lines": [{"product_id": pid, "qty_minor": 10, "unit_cost_minor": 700}],
    })
    assert receipt.status_code == 200, receipt.text  # REST sets the product's last cost
    cashier, _ = shop.employee("c1", "cashier")
    keeper, _ = shop.employee("k1", "stock_keeper")
    _, sale = sale_ops(shop.branch, pid)
    assert set(outcomes(shop.push(cashier, *sale))) == {("applied", None)}
    bill = op("supplier_ledger", {"supplier_id": sid, "type": "bill", "amount_minor": 7000})
    assert outcomes(shop.push(shop.owner, bill)) == [("applied", None)]
    b2 = shop.second_branch()
    c2, _ = shop.employee("c2", "cashier", branch_id=b2)

    def tables(page: dict) -> set[str]:
        return {c["table"] for c in page["changes"]}

    owner_p, cash_p, keep_p, c2_p = (shop.pull(h) for h in (shop.owner, cashier, keeper, c2))
    assert owner_p["watermark"] == cash_p["watermark"] == keep_p["watermark"] == c2_p["watermark"]
    assert {"sales", "sale_lines", "payments", "stock_movements", "supplier_ledger"} <= tables(
        owner_p
    )
    assert "supplier_ledger" not in tables(cash_p) and "sale_lines" in tables(cash_p)
    assert not {"sales", "sale_lines", "payments", "supplier_ledger"} & tables(keep_p)
    assert not {"sales", "sale_lines", "payments", "stock_movements"} & tables(c2_p)
    assert "products" in tables(c2_p)

    def line(page: dict) -> dict:
        return next(c for c in page["changes"] if c["table"] == "sale_lines")["data"]

    assert line(owner_p)["unit_cost_minor"] == 700  # server-derived cost snapshot
    assert "unit_cost_minor" not in line(cash_p)  # omitted, so the device keeps its own


def test_pull_limit_is_bounded_and_pages_monotonically(client: TestClient) -> None:
    shop = Shop(client)
    for i in range(3):
        shop.product(f"L{i}")
    for params in ({"limit": 0}, {"limit": 1001}, {"limit": -1}, {"since": -1}):
        r = client.get("/sync/pull", headers=shop.owner, params=params)
        assert r.status_code == 422 and r.json()["error"]["code"] == "REQUEST_INVALID"
    seen: list[tuple[str, str]] = []
    since = 0
    while True:
        page = shop.pull(shop.owner, since=since, limit=1)
        if not page["changes"]:
            break
        assert page["watermark"] == page["changes"][0]["seq"]
        seen.append((page["changes"][0]["table"], page["changes"][0]["row_id"]))
        since = page["watermark"]
    assert len(seen) == len(set(seen))
    assert sum(table == "products" for table, _ in seen) == 3  # after the built-in units


# ── R1-104 (REST side): DTO bounds give a coded 422, never a DB 500 ─────────


def test_rest_inputs_are_bounded_to_their_columns(client: TestClient) -> None:
    shop = Shop(client)
    unit = shop.units["piece"]
    long_name = client.post("/products", headers=shop.owner, json={
        "sku": "A", "name": "x" * 201, "unit_id": unit, "sell_price_minor": 1})
    assert long_name.status_code == 422
    assert long_name.json()["error"]["code"] == "REQUEST_INVALID"
    huge = client.post("/products", headers=shop.owner, json={
        "sku": "A", "name": "x", "unit_id": unit, "sell_price_minor": 2**53})
    assert huge.status_code == 422
    login = client.post("/auth/login", json={"username": "owner", "password": PW,
                                             "device_id": "d" * 129})
    assert login.status_code == 422 and login.json()["error"]["code"] == "REQUEST_INVALID"
    envelope = client.post("/sync/push", headers=shop.owner, json={"device_id": "d" * 129, "ops": []})
    assert envelope.status_code == 422


def test_large_amounts_fit(client: TestClient) -> None:
    # Over 21.5 million AFN in minor units: past a 32-bit integer.
    shop = Shop(client)
    r = client.post("/products", headers=shop.owner, json={
        "sku": "BIG", "name": "Generator", "unit_id": shop.units["piece"],
        "sell_price_minor": 2_500_000_000})
    assert r.status_code == 200, r.text
    _, ops = sale_ops(shop.branch, shop.product(), price=2_600_000_000, qty=1)
    assert outcomes(shop.push(shop.owner, *ops)) == [("applied", None)] * 4


def test_read_fields_are_real_business_columns() -> None:
    for table, fields in READ_FIELDS.items():
        cols = set(sync_service_module._MODELS[table].__table__.columns.keys())
        assert set(fields) <= cols, table


# ── failure paths: races and infrastructure errors never lose or double-apply ──


def test_a_race_on_the_same_op_replays_the_winner(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    from sqlalchemy.orm import Session

    shop = Shop(client)
    pid = shop.product()
    mv = op("stock_movements", {"product_id": pid, "branch_id": shop.branch, "qty_delta": 3,
                                "reason": "purchase"})
    first = shop.push(shop.owner, mv)
    real_get = Session.get
    hidden: set[str] = set()

    def racing_get(self: Session, entity: Any, ident: Any, **kw: Any) -> Any:
        # The first look misses the concurrent winner's rows (not yet committed).
        name = getattr(entity, "__tablename__", "")
        if name in ("processed_ops", "stock_movements") and f"{name}:{ident}" not in hidden:
            hidden.add(f"{name}:{ident}")
            return None
        return real_get(self, entity, ident, **kw)

    monkeypatch.setattr(Session, "get", racing_get)
    again = shop.push(shop.owner, mv)
    monkeypatch.undo()
    assert again == first
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["on_hand"] == 3


def test_unexpected_errors_reject_without_caching(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    shop = Shop(client)
    pid = shop.product()
    mv = op("stock_movements", {"product_id": pid, "branch_id": shop.branch, "qty_delta": 2,
                                "reason": "purchase"})

    def boom(*_a: Any, **_k: Any) -> Any:
        raise RuntimeError("unexpected")

    monkeypatch.setattr(sync_service_module, "plan_op", boom)
    assert outcomes(shop.push(shop.owner, mv)) == [("rejected", "ROW_INVALID")]
    monkeypatch.undo()
    assert outcomes(shop.push(shop.owner, mv)) == [("applied", None)]


def test_a_database_outage_fails_the_request_so_nothing_is_lost(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    from sqlalchemy.exc import OperationalError

    shop = Shop(client)
    pid = shop.product()
    mv = {"product_id": pid, "branch_id": shop.branch, "reason": "purchase"}
    good, later = op("stock_movements", {**mv, "qty_delta": 1}), op("stock_movements", {**mv, "qty_delta": 2})
    real_plan = sync_service_module.plan_op
    calls = {"n": 0}

    def flaky(op_in: Any, **kw: Any) -> Any:
        calls["n"] += 1
        if calls["n"] == 2:
            raise OperationalError("SELECT 1", {}, Exception("database is locked"))
        return real_plan(op_in, **kw)

    monkeypatch.setattr(sync_service_module, "plan_op", flaky)
    r = client.post("/sync/push", headers=shop.owner, json={"device_id": "d", "ops": [good, later]})
    assert r.status_code == 500 and r.json()["error"]["code"] == "SYNC_UNAVAILABLE"
    monkeypatch.undo()
    # The client re-sends both: the op applied before the outage replays, the other applies once.
    assert outcomes(shop.push(shop.owner, good, later)) == [("applied", None)] * 2
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["on_hand"] == 3


# ── follow-up review: money needs the sale's lines; op_id ownership; limits ──


def test_payments_and_charges_wait_for_the_sales_lines(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    cashier, _ = shop.employee("c1", "cashier")
    cid = _uuid()
    shop.push(shop.owner, op("customers", {"name": "C", "credit_limit_minor": 1000}, row_id=cid))
    _, credit = sale_ops(shop.branch, pid, customer_id=cid, cash=2000)
    header, line, move, payment, charge = credit
    early = shop.push(cashier, header, payment, charge)
    assert outcomes(early) == [("applied", None)] + [("rejected", "SALE_LINES_NOT_FOUND")] * 2
    # The early rejections were not recorded: once the lines arrive, the same ops apply.
    assert set(outcomes(shop.push(cashier, line, move, payment, charge))) == {("applied", None)}
    # A header with no lines can never carry a debt, whatever total it claims.
    _, fake = sale_ops(shop.branch, pid, customer_id=cid, price=50_000_000, qty=1)
    assert outcomes(shop.push(cashier, fake[0], fake[-1])) == [
        ("applied", None), ("rejected", "SALE_LINES_NOT_FOUND"),
    ]
    balance = client.get(f"/customers/{cid}", headers=shop.owner).json()["balance_minor"]
    assert balance == 10000 - 2000


def test_payments_never_exceed_the_sale_total(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    cashier, _ = shop.employee("c1", "cashier")
    _, ops = sale_ops(shop.branch, pid)  # total 10000, paid 10000
    header, line, move, payment = ops
    payment["data"].update(amount_minor=50_000_000, tendered_minor=50_000_000)
    assert outcomes(shop.push(cashier, header, line, move, payment)) == [
        ("applied", None), ("applied", None), ("applied", None),
        ("rejected", "SYNC_REF_MISMATCH"),
    ]
    # Nor does a sale header claim more paid than its total.
    _, ops = sale_ops(shop.branch, pid)
    ops[0]["data"].update(number="INV-20260912-0002", paid_minor=50_000_000)
    assert outcomes(shop.push(cashier, ops[0])) == [("rejected", "SALE_OVERPAID")]


def test_another_users_op_id_cannot_decide_this_users_op(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    cashier, _ = shop.employee("c1", "cashier")
    keeper, _ = shop.employee("k1", "stock_keeper")
    _, ops = sale_ops(shop.branch, pid)
    # The keeper pushes junk under the cashier's op_id first: a recorded failure...
    junk = {**ops[0], "data": {"bogus": 1}}
    assert outcomes(shop.push(keeper, junk)) == [("rejected", "SYNC_FIELD_NOT_ALLOWED")]
    # ...that does not decide the cashier's real op.
    assert set(outcomes(shop.push(cashier, *ops))) == {("applied", None)}
    # An op_id already applied for another user is spent.
    seed = op("units", {"name": "piece", "decimal_places": 0})
    assert outcomes(shop.push(keeper, seed)) == [("applied", None)]
    taken = {**op("customers", {"name": "X"}), "op_id": seed["op_id"]}
    assert outcomes(shop.push(cashier, taken)) == [("rejected", "SYNC_OP_ID_TAKEN")]


def test_a_push_carries_at_most_500_ops(client: TestClient) -> None:
    shop = Shop(client)
    ops = [op("units", {"name": "piece", "decimal_places": 0}) for _ in range(501)]
    r = client.post("/sync/push", headers=shop.owner, json={"device_id": "d", "ops": ops})
    assert r.status_code == 422 and r.json()["error"]["code"] == "REQUEST_INVALID"


def _numbered(ops: list[dict], number: str) -> list[dict]:
    ops[0]["data"]["number"] = number
    return ops


def test_selling_under_the_catalog_price_is_a_managers_discount(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.employee("c1", "cashier")
    manager, _ = shop.employee("m1", "manager")
    pid = shop.product()  # sells at 5000
    _, ops = sale_ops(shop.branch, pid, price=4000)
    assert outcomes(shop.push(cashier, *ops[:2])) == [("applied", None), ("rejected", "ACCESS_DENIED")]
    _, ops = sale_ops(shop.branch, pid, price=4000)
    ops = _numbered(ops, "INV-20260912-0002")
    assert outcomes(shop.push(manager, *ops)) == [("applied", None)] * 4


def test_an_offline_till_may_still_sell_at_a_recent_price(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.employee("c1", "cashier")
    pid = shop.product()  # sells at 5000
    raised = op("products", {"name": "Tea", "sell_price_minor": 6000}, row_id=pid, kind="update",
                base_version=1)
    assert outcomes(shop.push(shop.owner, raised)) == [("applied", None)]
    # The till had not pulled the new price yet: 5000 was the price a moment ago.
    _, ops = sale_ops(shop.branch, pid, price=5000)
    assert outcomes(shop.push(cashier, *ops)) == [("applied", None)] * 4
    # A price the product never had is still a discount.
    _, ops = sale_ops(shop.branch, pid, price=4500)
    ops = _numbered(ops, "INV-20260912-0002")
    assert outcomes(shop.push(cashier, *ops[:2])) == [("applied", None), ("rejected", "ACCESS_DENIED")]


def test_credit_limits_change_through_sync_by_a_manager(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.employee("c1", "cashier")
    cid = _uuid()
    new = op("customers", {"name": "Ahmad", "credit_limit_minor": 0, "currency": "AFN"}, row_id=cid)
    assert outcomes(shop.push(cashier, new)) == [("applied", None)]

    def edit(data: dict[str, Any], version: int) -> dict[str, Any]:
        return op("customers", data, row_id=cid, kind="update", base_version=version)

    # A cashier may correct the name, not grant credit.
    res = shop.push(cashier, edit({"credit_limit_minor": 500000}, 1), edit({"name": "Ahmad K."}, 1))
    assert outcomes(res) == [("rejected", "ACCESS_DENIED"), ("applied", None)]
    res = shop.push(
        shop.owner, edit({"credit_limit_minor": 500000}, 2), edit({"credit_limit_minor": None}, 2)
    )
    assert outcomes(res) == [("applied", None), ("conflict", "CUSTOMERS_VERSION_CONFLICT")]


def test_the_pushed_unit_cost_is_ignored(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product()
    cashier, _ = shop.employee("c1", "cashier")
    _, ops = sale_ops(shop.branch, pid)
    ops[1]["data"]["unit_cost_minor"] = -700  # a bad local cost from an old receive screen
    assert set(outcomes(shop.push(cashier, *ops))) == {("applied", None)}
    line = next(c for c in shop.pull(shop.owner)["changes"] if c["table"] == "sale_lines")
    assert line["data"]["unit_cost_minor"] == 0  # the server's cost snapshot (no cost yet)
