"""The change feed: REST writes reach every device the way sync writes do;
post-images carry the row's version; a stale edit gets the server's row back;
offline rows keep their device time; pages are complete; a sale number two
devices share is kept and flagged; a receipt cost syncs as a product update."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import AuditEntryModel

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"
VOID = "/sales/{sale_id}/void"


def _uuid() -> str:
    return str(uuid.uuid4())


class Shop:
    def __init__(self, client: TestClient) -> None:
        self.c = client
        boot = client.post("/auth/bootstrap", json={
            "setup_token": "test-setup-token", "username": "owner", "password": PW,
            "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.h = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
        self.branch: str = boot["user"]["default_branch_id"]

    def push(self, *ops: dict[str, Any]) -> list[dict[str, Any]]:
        r = self.c.post("/sync/push", headers=self.h, json={"device_id": "d1", "ops": list(ops)})
        assert r.status_code == 200, r.text
        return list(r.json()["results"])

    def pull(self, since: int = 0, limit: int = 1000) -> dict[str, Any]:
        r = self.c.get("/sync/pull", headers=self.h, params={"since": since, "limit": limit})
        assert r.status_code == 200, r.text
        return dict(r.json())


def op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, kind: str = "insert",
    base_version: int | None = None, created_at: str | None = None,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": kind, "data": data,
    }
    if base_version is not None:
        body["base_version"] = base_version
    if created_at is not None:
        body["created_at"] = created_at
    return body


def product(sku: str = "P1", price: int = 5000) -> dict[str, Any]:
    return {
        "sku": sku, "name": "Tea", "unit_id": PIECE, "category_id": None,
        "sell_price_minor": price, "sell_currency": "AFN", "cost_minor": None,
        "cost_currency": None, "track_stock": True, "is_active": True,
    }


def test_rest_writes_reach_the_feed(client: TestClient) -> None:
    shop = Shop(client)
    pid = client.post("/products", headers=shop.h, json={
        "sku": "P1", "name": "Soap", "unit_id": PIECE, "sell_price_minor": 5000,
        "barcodes": ["123"],
    }).json()["id"]
    client.post("/stock/adjust", headers=shop.h, json={"product_id": pid, "qty_delta": 10})
    customer = client.post("/customers", headers=shop.h, json={
        "name": "Karim", "credit_limit_minor": 100000,
    }).json()["id"]
    sale = client.post("/sales", headers=shop.h, json={
        "lines": [{"product_id": pid, "qty_minor": 2}], "customer_id": customer,
        "payments": [{"method": "cash", "amount_minor": 5000}],
    })
    assert sale.status_code == 200, sale.text
    voided = client.post(VOID.replace("{sale_id}", sale.json()["id"]), headers=shop.h,
                         json={"reason": "wrong item"})
    assert voided.status_code == 200, voided.text
    edited = client.patch(f"/products/{pid}", headers=shop.h, json={"sell_price_minor": 6000})
    assert edited.json()["version"] == 2

    feed = [(c["table"], c["data"]) for c in shop.pull()["changes"]]
    tables = {t for t, _ in feed}
    assert tables >= {
        "products", "barcodes", "stock_movements", "customers", "sales", "sale_lines",
        "payments", "customer_ledger",
    }
    assert [d for t, d in feed if t == "sales"][-1]["status"] == "voided"
    latest = [d for t, d in feed if t == "products"][-1]
    assert (latest["sell_price_minor"], latest["version"]) == (6000, 2)
    returned = [d["qty_delta"] for t, d in feed if t == "stock_movements" and d["reason"] == "returned"]
    assert returned == [2]


def test_a_stale_edit_gets_the_servers_row_back(client: TestClient) -> None:
    shop = Shop(client)
    pid = _uuid()
    [created] = shop.push(op("products", product(), row_id=pid))
    assert (created["outcome"], created["version"]) == ("applied", 1)
    r = client.patch(f"/products/{pid}", headers=shop.h,
                     json={"sell_price_minor": 6000, "version": 1})
    assert r.json()["version"] == 2
    stale = op("products", {"name": "Tea", "sell_price_minor": 4000}, row_id=pid,
               kind="update", base_version=1)
    [result] = shop.push(stale)
    assert (result["outcome"], result["code"]) == ("conflict", "PRODUCTS_VERSION_CONFLICT")
    assert (result["current"]["sell_price_minor"], result["current"]["version"]) == (6000, 2)
    [again] = shop.push(stale)  # a replay carries the server's row too
    assert again["current"]["version"] == 2
    late = client.patch(f"/products/{pid}", headers=shop.h,
                        json={"sell_price_minor": 7000, "version": 1})
    assert (late.status_code, late.json()["error"]["code"]) == (409, "PRODUCT_VERSION_CONFLICT")


def test_offline_rows_keep_their_device_time(client: TestClient) -> None:
    shop = Shop(client)
    pid = _uuid()
    shop.push(op("products", product(), row_id=pid))
    now = datetime.now(UTC)

    def movement(at: datetime) -> dict[str, Any]:
        return op("stock_movements", {
            "product_id": pid, "branch_id": shop.branch, "qty_delta": 1, "reason": "purchase",
        }, created_at=at.isoformat())

    recent = movement(now - timedelta(days=2))
    stale = movement(now - timedelta(days=100))
    ahead = movement(now + timedelta(hours=1))
    assert [r["outcome"] for r in shop.push(recent, stale, ahead)] == ["applied"] * 3
    times = {
        c["row_id"]: datetime.fromisoformat(c["data"]["occurred_at"])
        for c in shop.pull()["changes"] if c["table"] == "stock_movements"
    }
    assert abs(times[recent["row_id"]] - (now - timedelta(days=2))) < timedelta(seconds=1)
    for far in (stale, ahead):  # outside the window: the server's time
        assert abs(times[far["row_id"]] - now) < timedelta(minutes=1)


def test_pull_pages_are_complete_and_report_the_newest_seq(client: TestClient) -> None:
    shop = Shop(client)
    shop.push(*[op("products", product(sku=f"S{i}"), row_id=_uuid()) for i in range(25)])
    seen: list[int] = []
    since = 0
    while True:
        page = shop.pull(since=since, limit=10)
        seen += [c["seq"] for c in page["changes"]]
        if page["watermark"] == since:
            break
        since = page["watermark"]
    assert seen == sorted(seen) and len(set(seen)) == 25
    assert page["max_seq"] == seen[-1]


def test_a_receipt_cost_syncs_as_a_product_update(client: TestClient) -> None:
    shop = Shop(client)
    pid = _uuid()
    shop.push(op("products", product(), row_id=pid))
    [r] = shop.push(op("products", {"cost_minor": 4000}, row_id=pid, kind="update",
                       base_version=1))
    assert (r["outcome"], r["version"]) == ("applied", 2)
    image = [c["data"] for c in shop.pull()["changes"] if c["table"] == "products"][-1]
    assert (image["cost_minor"], image["cost_currency"], image["version"]) == (4000, "AFN", 2)


def test_a_sale_number_two_devices_share_is_kept_and_flagged(client: TestClient) -> None:
    shop = Shop(client)

    def header() -> dict[str, Any]:
        return op("sales", {
            "number": "INV-20260914-0001", "branch_id": shop.branch, "shift_id": None,
            "customer_id": None, "status": "settled", "currency": "AFN", "discount_minor": 0,
            "subtotal_minor": 0, "tax_minor": 0, "total_minor": 0, "paid_minor": 0,
            "change_minor": 0,
        })

    assert [r["outcome"] for r in shop.push(header(), header())] == ["applied", "applied"]
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        entries = s.scalars(
            select(AuditEntryModel)
            .where(AuditEntryModel.action == "sale.settled")
            .order_by(AuditEntryModel.occurred_at)
        ).all()
    assert [(e.after or {}).get("number_taken") for e in entries] == [None, True]
