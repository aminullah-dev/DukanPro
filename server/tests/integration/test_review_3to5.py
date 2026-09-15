"""Fixes from the adversarial review of themes 3-5.

A sale line's decimal places come from its product's unit; the built-in units
are in the feed; a sale's stock movement waits for a line still on its way, and
the price window counts back from the sale; totals stay within MONEY_MAX; sync
takes only the shop's price currencies, as REST does; drawer cash is never
negative; an unknown route answers in the error contract; a sign-out with a
rotated-out refresh token still ends the session."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

from fastapi.testclient import TestClient
from sqlalchemy import Engine, update
from sqlalchemy.orm import Session

from dukan.domain.catalog import BUILTIN_UNITS
from dukan.domain.sales import line_total_minor
from dukan.infrastructure.db.models import AuditEntryModel, ProductModel
from dukan.shared.limits import MONEY_MAX

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"
KG = "00000000-0000-7000-8000-000000000002"


def _uuid() -> str:
    return str(uuid.uuid4())


def _engine(client: TestClient) -> Engine:
    engine: Engine = client.app.state.engine  # type: ignore[attr-defined]
    return engine


def _boot(client: TestClient) -> tuple[dict[str, str], str, str]:
    boot = client.post("/auth/bootstrap", json={
        "setup_token": "test-setup-token", "username": "owner", "password": PW,
        "display_name": "Owner", "shop_name": "Dukan",
    }).json()
    headers = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}
    return headers, boot["user"]["default_branch_id"], boot["tokens"]["refresh_token"]


def _cashier(client: TestClient, owner: dict[str, str]) -> tuple[dict[str, str], str]:
    r = client.post("/users", headers=owner, json={
        "username": "cash1", "password": PW, "display_name": "Cashier", "role_name": "cashier",
    })
    assert r.status_code == 200, r.text
    tokens = client.post("/auth/login", json={"username": "cash1", "password": PW}).json()
    return {"Authorization": f"Bearer {tokens['tokens']['access_token']}"}, r.json()["id"]


def _op(
    table: str, data: dict[str, Any], *, row_id: str | None = None, kind: str = "insert",
    base_version: int | None = None, at: datetime | None = None,
) -> dict[str, Any]:
    body: dict[str, Any] = {
        "op_id": _uuid(), "table": table, "row_id": row_id or _uuid(), "op": kind, "data": data,
    }
    if base_version is not None:
        body["base_version"] = base_version
    if at is not None:
        body["created_at"] = at.isoformat()
    return body


def _push(client: TestClient, headers: dict[str, str], *ops: dict[str, Any]) -> list[Any]:
    r = client.post("/sync/push", headers=headers, json={"device_id": "dev-1", "ops": list(ops)})
    assert r.status_code == 200, r.text
    return [(x["outcome"], x.get("code")) for x in r.json()["results"]]


def _product(client: TestClient, owner: dict[str, str], unit: str = PIECE, price: int = 5000) -> str:
    pid = _uuid()
    data = {
        "sku": "S" + pid[:6], "name": "Tea", "unit_id": unit, "sell_price_minor": price,
        "sell_currency": "AFN", "track_stock": True, "is_active": True,
    }
    assert _push(client, owner, _op("products", data, row_id=pid)) == [("applied", None)]
    return pid


def _version(client: TestClient, product_id: str) -> int:
    with Session(_engine(client)) as s:
        product = s.get(ProductModel, product_id)
        assert product is not None
        return product.version


def _price_changed(client: TestClient, owner: dict[str, str], pid: str, *, days_ago: int) -> None:
    """50.00 becomes 60.00, recorded `days_ago` days back."""
    change = _op(
        "products", {"sell_price_minor": 6000}, row_id=pid, kind="update",
        base_version=_version(client, pid),
    )
    assert _push(client, owner, change) == [("applied", None)]
    with Session(_engine(client)) as s:
        s.execute(
            update(AuditEntryModel)
            .where(
                AuditEntryModel.action == "product.price_changed",
                AuditEntryModel.entity_id == pid,
            )
            .values(occurred_at=datetime.now(UTC) - timedelta(days=days_ago))
        )
        s.commit()


def _sale_ops(
    branch: str, pid: str, *, qty: int, price: int, places: int | None = 0,
    line_total: int | None = None, at: datetime | None = None,
) -> list[dict[str, Any]]:
    sale_id = _uuid()
    total = line_total_minor(price, qty, places or 0) if line_total is None else line_total
    line: dict[str, Any] = {
        "sale_id": sale_id, "product_id": pid, "name": "Tea", "qty_minor": qty,
        "unit_price_minor": price, "unit_cost_minor": 0, "line_total_minor": total,
        "currency": "AFN",
    }
    if places is not None:
        line["decimal_places"] = places
    header = {
        "number": "INV-" + sale_id[:8], "branch_id": branch, "shift_id": None,
        "customer_id": None, "status": "settled", "currency": "AFN", "discount_minor": 0,
        "subtotal_minor": total, "tax_minor": 0, "total_minor": total, "paid_minor": total,
        "change_minor": 0,
    }
    movement = {
        "product_id": pid, "branch_id": branch, "qty_delta": -qty, "reason": "sale",
        "ref_type": "sale", "ref_id": sale_id,
    }
    payment = {
        "sale_id": sale_id, "method": "cash", "amount_minor": total, "currency": "AFN",
        "tendered_minor": total, "change_minor": 0,
    }
    return [
        _op("sales", header, row_id=sale_id, at=at),
        _op("sale_lines", line, at=at),
        _op("stock_movements", movement, at=at),
        _op("payments", payment, at=at),
    ]


def test_a_sale_line_is_read_in_its_products_unit(client: TestClient) -> None:
    owner, branch, _ = _boot(client)
    tea, rice = _product(client, owner, PIECE, 5000), _product(client, owner, KG, 8000)
    # Tea is sold by the piece: a device that says six decimals is refused.
    got = _push(client, owner, *_sale_ops(branch, tea, qty=1500, price=5000, places=6))
    assert got[1] == ("rejected", "SYNC_FIELD_INVALID")
    # Rice is sold by the kg: 1500 is 1.500 kg (120.00) when the device leaves it out...
    ops = _sale_ops(branch, rice, qty=1500, price=8000, places=None, line_total=12000)
    assert _push(client, owner, *ops) == [("applied", None)] * 4
    # ...and never 1500 whole kg.
    ops = _sale_ops(branch, rice, qty=1500, price=8000, places=None, line_total=8000 * 1500)
    assert _push(client, owner, *ops)[1] == ("rejected", "SYNC_FIELD_INVALID")


def test_the_built_in_units_are_in_the_feed(client: TestClient) -> None:
    owner, _, _ = _boot(client)
    pull = client.get("/sync/pull", headers=owner, params={"since": 0}).json()
    units = {c["row_id"]: c["data"] for c in pull["changes"] if c["table"] == "units"}
    assert {u.id for u in BUILTIN_UNITS} <= set(units)
    assert units[KG]["decimal_places"] == 3


def test_a_sale_movement_waits_for_a_line_still_on_its_way(client: TestClient) -> None:
    owner, branch, _ = _boot(client)
    pid = _product(client, owner)
    stock = {"product_id": pid, "branch_id": branch, "qty_delta": 10, "reason": "adjustment"}
    assert _push(client, owner, _op("stock_movements", stock)) == [("applied", None)]
    _price_changed(client, owner, pid, days_ago=46)
    cashier, cashier_id = _cashier(client, owner)
    # A till that never heard of the change sold at 50.00 today: under the price,
    # and the old price is past the window, so the line waits for a manager.
    ops = _sale_ops(branch, pid, qty=2, price=5000)
    first = _push(client, cashier, *ops)
    assert first[1:3] == [("rejected", "ACCESS_DENIED"), ("rejected", "SALE_LINES_NOT_FOUND")]
    r = client.post(f"/users/{cashier_id}/roles", headers=owner, json={
        "branch_id": branch, "role_name": "manager",
    })
    assert r.status_code == 200, r.text
    # The movement was a retry, not a lasting refusal: it applies with its line.
    assert _push(client, cashier, *ops) == [("applied", None)] * 4
    assert client.get(f"/products/{pid}", headers=owner).json()["on_hand"] == 8


def test_the_price_window_counts_back_from_the_sale(client: TestClient) -> None:
    owner, branch, _ = _boot(client)
    pid = _product(client, owner)
    _price_changed(client, owner, pid, days_ago=46)
    cashier, _ = _cashier(client, owner)
    # Sold 44 days ago, two days after the change, on a till that had not heard of it.
    at = datetime.now(UTC) - timedelta(days=44)
    ops = _sale_ops(branch, pid, qty=1, price=5000, at=at)
    assert _push(client, cashier, *ops) == [("applied", None)] * 4


def test_totals_past_money_max_are_refused(client: TestClient) -> None:
    owner, _, _ = _boot(client)
    pid = client.post("/products", headers=owner, json={
        "sku": "P1", "name": "Soap", "unit_id": PIECE, "sell_price_minor": 52000,
    }).json()["id"]
    customer = client.post("/customers", headers=owner, json={"name": "Karim"}).json()["id"]
    for qty in (10**14, MONEY_MAX):
        r = client.post("/sales", headers=owner, json={
            "lines": [{"product_id": pid, "qty_minor": qty}], "payments": [],
            "customer_id": customer,
        })
        assert (r.status_code, r.json()["error"]["code"]) == (422, "SALE_TOTAL_TOO_LARGE")
    r = client.post("/goods-receipts", headers=owner, json={
        "lines": [{"product_id": pid, "qty_minor": MONEY_MAX, "unit_cost_minor": MONEY_MAX}],
    })
    assert (r.status_code, r.json()["error"]["code"]) == (422, "GRN_TOTAL_TOO_LARGE")


def test_sync_takes_only_the_shops_price_currencies(client: TestClient) -> None:
    owner, _, _ = _boot(client)
    data = {
        "sku": "U1", "name": "Tea", "unit_id": PIECE, "sell_price_minor": 5000,
        "sell_currency": "USD", "track_stock": True, "is_active": True,
    }
    assert _push(client, owner, _op("products", data)) == [("rejected", "PRICE_CURRENCY_INVALID")]
    pid = _product(client, owner)
    moved = _op(
        "products", {"sell_currency": "XYZ"}, row_id=pid, kind="update",
        base_version=_version(client, pid),
    )
    assert _push(client, owner, moved) == [("rejected", "PRICE_CURRENCY_INVALID")]


def test_drawer_cash_is_never_negative(client: TestClient) -> None:
    owner, _, _ = _boot(client)
    r = client.post("/shifts", headers=owner, json={"opening_float_minor": -500000})
    assert (r.status_code, r.json()["error"]["code"]) == (422, "SHIFT_CASH_INVALID")
    shift = client.post("/shifts", headers=owner, json={"opening_float_minor": 0}).json()["id"]
    r = client.post(f"/shifts/{shift}/close", headers=owner, json={"counted_cash_minor": -100})
    assert (r.status_code, r.json()["error"]["code"]) == (422, "SHIFT_CASH_INVALID")


def test_unknown_routes_answer_in_the_error_contract(client: TestClient) -> None:
    r = client.get("/no-such-route")
    assert (r.status_code, r.json()) == (404, {"error": {"code": "NOT_FOUND", "context": {}}})
    r = client.put("/auth/me")
    assert (r.status_code, r.json()["error"]["code"]) == (405, "METHOD_NOT_ALLOWED")


def test_a_sign_out_with_a_rotated_out_token_ends_the_session(client: TestClient) -> None:
    _, _, r1 = _boot(client)
    # A renewal in flight rotates r1 to r2 while the device signs out with r1.
    r2 = client.post("/auth/refresh", json={"refresh_token": r1}).json()["refresh_token"]
    assert client.post("/auth/logout", json={"refresh_token": r1}).status_code < 300
    again = client.post("/auth/refresh", json={"refresh_token": r2})
    assert (again.status_code, again.json()["error"]["code"]) == (401, "REFRESH_INVALID")
