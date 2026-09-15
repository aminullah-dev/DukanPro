"""Review of themes 6-9, sync: an edit made on top of one the server did not take
never overwrites another device's row, a refused barcode's removal settles, a
replay returns its version, and a pull tells the device when to read the feed
again (a restore)."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient
from sqlalchemy import delete
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import ChangeLogModel

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"


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

    def push(self, *ops: dict[str, Any], device: str = "d1") -> list[dict[str, Any]]:
        r = self.c.post("/sync/push", headers=self.h, json={"device_id": device, "ops": list(ops)})
        assert r.status_code == 200, r.text
        return list(r.json()["results"])

    def pull(self, since: int = 0, token: str | None = None) -> dict[str, Any]:
        params: dict[str, Any] = {"since": since, "limit": 1000}
        if token is not None:
            params["since_token"] = token
        r = self.c.get("/sync/pull", headers=self.h, params=params)
        assert r.status_code == 200, r.text
        return dict(r.json())


def op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, kind: str = "insert",
    base_version: int | None = None,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": kind, "data": data,
    }
    if base_version is not None:
        body["base_version"] = base_version
    return body


def product(sku: str, price: int = 5000) -> dict[str, Any]:
    return {
        "sku": sku, "name": "Tea", "unit_id": PIECE, "category_id": None,
        "sell_price_minor": price, "sell_currency": "AFN", "cost_minor": None,
        "cost_currency": None, "track_stock": True, "is_active": True,
    }


def _image(feed: dict[str, Any], row_id: str) -> dict[str, Any]:
    return [c["data"] for c in feed["changes"] if c["row_id"] == row_id][-1]


def test_an_edit_chained_on_a_conflicted_one_conflicts_too(client: TestClient) -> None:
    shop = Shop(client)
    pid = _uuid()
    shop.push(op("products", product("T1", price=10000), row_id=pid))
    a = shop.push(
        op("products", {"sell_price_minor": 15000}, row_id=pid, kind="update", base_version=1),
        device="A",
    )
    assert a[0]["outcome"] == "applied"
    # B, offline since version 1: a rename (local version 2), then a price on top of it.
    rename = op("products", {"name": "Tea (B)"}, row_id=pid, kind="update", base_version=1)
    price = op("products", {"sell_price_minor": 12000}, row_id=pid, kind="update", base_version=2)
    b = shop.push(rename, price, device="B")
    assert [r["outcome"] for r in b] == ["conflict", "conflict"]
    assert b[1]["current"]["sell_price_minor"] == 15000
    assert _image(shop.pull(), pid)["sell_price_minor"] == 15000  # A's price stands
    assert shop.push(price, device="B")[0]["outcome"] == "conflict"  # a replay keeps it


def test_a_removal_of_a_barcode_another_till_removed_is_done(client: TestClient) -> None:
    shop = Shop(client)
    pid, bid = _uuid(), _uuid()
    shop.push(
        op("products", product("B1"), row_id=pid),
        op("barcodes", {"product_id": pid, "code": "4006381333931", "symbology": "ean13"}, row_id=bid),
    )
    first = shop.push(op("barcodes", {"deleted": True}, row_id=bid, kind="update", base_version=1))
    assert first[0]["outcome"] == "applied"
    second = op("barcodes", {"deleted": True}, row_id=bid, kind="update", base_version=1)
    assert shop.push(second, device="d2")[0]["outcome"] == "applied"
    assert shop.push(second, device="d2")[0]["outcome"] == "applied"  # replayed, not re-sent forever
    removals = [c for c in shop.pull()["changes"] if c["row_id"] == bid and c["op"] == "update"]
    assert len(removals) == 1  # the second removal wrote nothing
    assert "created_at" in removals[0]["data"]


def test_a_removal_made_after_a_refused_barcode_takes_its_verdict(client: TestClient) -> None:
    shop = Shop(client)
    rice, flour, kept, refused = _uuid(), _uuid(), _uuid(), _uuid()
    shop.push(
        op("products", product("R1"), row_id=rice),
        op("products", product("F1"), row_id=flour),
        op("barcodes", {"product_id": rice, "code": "111", "symbology": "code128"}, row_id=kept),
    )
    results = shop.push(
        op("barcodes", {"product_id": flour, "code": "111", "symbology": "code128"}, row_id=refused),
        op("barcodes", {"deleted": True}, row_id=refused, kind="update", base_version=1),
        device="B",
    )
    assert [(r["outcome"], r["code"]) for r in results] == [("rejected", "BARCODE_DUPLICATE")] * 2


def test_a_replayed_master_update_returns_its_version(client: TestClient) -> None:
    shop = Shop(client)
    pid = _uuid()
    shop.push(op("products", product("V1"), row_id=pid))
    edit = op("products", {"name": "Green tea"}, row_id=pid, kind="update", base_version=1)
    first = shop.push(edit)[0]
    again = shop.push(edit)[0]
    assert (first["outcome"], first["version"]) == ("applied", 2)
    assert again == first


def test_a_pull_resets_when_the_feed_no_longer_holds_the_cursor(client: TestClient) -> None:
    shop = Shop(client)
    shop.push(*[op("products", product(f"A{i}")) for i in range(5)])
    feed = shop.pull()
    cursor, token = feed["watermark"], feed["watermark_token"]
    assert token and feed["scope"] and feed["reset"] is False
    assert shop.pull(cursor, token)["reset"] is False

    # Restored from an older backup, then written to: the feed grows back past the
    # cursor, and the seq the device stopped at now holds another change.
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        s.execute(delete(ChangeLogModel).where(ChangeLogModel.seq > cursor - 3))
        s.commit()
    later = [_uuid() for _ in range(8)]
    shop.push(*[op("products", product(f"B{i}"), row_id=pid) for i, pid in enumerate(later)])
    assert shop.pull()["max_seq"] > cursor
    restored = shop.pull(cursor, token)
    assert (restored["reset"], restored["changes"], restored["watermark"]) == (True, [], 0)
    again = {c["row_id"] for c in shop.pull()["changes"]}
    assert set(later) <= again
    assert shop.pull(cursor, "not-a-token")["reset"] is True


def test_the_pull_scope_changes_when_a_role_is_granted(client: TestClient) -> None:
    shop = Shop(client)
    made = client.post("/users", headers=shop.h, json={
        "username": "c1", "password": PW, "display_name": "Cashier", "role_name": "cashier",
        "branch_id": shop.branch,
    })
    assert made.status_code in (200, 201), made.text
    login = client.post("/auth/login", json={"username": "c1", "password": PW, "device_id": "t1"})
    cashier = {"Authorization": f"Bearer {login.json()['tokens']['access_token']}"}

    def scope() -> str:
        r = client.get("/sync/pull", headers=cashier, params={"since": 0})
        assert r.status_code == 200, r.text
        return str(r.json()["scope"])

    before = scope()
    assert before == scope()  # the same scope, pull after pull
    granted = client.post(
        f"/users/{made.json()['id']}/roles", headers=shop.h,
        json={"branch_id": shop.branch, "role_name": "manager"},
    )
    assert granted.status_code in (200, 201), granted.text
    assert scope() != before  # the device reads the feed again for what the old scope hid
