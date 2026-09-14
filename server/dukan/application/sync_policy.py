"""Sync apply policy: the application-layer gate every pushed op passes before
infrastructure writes it (docs/sync-protocol.md, "Push validation").

Per op it validates the envelope; cleans `data` against a strict per-table
allow-list (types, lengths, ranges, enums, currency; server-owned columns are
never accepted); authorizes the AUTHENTICATED pushing actor in the row's branch
(branch rows) or the active branch (shop-wide rows); checks parents and domain
invariants; and returns an ApplyPlan: the exact column values to write plus the
audit intent. Pure: domain + shared + the access guard only. Lookups go through
the SyncReader port, implemented in infrastructure.
"""

from __future__ import annotations

import re
from collections.abc import Callable, Iterable, Mapping
from dataclasses import dataclass, replace
from datetime import UTC, datetime, timedelta
from typing import Any, Protocol

from dukan.application.access import require_any_permission, require_permission
from dukan.application.sync import OpInput
from dukan.domain.branches import assert_branch_active
from dukan.domain.customers import (
    LedgerEntryType,
    assert_not_overpaid,
    assert_within_credit_limit,
)
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.inventory import StockReason, adjust_stock
from dukan.domain.purchasing import SupplierEntryType
from dukan.domain.sales import (
    PaymentMethod,
    assert_discount_valid,
    assert_payment_valid,
    assert_sale_not_overpaid,
    assert_shift_cash_valid,
    line_total_minor,
)
from dukan.shared.errors import ConflictError, NotFoundError, PermissionDeniedError, ValidationError
from dukan.shared.limits import INT32_MAX, INT32_MIN, MONEY_MAX

POLICY = PermissionPolicy()
PULL_LIMIT_MAX = 1000
PUSH_OPS_MAX = 500  # ops per /sync/push request (the client sends batches of 200)
DEFAULT_CURRENCY = "AFN"
# A device sells at the prices it last pulled: for up to the app's 30-day offline
# unlock window, plus time to push. A sale line at a price the product had within
# this window is not a discount.
PRICE_DRIFT_WINDOW = timedelta(days=45)

_UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
_CURRENCY = re.compile(r"[A-Z]{3}")

MASTER_TABLES = frozenset(
    {"products", "barcodes", "customers", "suppliers", "units", "categories", "shifts"}
)
LEDGER_TABLES = frozenset(
    {"stock_movements", "sales", "sale_lines", "payments", "customer_ledger", "supplier_ledger"}
)
SYNC_TABLES = MASTER_TABLES | LEDGER_TABLES

# RecordMixin columns: always server-owned, never taken from a pushed payload.
SERVER_OWNED = frozenset(
    {"id", "created_at", "updated_at", "deleted_at", "created_by", "updated_by", "version"}
)

# Business columns per table (+ `version` on master rows): the post-image written
# to change_log, and the only keys a pull ever returns.
READ_FIELDS: dict[str, tuple[str, ...]] = {
    "products": (
        "sku", "name", "unit_id", "category_id", "sell_price_minor", "sell_currency",
        "cost_minor", "cost_currency", "track_stock", "is_active", "version",
    ),
    "barcodes": ("product_id", "code", "symbology", "version"),
    "units": ("name", "decimal_places", "version"),
    "categories": ("name", "parent_id", "version"),
    "customers": ("name", "phone", "credit_limit_minor", "currency", "is_active", "version"),
    "suppliers": ("name", "phone", "currency", "is_active", "version"),
    "stock_movements": (
        "product_id", "branch_id", "qty_delta", "reason", "ref_type", "ref_id", "occurred_at",
    ),
    "sales": (
        "number", "branch_id", "shift_id", "customer_id", "status", "currency",
        "discount_minor", "subtotal_minor", "tax_minor", "total_minor", "paid_minor",
        "change_minor", "occurred_at",
    ),
    "sale_lines": (
        "sale_id", "product_id", "name", "qty_minor", "decimal_places", "unit_price_minor",
        "unit_cost_minor", "line_total_minor", "currency",
    ),
    "payments": (
        "sale_id", "method", "amount_minor", "currency", "tendered_minor", "change_minor",
    ),
    "customer_ledger": (
        "customer_id", "type", "amount_minor", "currency", "ref_type", "ref_id", "occurred_at",
        "shift_id", "method",
    ),
    "supplier_ledger": (
        "supplier_id", "type", "amount_minor", "currency", "ref_type", "ref_id", "occurred_at",
    ),
    "shifts": (
        "branch_id", "user_id", "opened_at", "opening_float_minor", "closed_at",
        "counted_cash_minor", "expected_cash_minor", "variance_minor", "status", "version",
    ),
}

# The fixed unit seed every fresh device records on first use (LocalCatalog.listUnits).
CANONICAL_UNITS = frozenset({("piece", 0), ("kg", 3), ("litre", 3), ("dozen", 0), ("meter", 2)})


class SyncConflict(ConflictError):
    """Concurrency conflict on a master row (stale base_version, or an insert on a
    row that already exists): the `conflict` outcome. Every other AppError raised
    while planning an op is the `rejected` outcome."""


def is_uuid(value: object) -> bool:
    """Canonical lowercase 36-char UUID (any version: tests and legacy data use v4)."""
    return isinstance(value, str) and _UUID.fullmatch(value) is not None


# ── Per-table allow-lists ────────────────────────────────────────────────────


@dataclass(frozen=True, slots=True)
class _Field:
    kind: str  # str | int | bool | uuid | currency | enum | null
    required: bool = False  # insert: must be present; str: must be non-blank when present
    nullable: bool = False
    max_len: int = 0
    lo: int = INT32_MIN
    hi: int = INT32_MAX
    choices: frozenset[str] = frozenset()


def _str(max_len: int, *, required: bool = False, nullable: bool = False) -> _Field:
    return _Field("str", required=required, nullable=nullable, max_len=max_len)


def _int(
    *, lo: int = INT32_MIN, hi: int = INT32_MAX, required: bool = False, nullable: bool = False
) -> _Field:
    return _Field("int", required=required, nullable=nullable, lo=lo, hi=hi)


def _uuid(*, required: bool = False, nullable: bool = False) -> _Field:
    return _Field("uuid", required=required, nullable=nullable)


def _enum(values: Iterable[str], *, required: bool = False, nullable: bool = False) -> _Field:
    return _Field("enum", required=required, nullable=nullable, choices=frozenset(values))


_BOOL = _Field("bool")
_CURRENCY_F = _Field("currency")
_MUST_BE_NULL = _Field("null")  # key tolerated (the app sends it); value must be null

_INSERT: dict[str, dict[str, _Field]] = {
    "products": {
        "sku": _str(64, required=True),
        "name": _str(200, required=True),
        "unit_id": _uuid(required=True),
        "category_id": _MUST_BE_NULL,
        "sell_price_minor": _int(lo=0, hi=MONEY_MAX),
        "sell_currency": _CURRENCY_F,
        "cost_minor": _MUST_BE_NULL,
        "cost_currency": _MUST_BE_NULL,
        "track_stock": _BOOL,
        "is_active": _BOOL,
    },
    "barcodes": {
        "product_id": _uuid(required=True),
        "code": _str(64, required=True),
        "symbology": _str(16),
    },
    "units": {"name": _str(48, required=True), "decimal_places": _int(lo=0, hi=6, required=True)},
    "customers": {
        "name": _str(128, required=True),
        "phone": _str(32, nullable=True),
        "credit_limit_minor": _int(lo=0, hi=MONEY_MAX, nullable=True),
        "currency": _CURRENCY_F,
        "is_active": _BOOL,
    },
    "suppliers": {
        "name": _str(128, required=True),
        "phone": _str(32, nullable=True),
        "currency": _CURRENCY_F,
        "is_active": _BOOL,
    },
    "stock_movements": {
        "product_id": _uuid(required=True),
        "branch_id": _uuid(required=True),
        "qty_delta": _int(lo=-MONEY_MAX, hi=MONEY_MAX, required=True),
        "reason": _enum([r.value for r in StockReason], required=True),
        "ref_type": _enum(["sale"], nullable=True),
        "ref_id": _uuid(nullable=True),
    },
    "sales": {
        "number": _str(32, required=True),
        "branch_id": _uuid(required=True),
        "shift_id": _uuid(nullable=True),  # the seller's own shift
        "customer_id": _uuid(nullable=True),
        "status": _enum(["settled"]),
        "currency": _CURRENCY_F,
        "discount_minor": _int(lo=0, hi=MONEY_MAX),
        "subtotal_minor": _int(lo=0, hi=MONEY_MAX, required=True),
        "tax_minor": _int(lo=0, hi=MONEY_MAX),
        "total_minor": _int(lo=0, hi=MONEY_MAX, required=True),
        "paid_minor": _int(lo=0, hi=MONEY_MAX, required=True),
        "change_minor": _int(lo=0, hi=MONEY_MAX),
    },
    "sale_lines": {
        "sale_id": _uuid(required=True),
        "product_id": _uuid(required=True),
        "name": _str(200, required=True),
        "qty_minor": _int(lo=1, hi=MONEY_MAX, required=True),
        "decimal_places": _int(lo=0, hi=6),
        "unit_price_minor": _int(lo=0, hi=MONEY_MAX, required=True),
        # accepted but ignored: the server re-derives it
        "unit_cost_minor": _int(lo=-MONEY_MAX, hi=MONEY_MAX),
        "line_total_minor": _int(lo=0, hi=MONEY_MAX, required=True),
        "currency": _CURRENCY_F,
    },
    "payments": {
        "sale_id": _uuid(required=True),
        "method": _enum([m.value for m in PaymentMethod], required=True),
        "amount_minor": _int(lo=1, hi=MONEY_MAX, required=True),
        "currency": _CURRENCY_F,
        "tendered_minor": _int(lo=0, hi=MONEY_MAX, nullable=True),
        "change_minor": _int(lo=0, hi=MONEY_MAX, nullable=True),
    },
    "customer_ledger": {
        "customer_id": _uuid(required=True),
        "type": _enum([t.value for t in LedgerEntryType], required=True),
        # Signed: an adjustment (a write-off) lowers the debt with a negative amount.
        "amount_minor": _int(lo=-MONEY_MAX, hi=MONEY_MAX, required=True),
        "currency": _CURRENCY_F,
        "ref_type": _enum(["sale", "manual", "write_off"], nullable=True),
        "ref_id": _uuid(nullable=True),
        # A payment's: the drawer it went into, and how it was paid.
        "shift_id": _uuid(nullable=True),
        "method": _enum(
            [m.value for m in PaymentMethod if m is not PaymentMethod.CREDIT], nullable=True
        ),
    },
    "supplier_ledger": {
        "supplier_id": _uuid(required=True),
        "type": _enum([t.value for t in SupplierEntryType], required=True),
        "amount_minor": _int(lo=1, hi=MONEY_MAX, required=True),
        "currency": _CURRENCY_F,
        "ref_type": _MUST_BE_NULL,
        "ref_id": _MUST_BE_NULL,
    },
    "shifts": {
        "branch_id": _uuid(required=True),
        "user_id": _uuid(required=True),
        "opening_float_minor": _int(lo=0, hi=MONEY_MAX),
        "status": _enum(["open"]),
    },
}

_UPDATE: dict[str, dict[str, _Field]] = {
    "products": {
        "name": _str(200),
        "sell_price_minor": _int(lo=0, hi=MONEY_MAX),
        "sell_currency": _CURRENCY_F,
        "is_active": _BOOL,
        "cost_minor": _int(lo=0, hi=MONEY_MAX),  # a goods receipt's cost, purchase.cost
    },
    "customers": {
        "name": _str(128),
        "phone": _str(32, nullable=True),
        "credit_limit_minor": _int(lo=0, hi=MONEY_MAX, nullable=True),
        "is_active": _BOOL,
    },
    "shifts": {
        "status": _enum(["closed"]),
        "counted_cash_minor": _int(lo=0, hi=MONEY_MAX),
    },
}


def clean_fields(table: str, op: str, data: Mapping[str, Any]) -> dict[str, Any]:
    """Validate `data` against the allow-list for (table, op) and return it.

    Raises ValidationError SYNC_FIELD_NOT_ALLOWED / SYNC_FIELD_REQUIRED /
    SYNC_FIELD_INVALID / MONEY_CURRENCY_INVALID."""
    spec = (_INSERT if op == "insert" else _UPDATE)[table]
    for key in data:
        if key not in spec:
            raise ValidationError(
                "SYNC_FIELD_NOT_ALLOWED", table=table, field=str(key)[:64],
                reason="server_owned" if key in SERVER_OWNED else "unknown",
            )
    out: dict[str, Any] = {}
    for name, f in spec.items():
        if name in data:
            out[name] = _check(table, name, f, data[name])
        elif f.required and op == "insert":
            raise ValidationError("SYNC_FIELD_REQUIRED", table=table, field=name)
    return out


def _check(table: str, name: str, f: _Field, value: Any) -> Any:
    def invalid(reason: str) -> ValidationError:
        return ValidationError("SYNC_FIELD_INVALID", table=table, field=name, reason=reason)

    if value is None:
        if f.nullable or f.kind == "null":
            return None
        raise invalid("null")
    if f.kind == "null":
        raise ValidationError(
            "SYNC_FIELD_NOT_ALLOWED", table=table, field=name, reason="must_be_null"
        )
    if f.kind == "int":
        if type(value) is not int:  # bool is an int subclass; floats are never money
            raise invalid("type")
        if not f.lo <= value <= f.hi:
            raise invalid("range")
        return value
    if f.kind == "bool":
        if type(value) is not bool:
            raise invalid("type")
        return value
    if not isinstance(value, str):
        raise invalid("type")
    if "\x00" in value:
        raise invalid("nul")
    if f.kind == "uuid":
        if _UUID.fullmatch(value) is None:
            raise invalid("uuid")
    elif f.kind == "currency":
        if _CURRENCY.fullmatch(value) is None:
            raise ValidationError("MONEY_CURRENCY_INVALID", currency=value[:8])
    elif f.kind == "enum":
        if value not in f.choices:
            raise invalid("enum")
    elif len(value) > f.max_len:
        raise invalid("too_long")
    elif f.required and not value.strip():
        raise invalid("empty")
    return value


# ── Envelope ─────────────────────────────────────────────────────────────────


# Append-only rows the device dates: a sale made offline on Monday stays on Monday.
# The device's time (the outbox created_at) counts within a window around the
# server's clock (the 30-day offline unlock window plus time to push); outside it,
# or when absent, the server's time is used.
DATED_TABLES = frozenset({"sales", "stock_movements", "customer_ledger", "supplier_ledger"})
EVENT_TIME_PAST = timedelta(days=45)
EVENT_TIME_FUTURE = timedelta(minutes=5)


def event_time(recorded_at: str | None, now: datetime) -> datetime:
    at = parse_recorded_at(recorded_at) if recorded_at else None
    if at is None or not now - EVENT_TIME_PAST <= at <= now + EVENT_TIME_FUTURE:
        return now
    return at.astimezone(UTC)


def parse_recorded_at(value: str) -> datetime | None:
    """The outbox `created_at` (informational, audit only): tz-aware ISO-8601."""
    if len(value) > 40:
        return None
    try:
        at = datetime.fromisoformat(value)
    except ValueError:
        return None
    return at if at.tzinfo is not None else None


def check_envelope(op: OpInput, actor: User) -> None:
    """Op-level shape rules. op_id is checked by the caller before any DB access
    (an invalid op_id cannot be recorded, so its outcome is never cached)."""
    if not is_uuid(op.row_id):
        raise ValidationError("SYNC_OP_INVALID", field="row_id")
    if op.table not in SYNC_TABLES:
        raise ValidationError("UNKNOWN_TABLE", table=op.table[:32])
    if op.op not in ("insert", "update"):
        raise ValidationError("SYNC_OP_INVALID", field="op")
    if (op.table, op.op) not in _HANDLERS:
        raise ValidationError("SYNC_OP_UNSUPPORTED", table=op.table, op=op.op)
    if op.op == "update":
        if op.base_version is None:
            raise ValidationError("SYNC_BASE_VERSION_REQUIRED", table=op.table)
        if not 0 <= op.base_version <= INT32_MAX:  # 0 = never read: a plain conflict
            raise ValidationError("SYNC_OP_INVALID", field="base_version")
    if op.actor_id is not None and op.actor_id != actor.id:
        # An op is only ever applied under the token of the user who recorded it.
        raise PermissionDeniedError("SYNC_ACTOR_MISMATCH", actor_id=actor.id)
    if op.created_at is not None and parse_recorded_at(op.created_at) is None:
        raise ValidationError("SYNC_OP_INVALID", field="created_at")


# ── Read port + plan types ───────────────────────────────────────────────────


@dataclass(frozen=True, slots=True)
class ProductRef:
    id: str
    deleted: bool
    track_stock: bool
    sell_price_minor: int
    cost_minor: int | None
    decimal_places: int | None  # its unit's; None when the unit row is missing


@dataclass(frozen=True, slots=True)
class CustomerRef:
    id: str
    deleted: bool
    currency: str
    credit_limit_minor: int | None
    is_active: bool


@dataclass(frozen=True, slots=True)
class SupplierRef:
    id: str
    deleted: bool
    currency: str


@dataclass(frozen=True, slots=True)
class SaleRef:
    id: str
    branch_id: str
    created_by: str | None
    customer_id: str | None
    currency: str
    subtotal_minor: int
    total_minor: int
    paid_minor: int
    occurred_at: datetime  # the sale's time, as its header recorded it


@dataclass(frozen=True, slots=True)
class ShiftRef:
    id: str
    branch_id: str
    user_id: str
    status: str


class SyncReader(Protocol):
    """Lookups the policy needs (implemented in infrastructure, same session)."""

    def product(self, product_id: str) -> ProductRef | None: ...

    def unit_exists(self, unit_id: str) -> bool: ...

    def shop_currencies(self) -> frozenset[str]: ...  # the live branches' currencies

    def shift(self, shift_id: str) -> ShiftRef | None: ...

    def shift_expected_cash(self, shift_id: str) -> int: ...  # float + its drawer cash

    def customer(self, customer_id: str) -> CustomerRef | None: ...

    def customer_balance(self, customer_id: str) -> int: ...

    def supplier(self, supplier_id: str) -> SupplierRef | None: ...

    def sale(self, sale_id: str) -> SaleRef | None: ...  # locks the header where supported

    def sale_lines_total(self, sale_id: str) -> int: ...

    def sale_line_qty(self, sale_id: str, product_id: str) -> int: ...

    def sale_stock_out_qty(self, sale_id: str, product_id: str) -> int: ...

    def sale_payments_total(self, sale_id: str) -> int: ...

    def sale_charges_total(self, sale_id: str) -> int: ...

    def branch_active(self, branch_id: str) -> bool: ...

    def sale_number_taken(self, branch_id: str, number: str) -> bool: ...

    def recent_sell_prices(self, product_id: str, since: datetime) -> frozenset[int]:
        """Every sell price the product had at some moment since `since`."""
        ...


@dataclass(frozen=True, slots=True)
class RowSnapshot:
    """The stored row an op targets: business columns + version + soft-delete flag."""

    version: int
    deleted: bool
    values: Mapping[str, Any]


@dataclass(frozen=True, slots=True)
class AuditIntent:
    action: str
    entity_type: str
    after: dict[str, Any]
    before: dict[str, Any] | None = None


@dataclass(frozen=True, slots=True)
class ApplyPlan:
    values: dict[str, Any]  # columns to write: validated + server-derived
    auth_branch_id: str  # branch the permission was checked in
    row_branch_id: str | None  # branch the row belongs to (change_log scope); None = shop-wide
    audit: AuditIntent


@dataclass(frozen=True, slots=True)
class _Ctx:
    op: OpInput
    actor: User
    active_branch: str | None
    existing: RowSnapshot | None
    reader: SyncReader
    now: datetime


def _need(ctx: _Ctx, permission: Permission, branch_id: str) -> None:
    require_permission(POLICY, ctx.actor, permission, branch_id)


def _active(ctx: _Ctx) -> str:
    if not ctx.active_branch:
        raise ValidationError("BRANCH_REQUIRED")
    return ctx.active_branch


def _guard_insert(ctx: _Ctx) -> None:
    if ctx.existing is None:
        return
    if ctx.op.table in MASTER_TABLES:
        raise SyncConflict(f"{ctx.op.table.upper()}_ALREADY_EXISTS", row_id=ctx.op.row_id)
    raise ValidationError("SYNC_ROW_EXISTS", table=ctx.op.table, row_id=ctx.op.row_id)


def _guard_update(ctx: _Ctx, not_found: str) -> RowSnapshot:
    current = ctx.existing
    if current is None or current.deleted:
        raise NotFoundError(not_found, row_id=ctx.op.row_id)
    if current.version != ctx.op.base_version:
        raise SyncConflict(
            f"{ctx.op.table.upper()}_VERSION_CONFLICT",
            base_version=ctx.op.base_version, current_version=current.version,
        )
    return current


def _product(ctx: _Ctx, product_id: str, *, allow_deleted: bool = False) -> ProductRef:
    p = ctx.reader.product(product_id)
    if p is None or (p.deleted and not allow_deleted):
        raise NotFoundError("PRODUCT_NOT_FOUND", product_id=product_id)
    return p


def _customer(ctx: _Ctx, customer_id: str) -> CustomerRef:
    c = ctx.reader.customer(customer_id)
    if c is None or c.deleted:
        raise NotFoundError("CUSTOMER_NOT_FOUND", customer_id=customer_id)
    return c


def _own_sale(ctx: _Ctx, sale_id: str) -> SaleRef:
    """A sale child (line, payment, sale movement, credit charge) must reference an
    existing sale that the pushing actor created; SALE_CREATE in the sale's branch."""
    sale = ctx.reader.sale(sale_id)
    if sale is None:
        raise NotFoundError("SALE_NOT_FOUND", sale_id=sale_id)
    _need(ctx, Permission.SALE_CREATE, sale.branch_id)
    if sale.created_by != ctx.actor.id:
        raise ValidationError("SYNC_REF_MISMATCH", field="sale_id", reason="not_own_sale")
    return sale


def _require_complete_lines(ctx: _Ctx, sale: SaleRef) -> None:
    """Money against a sale (a payment or a credit charge) is accepted only once
    the sale's lines add up to its header subtotal: the header totals are the
    client's claim, the lines are what was sold. Lines precede that money in
    local_seq, so a sale still missing lines is a retry (not recorded), not a
    rejection."""
    if ctx.reader.sale_lines_total(sale.id) != sale.subtotal_minor:
        raise NotFoundError("SALE_LINES_NOT_FOUND", sale_id=sale.id)


def _pick(values: Mapping[str, Any], *keys: str) -> dict[str, Any]:
    return {k: values[k] for k in keys if k in values}


def _violates(rule: Callable[[], None]) -> bool:
    try:
        rule()
    except ConflictError:
        return True
    return False


# ── Handlers: one per (table, op) the app legitimately pushes ────────────────


def _products_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    _need(ctx, Permission.PRODUCT_MANAGE, branch)
    _guard_insert(ctx)
    if not ctx.reader.unit_exists(v["unit_id"]):
        raise ValidationError("UNIT_NOT_FOUND", unit_id=v["unit_id"])
    currency = v.get("sell_currency", DEFAULT_CURRENCY)
    if currency not in ctx.reader.shop_currencies():
        # A price is in a currency the shop's branches trade in, as on REST.
        raise ValidationError("PRICE_CURRENCY_INVALID", currency=currency)
    after = _pick(
        v, "sku", "name", "unit_id", "sell_price_minor", "sell_currency", "track_stock", "is_active"
    )
    return ApplyPlan(v, branch, None, AuditIntent("product.created", "product", after))


def _products_update(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    _need(ctx, Permission.PRODUCT_MANAGE, branch)
    current = _guard_update(ctx, "PRODUCT_NOT_FOUND")
    if not v:
        raise ValidationError("SYNC_OP_INVALID", field="data", reason="empty")
    if "sell_currency" in v and v["sell_currency"] not in ctx.reader.shop_currencies():
        raise ValidationError("PRICE_CURRENCY_INVALID", currency=v["sell_currency"])
    changed = {k: val for k, val in v.items() if current.values.get(k) != val}
    price_changed = "sell_price_minor" in changed or "sell_currency" in changed
    if price_changed:
        _need(ctx, Permission.PRICE_CHANGE, branch)
    if "cost_minor" in v:
        # A cost sets every later margin: purchase.cost. It is in the product's
        # selling currency, as a REST receipt sets it.
        _need(ctx, Permission.PURCHASE_COST, branch)
        v = {**v, "cost_currency": v.get("sell_currency", current.values.get("sell_currency"))}
    if price_changed:
        action = "product.price_changed"
    elif changed.get("is_active") is False:
        action = "product.deactivated"
    elif set(changed) == {"cost_minor"}:
        action = "cost.valuation_changed"
    else:
        action = "product.updated"
    before = {k: current.values.get(k) for k in changed}
    return ApplyPlan(v, branch, None, AuditIntent(action, "product", changed, before))


def _barcodes_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    _need(ctx, Permission.PRODUCT_MANAGE, branch)
    _guard_insert(ctx)
    _product(ctx, v["product_id"])
    after = _pick(v, "product_id", "code")
    return ApplyPlan(v, branch, None, AuditIntent("barcode.added", "barcode", after))


def _units_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    if (v["name"], v["decimal_places"]) in CANONICAL_UNITS:
        # Every fresh device seeds these five units on first use, whatever the role
        # of its first user; any member of the branch may push that seed.
        if not ctx.actor.is_active or not POLICY.permissions_for(ctx.actor, branch):
            raise PermissionDeniedError(
                "ACCESS_DENIED", permission="branch.member", branch_id=branch,
                actor_id=ctx.actor.id,
            )
    else:
        _need(ctx, Permission.PRODUCT_MANAGE, branch)
    _guard_insert(ctx)
    after = _pick(v, "name", "decimal_places")
    return ApplyPlan(v, branch, None, AuditIntent("unit.created", "unit", after))


def _customers_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    _need(ctx, Permission.SALE_CREATE, branch)
    _guard_insert(ctx)
    limit = v.get("credit_limit_minor")  # absent or null: unlimited credit
    after = _pick(v, "name", "credit_limit_minor", "currency")
    if limit != 0 and not POLICY.can(ctx.actor, Permission.CUSTOMER_CREDIT, branch):
        # Granting credit is a manager's decision. The offline row still applies
        # (its sales and payments depend on it) but with no credit; the audit keeps
        # what was asked for.
        v = {**v, "credit_limit_minor": 0}
        after = {**after, "credit_limit_minor": 0, "credit_limit_requested": limit}
    return ApplyPlan(v, branch, None, AuditIntent("customer.created", "customer", after))


def _customers_update(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    _need(ctx, Permission.SALE_CREATE, branch)
    current = _guard_update(ctx, "CUSTOMER_NOT_FOUND")
    if not v:
        raise ValidationError("SYNC_OP_INVALID", field="data", reason="empty")
    changed = {k: val for k, val in v.items() if current.values.get(k) != val}
    if "credit_limit_minor" in changed or "is_active" in changed:
        # Credit, and closing a customer's account, are a manager's decision.
        _need(ctx, Permission.CUSTOMER_CREDIT, branch)
    action = (
        "customer.credit_limit_changed" if "credit_limit_minor" in changed else "customer.updated"
    )
    before = {k: current.values.get(k) for k in changed}
    return ApplyPlan(v, branch, None, AuditIntent(action, "customer", changed, before))


def _suppliers_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch = _active(ctx)
    _need(ctx, Permission.PRODUCT_MANAGE, branch)
    _guard_insert(ctx)
    after = _pick(v, "name", "currency")
    return ApplyPlan(v, branch, None, AuditIntent("supplier.created", "supplier", after))


_STOCK_ACTIONS = {
    StockReason.ADJUSTMENT: "stock.adjusted",
    StockReason.PURCHASE: "stock.received",
    StockReason.SALE: "stock.sold",
}


def _stock_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    reason = StockReason(v["reason"])
    if reason not in _STOCK_ACTIONS:
        raise ValidationError("SYNC_OP_UNSUPPORTED", table="stock_movements", reason=reason.value)
    branch: str = v["branch_id"]
    needed = Permission.SALE_CREATE if reason is StockReason.SALE else Permission.STOCK_ADJUST
    _need(ctx, needed, branch)
    _guard_insert(ctx)
    qty: int = v["qty_delta"]
    if reason is StockReason.SALE:
        # A sale movement must be backed by an unconsumed line of the pusher's own
        # sale in the same branch; otherwise sale.create would be a stock write-off.
        _product(ctx, v["product_id"], allow_deleted=True)
        if qty >= 0:
            raise ValidationError("STOCK_INVALID_QTY", qty=qty)
        if v.get("ref_type") != "sale" or v.get("ref_id") is None:
            raise ValidationError("SYNC_FIELD_REQUIRED", table="stock_movements", field="ref_id")
        sale = _own_sale(ctx, v["ref_id"])
        if sale.branch_id != branch:
            raise ValidationError("SYNC_REF_MISMATCH", field="branch_id", reason="sale_branch")
        sold = ctx.reader.sale_line_qty(sale.id, v["product_id"])
        moved = ctx.reader.sale_stock_out_qty(sale.id, v["product_id"])
        if moved - qty > sold:
            # A line still on its way (waiting for a permission, say) makes this a
            # retry; once every line is in, moving more than they sold is refused.
            _require_complete_lines(ctx, sale)
            raise ValidationError(
                "SYNC_REF_MISMATCH", field="qty_delta", reason="exceeds_sale_lines"
            )
    else:
        if v.get("ref_type") is not None or v.get("ref_id") is not None:
            raise ValidationError(
                "SYNC_FIELD_NOT_ALLOWED", table="stock_movements", field="ref_id",
                reason=reason.value,
            )
        product = _product(ctx, v["product_id"])
        if reason is StockReason.ADJUSTMENT:
            adjust_stock(
                id=ctx.op.row_id, product_id=product.id, branch_id=branch, qty_delta=qty,
                at=ctx.now,
            )
            if not product.track_stock:
                raise ValidationError("PRODUCT_NOT_STOCK_TRACKED", product_id=product.id)
        elif qty <= 0:
            raise ValidationError("STOCK_INVALID_QTY", qty=qty)
    after = _pick(v, "product_id", "branch_id", "qty_delta", "reason", "ref_id")
    return ApplyPlan(
        v, branch, branch, AuditIntent(_STOCK_ACTIONS[reason], "stock_movement", after)
    )


def _sales_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    branch: str = v["branch_id"]
    _need(ctx, Permission.SALE_CREATE, branch)
    _guard_insert(ctx)
    shift_id = v.get("shift_id")
    # The drawer the sale's cash went into: the seller's own shift in this branch.
    # A sale the till rang before its close reached the server is kept, flagged.
    after_close = shift_id is not None and _own_shift(ctx, shift_id, branch).status != "open"
    discount: int = v.get("discount_minor", 0)
    assert_discount_valid(discount_minor=discount, subtotal_minor=v["subtotal_minor"])
    if discount > 0:
        _need(ctx, Permission.SALE_DISCOUNT, branch)
    total: int = v["total_minor"]
    if total != v["subtotal_minor"] - discount + v.get("tax_minor", 0):
        raise ValidationError(
            "SYNC_FIELD_INVALID", table="sales", field="total_minor", reason="arithmetic"
        )
    assert_sale_not_overpaid(paid_minor=v["paid_minor"], total_minor=total)
    customer_id = v.get("customer_id")
    if customer_id is None:
        if v["paid_minor"] < total:
            raise ConflictError("SALE_UNDERPAID", total=total, paid=v["paid_minor"])
    else:
        _customer(ctx, customer_id)
    after = _pick(
        v, "number", "branch_id", "customer_id", "currency", "discount_minor", "total_minor",
        "paid_minor",
    )
    if ctx.reader.sale_number_taken(branch, v["number"]):
        # Two devices numbered a sale alike: kept (the sale happened), flagged.
        after = {**after, "number_taken": True}
    if after_close:
        after = {**after, "after_shift_close": True}
    return ApplyPlan(v, branch, branch, AuditIntent("sale.settled", "sale", after))


_DISCOUNTERS = (Permission.SALE_DISCOUNT, Permission.PRICE_CHANGE)


def _sale_lines_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    sale = _own_sale(ctx, v["sale_id"])
    _guard_insert(ctx)
    product = _product(ctx, v["product_id"], allow_deleted=True)
    places = product.decimal_places
    if places is None:
        raise NotFoundError("UNIT_NOT_FOUND", product_id=product.id)
    if v.get("decimal_places", places) != places:
        # Decimal places say what a quantity means (1500 is 1.500 kg, or 1500
        # pieces): the product's unit decides, never the device.
        raise ValidationError(
            "SYNC_FIELD_INVALID", table="sale_lines", field="decimal_places", reason="unit"
        )
    expected = line_total_minor(v["unit_price_minor"], v["qty_minor"], places)
    if v["line_total_minor"] != expected:
        raise ValidationError(
            "SYNC_FIELD_INVALID", table="sale_lines", field="line_total_minor",
            reason="arithmetic",
        )
    currency = v.get("currency", DEFAULT_CURRENCY)
    if currency != sale.currency:
        raise ConflictError("SALE_CURRENCY_MISMATCH", expected=sale.currency, got=currency)
    if ctx.reader.sale_lines_total(sale.id) + v["line_total_minor"] > sale.subtotal_minor:
        raise ValidationError(
            "SYNC_REF_MISMATCH", field="line_total_minor", reason="exceeds_subtotal"
        )
    price: int = v["unit_price_minor"]
    below_catalog = price < product.sell_price_minor
    if below_catalog and not any(POLICY.can(ctx.actor, p, sale.branch_id) for p in _DISCOUNTERS):
        # Under the catalog price is a discount, a manager's decision, unless the
        # device still had an older price: one the product had within the window
        # before the sale (its time as the header recorded it, never after now).
        since = min(ctx.now, sale.occurred_at) - PRICE_DRIFT_WINDOW
        if price not in ctx.reader.recent_sell_prices(product.id, since):
            require_any_permission(POLICY, ctx.actor, _DISCOUNTERS, sale.branch_id)
    # The unit's decimal places, and the cost snapshot, are the server's.
    values = {**v, "decimal_places": places, "unit_cost_minor": product.cost_minor or 0}
    after = {
        **_pick(v, "sale_id", "product_id", "qty_minor", "unit_price_minor", "line_total_minor"),
        "catalog_price_minor": product.sell_price_minor,
        **({"below_catalog": True} if below_catalog else {}),
    }
    return ApplyPlan(
        values, sale.branch_id, sale.branch_id, AuditIntent("sale.line_added", "sale_line", after)
    )


def _payments_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    sale = _own_sale(ctx, v["sale_id"])
    _guard_insert(ctx)
    amount: int = v["amount_minor"]
    currency = v.get("currency", DEFAULT_CURRENCY)
    if currency != sale.currency:
        raise ConflictError("SALE_CURRENCY_MISMATCH", expected=sale.currency, got=currency)
    assert_payment_valid(
        method=v["method"], amount_minor=amount, tendered_minor=v.get("tendered_minor")
    )
    _require_complete_lines(ctx, sale)
    # Payments never exceed what the sale says was paid, nor the sale's total.
    if ctx.reader.sale_payments_total(sale.id) + amount > min(sale.paid_minor, sale.total_minor):
        raise ValidationError("SYNC_REF_MISMATCH", field="amount_minor", reason="exceeds_paid")
    after = _pick(v, "sale_id", "method", "amount_minor", "currency")
    return ApplyPlan(
        v, sale.branch_id, sale.branch_id, AuditIntent("payment.recorded", "payment", after)
    )


def _customer_ledger_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    entry = LedgerEntryType(v["type"])
    amount: int = v["amount_minor"]
    currency = v.get("currency", DEFAULT_CURRENCY)
    if entry is not LedgerEntryType.PAYMENT and (
        v.get("shift_id") is not None or v.get("method") is not None
    ):
        # How money was paid, and into which drawer, belongs to a payment only.
        raise ValidationError(
            "SYNC_FIELD_NOT_ALLOWED", table="customer_ledger", field="shift_id", reason=entry.value
        )
    if entry is LedgerEntryType.ADJUSTMENT:
        return _write_off(ctx, v, amount, currency)
    if entry is not LedgerEntryType.CHARGE and entry is not LedgerEntryType.PAYMENT:
        # An opening balance: no app flow pushes one.
        raise ValidationError("SYNC_OP_UNSUPPORTED", table="customer_ledger", type=entry.value)
    if amount <= 0:
        # Only an adjustment is signed; a charge or a payment is money one way.
        raise ValidationError(
            "SYNC_FIELD_INVALID", table="customer_ledger", field="amount_minor", reason="range"
        )
    if entry is LedgerEntryType.CHARGE:
        if v.get("ref_type") != "sale" or v.get("ref_id") is None:
            raise ValidationError("SYNC_FIELD_REQUIRED", table="customer_ledger", field="ref_id")
        sale = _own_sale(ctx, v["ref_id"])
        _guard_insert(ctx)
        customer = _customer(ctx, v["customer_id"])
        if sale.customer_id != customer.id:
            raise ValidationError(
                "SYNC_REF_MISMATCH", field="customer_id", reason="sale_customer"
            )
        if currency != sale.currency:
            raise ConflictError("SALE_CURRENCY_MISMATCH", expected=sale.currency, got=currency)
        if customer.currency != sale.currency:
            # Ledgers never convert: a customer's debt is in their own currency.
            raise ConflictError(
                "DEBT_CURRENCY_MISMATCH", expected=customer.currency, got=sale.currency
            )
        _require_complete_lines(ctx, sale)
        if ctx.reader.sale_charges_total(sale.id) + amount > sale.total_minor - sale.paid_minor:
            raise ValidationError(
                "SYNC_REF_MISMATCH", field="amount_minor", reason="exceeds_unpaid"
            )
        balance = ctx.reader.customer_balance(customer.id)
        over_limit = _violates(lambda: assert_within_credit_limit(
            balance_minor=balance, charge_minor=amount,
            credit_limit_minor=customer.credit_limit_minor,
        ))
        after = {
            **_pick(v, "customer_id", "amount_minor", "currency", "ref_id"),
            "over_credit_limit": over_limit,
        }
        if not customer.is_active:
            # The till sold before it heard the account was closed: kept, flagged.
            after = {**after, "customer_inactive": True}
        return ApplyPlan(
            v, sale.branch_id, sale.branch_id,
            AuditIntent("debt.charge_posted", "customer_ledger", after),
        )
    if v.get("ref_type") not in (None, "manual") or v.get("ref_id") is not None:
        raise ValidationError(
            "SYNC_FIELD_NOT_ALLOWED", table="customer_ledger", field="ref_id", reason="payment"
        )
    branch = _active(ctx)
    _need(ctx, Permission.SALE_CREATE, branch)
    _guard_insert(ctx)
    customer = _customer(ctx, v["customer_id"])
    if currency != customer.currency:
        raise ConflictError("DEBT_CURRENCY_MISMATCH", expected=customer.currency, got=currency)
    if v.get("shift_id") is not None:
        _own_shift(ctx, v["shift_id"], branch)  # the drawer a collection went into
    # Append-only ledger: concurrent offline payments both apply (customers-debt.md),
    # so an overpayment is flagged in the audit entry, not rejected.
    balance = ctx.reader.customer_balance(customer.id)
    overpaid = _violates(
        lambda: assert_not_overpaid(balance_minor=balance, payment_minor=amount)
    )
    after = {
        **_pick(v, "customer_id", "amount_minor", "currency", "method", "shift_id"),
        "overpaid": overpaid,
    }
    return ApplyPlan(
        v, branch, None, AuditIntent("debt.payment_recorded", "customer_ledger", after)
    )


def _write_off(ctx: _Ctx, v: dict[str, Any], amount: int, currency: str) -> ApplyPlan:
    """A write-off from a device: a negative adjustment (it lowers the debt),
    `ref_type` write_off, needing debt.write_off. Like a payment, one that outruns
    the balance is flagged, not refused: another till may have taken a payment
    meanwhile."""
    if v.get("ref_type") != "write_off" or v.get("ref_id") is not None:
        raise ValidationError(
            "SYNC_FIELD_INVALID", table="customer_ledger", field="ref_type", reason="adjustment"
        )
    if amount >= 0:
        raise ValidationError(
            "SYNC_FIELD_INVALID", table="customer_ledger", field="amount_minor", reason="range"
        )
    branch = _active(ctx)
    _need(ctx, Permission.DEBT_WRITE_OFF, branch)
    _guard_insert(ctx)
    customer = _customer(ctx, v["customer_id"])
    if currency != customer.currency:
        raise ConflictError("DEBT_CURRENCY_MISMATCH", expected=customer.currency, got=currency)
    balance = ctx.reader.customer_balance(customer.id)
    after = {
        **_pick(v, "customer_id", "currency"), "amount": -amount,
        "exceeds_balance": -amount > balance,
    }
    return ApplyPlan(v, branch, None, AuditIntent("debt.written_off", "customer_ledger", after))


def _supplier_ledger_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    if SupplierEntryType(v["type"]) is not SupplierEntryType.BILL:
        raise ValidationError("SYNC_OP_UNSUPPORTED", table="supplier_ledger", type=v["type"])
    branch = _active(ctx)
    _need(ctx, Permission.PURCHASE_COST, branch)  # a bill is a debt: not a stock move
    _guard_insert(ctx)
    supplier = ctx.reader.supplier(v["supplier_id"])
    if supplier is None or supplier.deleted:
        raise NotFoundError("SUPPLIER_NOT_FOUND", supplier_id=v["supplier_id"])
    currency = v.get("currency", DEFAULT_CURRENCY)
    if currency != supplier.currency:
        raise ConflictError("PURCHASE_CURRENCY_MISMATCH", expected=supplier.currency, got=currency)
    after = _pick(v, "supplier_id", "amount_minor", "currency")
    return ApplyPlan(
        v, branch, None, AuditIntent("supplier.bill_posted", "supplier_ledger", after)
    )


def _own_shift(ctx: _Ctx, shift_id: str, branch_id: str) -> ShiftRef:
    """A sale or a debt collection names the pushing user's own shift in the same
    branch: the drawer its cash went into. One not arrived yet is a retry."""
    shift = ctx.reader.shift(shift_id)
    if shift is None:
        raise NotFoundError("SHIFT_NOT_FOUND", shift_id=shift_id)
    if shift.branch_id != branch_id:
        raise ValidationError("SYNC_REF_MISMATCH", field="shift_id", reason="shift_branch")
    if shift.user_id != ctx.actor.id:
        raise ValidationError("SYNC_REF_MISMATCH", field="shift_id", reason="shift_user")
    return shift


def _shifts_insert(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    """A till opens its seller's own shift, in a branch where they sell."""
    branch: str = v["branch_id"]
    _need(ctx, Permission.SALE_CREATE, branch)
    _guard_insert(ctx)
    if v["user_id"] != ctx.actor.id:
        raise ValidationError("SYNC_REF_MISMATCH", field="user_id", reason="own_shift")
    assert_shift_cash_valid(amount_minor=v.get("opening_float_minor", 0))
    values = {**v, "status": "open", "opened_at": event_time(ctx.op.created_at, ctx.now)}
    after = _pick(v, "branch_id", "opening_float_minor")
    return ApplyPlan(values, branch, branch, AuditIntent("shift.opened", "shift", after))


def _shifts_update(ctx: _Ctx, v: dict[str, Any]) -> ApplyPlan:
    """Closing a shift, by its own cashier or someone with report.view in its
    branch. The server counts what the drawer should hold from its own rows: the
    float, the cash of the shift's settled sales, and cash debt collections."""
    current = _guard_update(ctx, "SHIFT_NOT_FOUND")
    branch: str = current.values["branch_id"]
    own = current.values["user_id"] == ctx.actor.id
    _need(ctx, Permission.SALE_CREATE if own else Permission.REPORT_VIEW, branch)
    if current.values["status"] != "open":
        raise ConflictError("SHIFT_ALREADY_CLOSED", shift_id=ctx.op.row_id)
    if v.get("status") != "closed" or "counted_cash_minor" not in v:
        raise ValidationError("SYNC_OP_INVALID", field="data", reason="shift_close")
    counted: int = v["counted_cash_minor"]
    assert_shift_cash_valid(amount_minor=counted)
    expected = ctx.reader.shift_expected_cash(ctx.op.row_id)
    values = {
        "status": "closed", "counted_cash_minor": counted, "expected_cash_minor": expected,
        "variance_minor": counted - expected,
        "closed_at": event_time(ctx.op.created_at, ctx.now),
    }
    after = {"counted": counted, "expected": expected, "variance": counted - expected}
    return ApplyPlan(values, branch, branch, AuditIntent("shift.closed", "shift", after))


_HANDLERS: dict[tuple[str, str], Callable[[_Ctx, dict[str, Any]], ApplyPlan]] = {
    ("products", "insert"): _products_insert,
    ("products", "update"): _products_update,
    ("barcodes", "insert"): _barcodes_insert,
    ("units", "insert"): _units_insert,
    ("customers", "insert"): _customers_insert,
    ("customers", "update"): _customers_update,
    ("suppliers", "insert"): _suppliers_insert,
    ("stock_movements", "insert"): _stock_insert,
    ("sales", "insert"): _sales_insert,
    ("sale_lines", "insert"): _sale_lines_insert,
    ("payments", "insert"): _payments_insert,
    ("shifts", "insert"): _shifts_insert,
    ("shifts", "update"): _shifts_update,
    ("customer_ledger", "insert"): _customer_ledger_insert,
    ("supplier_ledger", "insert"): _supplier_ledger_insert,
}


def plan_op(
    op: OpInput,
    *,
    actor: User,
    active_branch: str | None,
    existing: RowSnapshot | None,
    reader: SyncReader,
    now: datetime,
) -> ApplyPlan:
    """Validate + authorize one op (after check_envelope). Raises SyncConflict
    (outcome `conflict`) or another AppError (outcome `rejected`)."""
    values = clean_fields(op.table, op.op, op.data)
    ctx = _Ctx(
        op=op, actor=actor, active_branch=active_branch, existing=existing, reader=reader, now=now
    )
    plan = _HANDLERS[(op.table, op.op)](ctx, values)
    # Writes happen only in an active branch; its history stays readable.
    assert_branch_active(
        branch_id=plan.auth_branch_id, is_active=reader.branch_active(plan.auth_branch_id)
    )
    if op.op == "insert" and op.table in DATED_TABLES:
        plan = replace(plan, values={**plan.values, "occurred_at": event_time(op.created_at, now)})
    return plan


# ── Outcome caching, audit role, pull scope ──────────────────────────────────

_TRANSIENT = frozenset({
    "ACCESS_DENIED", "SYNC_ACTOR_MISMATCH", "BRANCH_REQUIRED", "BRANCH_INACTIVE", "ROW_INVALID",
})


def is_cacheable(code: str) -> bool:
    """Whether a rejected/conflict outcome is recorded against its op_id forever.
    Outcomes that depend on server state that can change (permissions, which user
    pushes, a parent not present yet, an unexpected error) are re-evaluated on
    replay instead; nothing was applied, so exactly-once still holds."""
    return code not in _TRANSIENT and not code.endswith("_NOT_FOUND")


def role_label(actor: User, branch_id: str) -> str | None:
    names = sorted({a.role_name for a in actor.assignments if a.branch_id == branch_id})
    return ",".join(names)[:32] or None


def clamp_pull_limit(limit: int) -> int:
    return max(1, min(limit, PULL_LIMIT_MAX))


_ANY = frozenset(Permission)
_DEBT_READERS = frozenset(
    {Permission.SALE_CREATE, Permission.REPORT_VIEW, Permission.DEBT_WRITE_OFF}
)
_SALE_READERS = frozenset({Permission.SALE_CREATE, Permission.REPORT_VIEW})
_READ: dict[str, frozenset[Permission]] = {
    "products": _ANY,
    "barcodes": _ANY,
    "units": _ANY,
    "categories": _ANY,
    "customers": _DEBT_READERS,
    "customer_ledger": _DEBT_READERS,
    "suppliers": frozenset(
        {Permission.STOCK_ADJUST, Permission.PRODUCT_MANAGE, Permission.REPORT_VIEW}
    ),
    "supplier_ledger": frozenset({Permission.REPORT_VIEW, Permission.DEBT_WRITE_OFF}),
    "stock_movements": _ANY,
    "sales": _SALE_READERS,
    "sale_lines": _SALE_READERS,
    "payments": _SALE_READERS,
    "shifts": _SALE_READERS,
}
_BRANCH_SCOPED_READ = frozenset(
    {"stock_movements", "sales", "sale_lines", "payments", "shifts"}
)
_COST_READERS = frozenset({Permission.PRODUCT_MANAGE, Permission.REPORT_VIEW})
_COST_FIELDS: dict[str, tuple[str, ...]] = {
    "products": ("cost_minor", "cost_currency"),
    "sale_lines": ("unit_cost_minor",),
}


@dataclass(frozen=True, slots=True)
class PullScope:
    """What one actor may pull: tables their permissions can read (branch rows only
    for branches they hold a role in), allow-listed fields only, costs redacted
    without product.manage/report.view."""

    any_branch: frozenset[Permission]
    by_branch: Mapping[str, frozenset[Permission]]

    @classmethod
    def for_actor(cls, actor: User) -> PullScope:
        if not actor.is_active:
            return cls(frozenset(), {})
        by_branch = {
            a.branch_id: POLICY.permissions_for(actor, a.branch_id) for a in actor.assignments
        }
        union: frozenset[Permission] = frozenset().union(*by_branch.values())
        return cls(union, by_branch)

    @property
    def is_empty(self) -> bool:
        return not self.any_branch

    def view(
        self, table: str, branch_id: str | None, data: Mapping[str, Any]
    ) -> dict[str, Any] | None:
        """The pull payload for one change_log row, or None when not visible."""
        readers = _READ.get(table)
        if readers is None:
            return None
        perms = self.any_branch
        if table in _BRANCH_SCOPED_READ:
            legacy = data.get("branch_id")  # rows logged before change_log.branch_id existed
            branch = branch_id or (legacy if isinstance(legacy, str) else None)
            if branch is None:
                return None  # a branch row whose branch is unknown is visible to nobody
            perms = self.by_branch.get(branch, frozenset())
        if not perms & readers:
            return None
        # A hidden cost field is omitted, not nulled: the device keeps its local
        # value instead of overwriting it (one device can hold several users' rows).
        hidden = () if perms & _COST_READERS else _COST_FIELDS.get(table, ())
        return {k: data[k] for k in READ_FIELDS[table] if k in data and k not in hidden}
