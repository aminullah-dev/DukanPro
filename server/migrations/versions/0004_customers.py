"""0004 — customers, debt, purchasing.

The schema is frozen as this phase shipped it and never reads the live models,
so a later model change needs a later revision. A database an older release
built from the live models may already have these tables; those are left alone.

Revision ID: 0004
Revises: 0003
Create Date: 2026-09-11
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None

_TABLES = [
    "customer_ledger", "customers", "goods_receipt_lines", "goods_receipts", "supplier_ledger",
    "suppliers",
]


def _tables() -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return set(sa.inspect(op.get_bind()).get_table_names())


def _record() -> list[sa.Column]:
    """The columns every record table carries (RecordMixin)."""
    return [
        sa.Column("id", sa.String(36), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_by", sa.String(36), nullable=True),
        sa.Column("updated_by", sa.String(36), nullable=True),
        sa.Column("version", sa.Integer(), nullable=False),
    ]


def _index(name: str, table: str, columns: list[str], *, unique: bool = False) -> None:
    op.create_index(name, table, columns, unique=unique)


def upgrade() -> None:
    have = _tables()
    if "customer_ledger" not in have:
        op.create_table(
            "customer_ledger",
            sa.Column("customer_id", sa.String(36), nullable=False),
            sa.Column("type", sa.String(12), nullable=False),
            sa.Column("amount_minor", sa.Integer(), nullable=False),
            sa.Column("currency", sa.String(3), nullable=False),
            sa.Column("ref_type", sa.String(16), nullable=True),
            sa.Column("ref_id", sa.String(36), nullable=True),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_customer_ledger_customer_id", "customer_ledger", ["customer_id"])
    if "customers" not in have:
        op.create_table(
            "customers",
            sa.Column("name", sa.String(128), nullable=False),
            sa.Column("phone", sa.String(32), nullable=True),
            sa.Column("credit_limit_minor", sa.Integer(), nullable=True),
            sa.Column("currency", sa.String(3), nullable=False),
            sa.Column("is_active", sa.Boolean(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_customers_name", "customers", ["name"])
    if "goods_receipt_lines" not in have:
        op.create_table(
            "goods_receipt_lines",
            sa.Column("receipt_id", sa.String(36), nullable=False),
            sa.Column("product_id", sa.String(36), nullable=False),
            sa.Column("qty_minor", sa.Integer(), nullable=False),
            sa.Column("unit_cost_minor", sa.Integer(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_goods_receipt_lines_receipt_id", "goods_receipt_lines", ["receipt_id"])
    if "goods_receipts" not in have:
        op.create_table(
            "goods_receipts",
            sa.Column("number", sa.String(32), nullable=False),
            sa.Column("supplier_id", sa.String(36), nullable=True),
            sa.Column("branch_id", sa.String(36), nullable=False),
            sa.Column("total_cost_minor", sa.Integer(), nullable=False),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_goods_receipts_branch_id", "goods_receipts", ["branch_id"])
        _index("ix_goods_receipts_number", "goods_receipts", ["number"])
    if "supplier_ledger" not in have:
        op.create_table(
            "supplier_ledger",
            sa.Column("supplier_id", sa.String(36), nullable=False),
            sa.Column("type", sa.String(12), nullable=False),
            sa.Column("amount_minor", sa.Integer(), nullable=False),
            sa.Column("currency", sa.String(3), nullable=False),
            sa.Column("ref_type", sa.String(16), nullable=True),
            sa.Column("ref_id", sa.String(36), nullable=True),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_supplier_ledger_supplier_id", "supplier_ledger", ["supplier_id"])
    if "suppliers" not in have:
        op.create_table(
            "suppliers",
            sa.Column("name", sa.String(128), nullable=False),
            sa.Column("phone", sa.String(32), nullable=True),
            sa.Column("currency", sa.String(3), nullable=False),
            sa.Column("is_active", sa.Boolean(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_suppliers_name", "suppliers", ["name"])


def downgrade() -> None:
    have = _tables()
    for name in reversed(_TABLES):
        if name in have:
            op.drop_table(name)
