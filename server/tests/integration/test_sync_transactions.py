"""A device transaction's ledger rows reach the server together or not at all
(docs/sync-protocol.md, "Device transactions"). Its master edits still apply one
at a time, and ops from older apps (no tx_id) apply one at a time as before."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"
ABORTED = "SYNC_TX_ABORTED"


def _uuid() -> str:
    return str(uuid.uuid4())


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

    def on_hand(self, pid: str) -> int:
        return int(self.client.get(f"/products/{pid}", headers=self.owner).json()["on_hand"])

    def sale_exists(self, sale_id: str) -> bool:
        return self.client.get(f"/sales/{sale_id}", headers=self.owner).status_code == 200

    def push(self, *ops: dict[str, Any]) -> list[tuple[str, Any]]:
        r = self.client.post(
            "/sync/push", headers=self.owner, json={"device_id": "dev-1", "ops": list(ops)}
        )
        assert r.status_code == 200, r.text
        return [(x["outcome"], x.get("code")) for x in r.json()["results"]]


def _op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, tx: str | None = None,
    op: str = "insert", base_version: int | None = None,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": op, "data": data,
    }
    if tx is not None:
        body["tx_id"] = tx
    if base_version is not None:
        body["base_version"] = base_version
    return body


def _sale_ops(shop: Shop, pid: str, *, number: str, tx: str | None) -> list[dict[str, Any]]:
    """A cash sale of one soap, as a till records it: header, line, stock, payment."""
    sale = _uuid()
    return [
        _op("sales", {
            "number": number, "branch_id": shop.branch, "shift_id": None, "customer_id": None,
            "status": "settled", "currency": "AFN", "discount_minor": 0, "subtotal_minor": 5000,
            "tax_minor": 0, "total_minor": 5000, "paid_minor": 5000, "change_minor": 0,
        }, row_id=sale, tx=tx),
        _op("sale_lines", {
            "sale_id": sale, "product_id": pid, "name": "Soap", "qty_minor": 1,
            "decimal_places": 0, "unit_price_minor": 5000, "unit_cost_minor": 0,
            "line_total_minor": 5000, "currency": "AFN",
        }, tx=tx),
        _op("stock_movements", {
            "product_id": pid, "branch_id": shop.branch, "qty_delta": -1, "reason": "sale",
            "ref_type": "sale", "ref_id": sale,
        }, tx=tx),
        _op("payments", {
            "sale_id": sale, "method": "cash", "amount_minor": 5000, "currency": "AFN",
            "tendered_minor": 5000, "change_minor": 0,
        }, tx=tx),
    ]


def test_a_sale_sent_as_one_transaction_applies_whole(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    ops = _sale_ops(shop, pid, number="INV-T-1", tx=_uuid())
    assert shop.push(*ops) == [("applied", None)] * 4
    assert shop.sale_exists(ops[0]["row_id"])
    assert shop.on_hand(pid) == 9


def test_a_sale_whose_payment_is_refused_leaves_nothing_behind(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    ops = _sale_ops(shop, pid, number="INV-T-2", tx=_uuid())
    ops[3]["data"]["currency"] = "USD"  # a payment this shop refuses for good
    first = shop.push(*ops)
    assert first[3][0] == "rejected" and first[3][1] not in (None, ABORTED), first
    assert first[:3] == [("rejected", ABORTED)] * 3
    assert not shop.sale_exists(ops[0]["row_id"])
    assert shop.on_hand(pid) == 10
    assert shop.push(*ops) == first  # recorded: the same answers again


def test_ops_from_an_older_app_apply_one_at_a_time(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    ops = _sale_ops(shop, pid, number="INV-T-3", tx=None)
    ops[3]["data"]["currency"] = "USD"
    result = shop.push(*ops)
    assert result[:3] == [("applied", None)] * 3
    assert result[3][0] == "rejected"


def test_a_transaction_waiting_on_a_row_is_sent_again_whole(client: TestClient) -> None:
    shop = Shop(client)
    pid = _uuid()  # a product this server has not heard of yet
    ops = _sale_ops(shop, pid, number="INV-T-4", tx=_uuid())
    first = shop.push(*ops)
    codes = {code for _, code in first}
    assert {outcome for outcome, _ in first} == {"rejected"}
    assert len(codes) == 1 and next(iter(codes)).endswith("_NOT_FOUND"), first
    assert not shop.sale_exists(ops[0]["row_id"])
    product = _op("products", {
        "sku": "S" + _uuid()[:8], "name": "Soap", "unit_id": PIECE, "category_id": None,
        "sell_price_minor": 5000, "sell_currency": "AFN", "cost_minor": None,
        "cost_currency": None, "track_stock": True, "is_active": True,
    }, row_id=pid)
    assert shop.push(product) == [("applied", None)]
    assert shop.push(*ops) == [("applied", None)] * 4


def test_a_lost_master_edit_does_not_undo_the_ledger_rows_beside_it(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product(stock=10)
    r = client.patch(f"/products/{pid}", headers=shop.owner, json={"name": "Soap bar"})
    assert r.status_code == 200, r.text
    stale = int(client.get(f"/products/{pid}", headers=shop.owner).json()["version"]) - 1
    tx = _uuid()
    moves = [
        _op("stock_movements", {
            "product_id": pid, "branch_id": shop.branch, "qty_delta": qty, "reason": "adjustment",
        }, tx=tx)
        for qty in (5, 2)
    ]
    rename = _op("products", {"name": "Soap (big)"}, row_id=pid, op="update",
                 base_version=stale, tx=tx)
    result = shop.push(rename, *moves)
    assert result[0] == ("conflict", "PRODUCTS_VERSION_CONFLICT")
    assert result[1:] == [("applied", None)] * 2
    assert shop.on_hand(pid) == 17
