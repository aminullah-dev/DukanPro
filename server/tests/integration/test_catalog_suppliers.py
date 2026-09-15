"""Theme 7c: supplier payments and catalog integrity.

A supplier is paid (money out, purchase.cost), never more than owed, and cash
paid from a till's shift comes off its drawer. An untracked product moves no
stock on any path. A barcode is unique among live barcodes and can be removed,
and a removal reaches devices. A product's track-stock flag is editable and
synced; a SKU two offline tills both used is kept and flagged."""

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

    def product(self, sku: str, *, track: bool = True, barcodes: list[str] | None = None) -> str:
        r = self.client.post("/products", headers=self.owner, json={
            "sku": sku, "name": sku, "unit_id": PIECE, "sell_price_minor": 5000,
            "track_stock": track, "barcodes": barcodes or [],
        })
        assert r.status_code == 200, r.text
        pid: str = r.json()["id"]
        return pid

    def supplier_owed(self, amount_minor: int) -> str:
        """A supplier the shop owes amount_minor: a receipt of 10 at a cost."""
        supplier: str = self.client.post(
            "/suppliers", headers=self.owner, json={"name": "Wholesaler"}
        ).json()["id"]
        r = self.client.post("/goods-receipts", headers=self.owner, json={
            "supplier_id": supplier,
            "lines": [{"product_id": self.product("R" + _uuid()[:6]), "qty_minor": 10,
                       "unit_cost_minor": amount_minor // 10}],
        })
        assert r.status_code == 200, r.text
        return supplier

    def user(self, name: str, role: str) -> dict[str, str]:
        r = self.client.post("/users", headers=self.owner, json={
            "username": name, "password": PW, "display_name": name, "role_name": role,
        })
        assert r.status_code == 200, r.text
        tokens = self.client.post(
            "/auth/login", json={"username": name, "password": PW}
        ).json()["tokens"]
        return {"Authorization": f"Bearer {tokens['access_token']}"}

    def push(self, headers: dict[str, str], *ops: dict[str, Any]) -> list[tuple[str, Any]]:
        r = self.client.post(
            "/sync/push", headers=headers, json={"device_id": "dev-1", "ops": list(ops)}
        )
        assert r.status_code == 200, r.text
        return [(x["outcome"], x.get("code")) for x in r.json()["results"]]

    def feed(self, table: str) -> list[dict[str, Any]]:
        pull = self.client.get("/sync/pull", headers=self.owner, params={"since": 0}).json()
        return [c for c in pull["changes"] if c["table"] == table]

    def last_audit(self, action: str) -> dict[str, Any]:
        entries = self.client.get(f"/audit?action={action}", headers=self.owner).json()["entries"]
        after: dict[str, Any] = entries[0]["after"]
        return after


def test_a_supplier_is_paid_within_what_is_owed(client: TestClient) -> None:
    shop = Shop(client)
    supplier = shop.supplier_owed(4000)
    shift = client.post("/shifts", headers=shop.owner, json={"opening_float_minor": 10000}).json()
    pay = f"/suppliers/{supplier}/payments"
    assert _code(client.post(pay, headers=shop.user("k1", "stock_keeper"), json={
        "amount_minor": 1000,
    })) == (403, "ACCESS_DENIED")
    assert _code(client.post(pay, headers=shop.owner, json={"amount_minor": 5000})) == (
        409, "SUPPLIER_OVERPAYMENT"
    )
    assert _code(client.post(pay, headers=shop.owner, json={"amount_minor": 0})) == (
        422, "SUPPLIER_PAYMENT_INVALID"
    )
    r = client.post(pay, headers=shop.owner, json={
        "amount_minor": 1500, "method": "cash", "shift_id": shift["id"],
    })
    assert r.status_code == 200, r.text
    assert r.json()["balance_minor"] == 2500
    # The cash came out of the drawer.
    closed = client.post(f"/shifts/{shift['id']}/close", headers=shop.owner,
                         json={"counted_cash_minor": 8500}).json()
    assert (closed["expected_cash_minor"], closed["variance_minor"]) == (8500, 0)


def test_a_device_pays_a_supplier_and_an_overpayment_is_flagged(client: TestClient) -> None:
    shop = Shop(client)
    supplier = shop.supplier_owed(4000)

    def paid(amount: int) -> dict[str, Any]:
        return _op("supplier_ledger", {
            "supplier_id": supplier, "type": "payment", "amount_minor": amount,
            "currency": "AFN", "method": "cash",
        })

    assert shop.push(shop.owner, paid(1500)) == [("applied", None)]
    assert shop.last_audit("supplier.payment_recorded")["overpaid"] is False
    # Another till paid the rest meanwhile: both payments stand, the second flagged.
    assert shop.push(shop.owner, paid(4000)) == [("applied", None)]
    assert shop.last_audit("supplier.payment_recorded")["overpaid"] is True
    balances = {s["id"]: s["balance_minor"] for s in client.get("/suppliers", headers=shop.owner).json()}
    assert balances[supplier] == 4000 - 1500 - 4000


def test_an_untracked_product_moves_no_stock_on_any_path(client: TestClient) -> None:
    shop = Shop(client)
    service = shop.product("SV", track=False)
    r = client.post("/goods-receipts", headers=shop.owner, json={
        "lines": [{"product_id": service, "qty_minor": 5, "unit_cost_minor": 300}],
    })
    assert r.status_code == 200, r.text
    assert client.get(f"/products/{service}", headers=shop.owner).json()["on_hand"] == 0
    branch = client.get("/auth/me", headers=shop.owner).json()["default_branch_id"]
    for data in (
        {"product_id": service, "branch_id": branch, "qty_delta": 5, "reason": "purchase"},
        {"product_id": service, "branch_id": branch, "qty_delta": -1, "reason": "sale",
         "ref_type": "sale", "ref_id": _uuid()},
    ):
        assert shop.push(shop.owner, _op("stock_movements", data)) == [
            ("rejected", "PRODUCT_NOT_STOCK_TRACKED")
        ]


def test_a_barcode_is_unique_among_live_barcodes_and_can_be_removed(client: TestClient) -> None:
    shop = Shop(client)
    soap = shop.product("S1", barcodes=["111"])
    milk = shop.product("M1")
    add = f"/products/{milk}/barcodes"
    assert _code(client.post(add, headers=shop.owner, json={"code": "111"})) == (
        409, "BARCODE_DUPLICATE"
    )
    # A till offline gave the code to milk as well: refused, a scan names one item.
    offline = _op("barcodes", {"product_id": milk, "code": "111", "symbology": "ean13"})
    assert shop.push(shop.owner, offline) == [("rejected", "BARCODE_DUPLICATE")]
    r = client.delete(f"/products/{soap}/barcodes/111", headers=shop.owner)
    assert r.status_code == 200 and r.json()["barcodes"] == []
    assert client.post(add, headers=shop.owner, json={"code": "111"}).status_code == 200
    removed = [c for c in shop.feed("barcodes") if c["data"]["product_id"] == soap]
    assert removed[-1]["data"]["deleted_at"] is not None
    # A till takes it off milk: an edit of the barcode row.
    row = [c for c in shop.feed("barcodes") if c["data"]["product_id"] == milk][-1]
    edit = _op("barcodes", {"deleted": True}, row_id=row["row_id"], kind="update",
               base_version=row["data"]["version"])
    assert shop.push(shop.owner, edit) == [("applied", None)]
    assert client.get(f"/products/{milk}", headers=shop.owner).json()["barcodes"] == []


def test_track_stock_is_editable_and_synced(client: TestClient) -> None:
    shop = Shop(client)
    pid = shop.product("T1")
    r = client.patch(f"/products/{pid}", headers=shop.owner, json={"track_stock": False})
    assert r.status_code == 200 and r.json()["track_stock"] is False
    edit = _op("products", {"track_stock": True}, row_id=pid, kind="update",
               base_version=r.json()["version"])
    assert shop.push(shop.owner, edit) == [("applied", None)]
    assert client.get(f"/products/{pid}", headers=shop.owner).json()["track_stock"] is True


def test_a_sku_two_offline_tills_used_is_kept_and_flagged(client: TestClient) -> None:
    shop = Shop(client)
    shop.product("S1")
    twin = _op("products", {
        "sku": "S1", "name": "Soap too", "unit_id": PIECE, "sell_price_minor": 5000,
        "sell_currency": "AFN", "track_stock": True, "is_active": True,
    })
    assert shop.push(shop.owner, twin) == [("applied", None)]
    assert shop.last_audit("product.created")["sku_taken"] is True
