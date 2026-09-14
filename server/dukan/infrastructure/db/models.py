"""SQLAlchemy models. One table per Phase 1 identity concern + the audit log.
Schema parity with the Drift client is kept via docs/domain + mirrored tests."""

from __future__ import annotations

from datetime import datetime

from sqlalchemy import JSON, Boolean, DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from dukan.infrastructure.db.base import Base, RecordMixin, utcnow


class UserModel(RecordMixin, Base):
    __tablename__ = "users"
    username: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    display_name: Mapped[str] = mapped_column(String(128))
    password_hash: Mapped[str] = mapped_column(String(255))
    status: Mapped[str] = mapped_column(String(16), default="active")
    default_branch_id: Mapped[str | None] = mapped_column(String(36), default=None)


class RoleModel(RecordMixin, Base):
    __tablename__ = "roles"
    name: Mapped[str] = mapped_column(String(32), unique=True)
    permissions: Mapped[list] = mapped_column(JSON, default=list)


class BranchModel(RecordMixin, Base):
    __tablename__ = "branches"
    name: Mapped[str] = mapped_column(String(128))
    timezone: Mapped[str] = mapped_column(String(48), default="Asia/Kabul")
    currency_default: Mapped[str] = mapped_column(String(3), default="AFN")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class BranchAssignmentModel(RecordMixin, Base):
    __tablename__ = "branch_assignments"
    user_id: Mapped[str] = mapped_column(String(36), index=True)
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    role_name: Mapped[str] = mapped_column(String(32))


class SessionModel(RecordMixin, Base):
    __tablename__ = "sessions"
    user_id: Mapped[str] = mapped_column(String(36), index=True)
    device_id: Mapped[str] = mapped_column(String(128))
    refresh_hash: Mapped[str] = mapped_column(String(128), index=True)
    # The hash the last refresh rotated out: presented again, it means the refresh
    # token was copied, and the session is revoked.
    prev_refresh_hash: Mapped[str | None] = mapped_column(String(128), index=True, default=None)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)


class AuditEntryModel(Base):
    """Append-only business record. Never updated; included in backups."""

    __tablename__ = "audit_entries"
    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    actor_id: Mapped[str | None] = mapped_column(String(36), default=None)
    actor_role: Mapped[str | None] = mapped_column(String(32), default=None)
    action: Mapped[str] = mapped_column(String(64))
    entity_type: Mapped[str | None] = mapped_column(String(32), default=None)
    entity_id: Mapped[str | None] = mapped_column(String(36), default=None)
    before: Mapped[dict | None] = mapped_column(JSON, default=None)
    after: Mapped[dict | None] = mapped_column(JSON, default=None)
    origin: Mapped[str] = mapped_column(String(16), default="api")


# ── Catalog + inventory (Phase 2) ────────────────────────────────────────────


class UnitModel(RecordMixin, Base):
    __tablename__ = "units"
    name: Mapped[str] = mapped_column(String(48))
    decimal_places: Mapped[int] = mapped_column(default=0)


class CategoryModel(RecordMixin, Base):
    __tablename__ = "categories"
    name: Mapped[str] = mapped_column(String(128))
    parent_id: Mapped[str | None] = mapped_column(String(36), default=None)


class ProductModel(RecordMixin, Base):
    __tablename__ = "products"
    sku: Mapped[str] = mapped_column(String(64), index=True)
    name: Mapped[str] = mapped_column(String(200), index=True)
    unit_id: Mapped[str] = mapped_column(String(36))
    category_id: Mapped[str | None] = mapped_column(String(36), default=None)
    sell_price_minor: Mapped[int] = mapped_column(default=0)
    sell_currency: Mapped[str] = mapped_column(String(3), default="AFN")
    cost_minor: Mapped[int | None] = mapped_column(default=None)
    cost_currency: Mapped[str | None] = mapped_column(String(3), default=None)
    track_stock: Mapped[bool] = mapped_column(Boolean, default=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class BarcodeModel(RecordMixin, Base):
    __tablename__ = "barcodes"
    product_id: Mapped[str] = mapped_column(String(36), index=True)
    code: Mapped[str] = mapped_column(String(64), index=True)
    symbology: Mapped[str] = mapped_column(String(16), default="ean13")


class StockMovementModel(RecordMixin, Base):
    """Append-only stock ledger. On-hand is derived by summing qty_delta."""

    __tablename__ = "stock_movements"
    product_id: Mapped[str] = mapped_column(String(36), index=True)
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    qty_delta: Mapped[int] = mapped_column()
    reason: Mapped[str] = mapped_column(String(16))
    ref_type: Mapped[str | None] = mapped_column(String(16), default=None)
    ref_id: Mapped[str | None] = mapped_column(String(36), default=None)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ── Sales / POS (Phase 3) ────────────────────────────────────────────────────


class ShiftModel(RecordMixin, Base):
    __tablename__ = "shifts"
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    user_id: Mapped[str] = mapped_column(String(36))
    opened_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    opening_float_minor: Mapped[int] = mapped_column(default=0)
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    counted_cash_minor: Mapped[int | None] = mapped_column(default=None)
    expected_cash_minor: Mapped[int | None] = mapped_column(default=None)
    variance_minor: Mapped[int | None] = mapped_column(default=None)
    status: Mapped[str] = mapped_column(String(8), default="open")


class SaleModel(RecordMixin, Base):
    __tablename__ = "sales"
    number: Mapped[str] = mapped_column(String(32), index=True)
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    shift_id: Mapped[str | None] = mapped_column(String(36), default=None)
    customer_id: Mapped[str | None] = mapped_column(String(36), default=None)  # Phase 4
    status: Mapped[str] = mapped_column(String(8), default="settled")
    currency: Mapped[str] = mapped_column(String(3), default="AFN")
    discount_minor: Mapped[int] = mapped_column(default=0)
    subtotal_minor: Mapped[int] = mapped_column(default=0)
    tax_minor: Mapped[int] = mapped_column(default=0)
    total_minor: Mapped[int] = mapped_column(default=0)
    paid_minor: Mapped[int] = mapped_column(default=0)
    change_minor: Mapped[int] = mapped_column(default=0)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class SaleLineModel(RecordMixin, Base):
    __tablename__ = "sale_lines"
    sale_id: Mapped[str] = mapped_column(String(36), index=True)
    product_id: Mapped[str] = mapped_column(String(36))
    name: Mapped[str] = mapped_column(String(200))
    qty_minor: Mapped[int] = mapped_column()
    decimal_places: Mapped[int] = mapped_column(default=0)
    unit_price_minor: Mapped[int] = mapped_column()
    unit_cost_minor: Mapped[int] = mapped_column(default=0)
    line_total_minor: Mapped[int] = mapped_column()
    currency: Mapped[str] = mapped_column(String(3), default="AFN")


class PaymentModel(RecordMixin, Base):
    __tablename__ = "payments"
    sale_id: Mapped[str] = mapped_column(String(36), index=True)
    method: Mapped[str] = mapped_column(String(8))
    amount_minor: Mapped[int] = mapped_column()
    currency: Mapped[str] = mapped_column(String(3), default="AFN")
    tendered_minor: Mapped[int | None] = mapped_column(default=None)
    change_minor: Mapped[int | None] = mapped_column(default=None)


# ── Customers, debt, purchasing (Phase 4) ────────────────────────────────────


class CustomerModel(RecordMixin, Base):
    __tablename__ = "customers"
    name: Mapped[str] = mapped_column(String(128), index=True)
    phone: Mapped[str | None] = mapped_column(String(32), default=None)
    credit_limit_minor: Mapped[int | None] = mapped_column(default=None)
    currency: Mapped[str] = mapped_column(String(3), default="AFN")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class CustomerLedgerModel(RecordMixin, Base):
    """Append-only customer ledger. Balance = Σ charges − Σ payments."""

    __tablename__ = "customer_ledger"
    customer_id: Mapped[str] = mapped_column(String(36), index=True)
    type: Mapped[str] = mapped_column(String(12))
    amount_minor: Mapped[int] = mapped_column()
    currency: Mapped[str] = mapped_column(String(3), default="AFN")
    ref_type: Mapped[str | None] = mapped_column(String(16), default=None)
    ref_id: Mapped[str | None] = mapped_column(String(36), default=None)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class SupplierModel(RecordMixin, Base):
    __tablename__ = "suppliers"
    name: Mapped[str] = mapped_column(String(128), index=True)
    phone: Mapped[str | None] = mapped_column(String(32), default=None)
    currency: Mapped[str] = mapped_column(String(3), default="AFN")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class SupplierLedgerModel(RecordMixin, Base):
    __tablename__ = "supplier_ledger"
    supplier_id: Mapped[str] = mapped_column(String(36), index=True)
    type: Mapped[str] = mapped_column(String(12))
    amount_minor: Mapped[int] = mapped_column()
    currency: Mapped[str] = mapped_column(String(3), default="AFN")
    ref_type: Mapped[str | None] = mapped_column(String(16), default=None)
    ref_id: Mapped[str | None] = mapped_column(String(36), default=None)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class GoodsReceiptModel(RecordMixin, Base):
    __tablename__ = "goods_receipts"
    number: Mapped[str] = mapped_column(String(32), index=True)
    supplier_id: Mapped[str | None] = mapped_column(String(36), default=None)
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    total_cost_minor: Mapped[int] = mapped_column(default=0)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class GoodsReceiptLineModel(RecordMixin, Base):
    __tablename__ = "goods_receipt_lines"
    receipt_id: Mapped[str] = mapped_column(String(36), index=True)
    product_id: Mapped[str] = mapped_column(String(36))
    qty_minor: Mapped[int] = mapped_column()
    unit_cost_minor: Mapped[int] = mapped_column()


# ── Sync (Phase 6) ───────────────────────────────────────────────────────────


class ProcessedOpModel(Base):
    """Idempotency ledger: an op_id is applied at most once."""

    __tablename__ = "processed_ops"
    op_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    result: Mapped[str] = mapped_column(String(12))
    code: Mapped[str | None] = mapped_column(String(64), default=None)
    server_seq: Mapped[int | None] = mapped_column(Integer, default=None)
    actor_id: Mapped[str | None] = mapped_column(String(36), default=None)
    device_id: Mapped[str | None] = mapped_column(String(128), default=None)
    applied_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class ChangeLogModel(Base):
    """Monotonic feed of applied row changes; drives pull."""

    __tablename__ = "change_log"
    seq: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    table_name: Mapped[str] = mapped_column(String(32), index=True)
    row_id: Mapped[str] = mapped_column(String(36))
    op: Mapped[str] = mapped_column(String(8))
    data: Mapped[dict] = mapped_column(JSON)
    branch_id: Mapped[str | None] = mapped_column(String(36), default=None)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ── Notifications (Phase 9) ──────────────────────────────────────────────────


class NotificationModel(Base):
    """Persisted insight/alert feed. `dedupe_key` keeps refresh idempotent
    within a branch and day (branch/code/entity/day)."""

    __tablename__ = "notifications"
    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    code: Mapped[str] = mapped_column(String(48))
    severity: Mapped[str] = mapped_column(String(8), default="info")
    data: Mapped[dict] = mapped_column(JSON, default=dict)
    dedupe_key: Mapped[str] = mapped_column(String(160), unique=True, index=True)
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
