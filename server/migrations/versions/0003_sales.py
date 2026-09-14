"""0003 — sales / POS (shifts, sales, sale_lines, payments), and the sale a
stock movement belongs to (stock_movements.ref_type, ref_id). Before this
revision was frozen, an upgrade from 0002 never added those two columns.

The schema is frozen as this phase shipped it and never reads the live models,
so a later model change needs a later revision. A database an older release
built from the live models may already have these tables; those are left alone.

Revision ID: 0003
Revises: 0002
Create Date: 2026-09-11
"""

import sqlalchemy as sa
from alembic import op

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None

_TABLES = ["payments", "sale_lines", "sales", "shifts"]


def _tables() -> set[str]:
    return set(sa.inspect(op.get_bind()).get_table_names())


def _columns(table: str) -> set[str]:
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


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
    if "payments" not in have:
        op.create_table(
            "payments",
            sa.Column("sale_id", sa.String(36), nullable=False),
            sa.Column("method", sa.String(8), nullable=False),
            sa.Column("amount_minor", sa.Integer(), nullable=False),
            sa.Column("currency", sa.String(3), nullable=False),
            sa.Column("tendered_minor", sa.Integer(), nullable=True),
            sa.Column("change_minor", sa.Integer(), nullable=True),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_payments_sale_id", "payments", ["sale_id"])
    if "sale_lines" not in have:
        op.create_table(
            "sale_lines",
            sa.Column("sale_id", sa.String(36), nullable=False),
            sa.Column("product_id", sa.String(36), nullable=False),
            sa.Column("name", sa.String(200), nullable=False),
            sa.Column("qty_minor", sa.Integer(), nullable=False),
            sa.Column("decimal_places", sa.Integer(), nullable=False),
            sa.Column("unit_price_minor", sa.Integer(), nullable=False),
            sa.Column("unit_cost_minor", sa.Integer(), nullable=False),
            sa.Column("line_total_minor", sa.Integer(), nullable=False),
            sa.Column("currency", sa.String(3), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_sale_lines_sale_id", "sale_lines", ["sale_id"])
    if "sales" not in have:
        op.create_table(
            "sales",
            sa.Column("number", sa.String(32), nullable=False),
            sa.Column("branch_id", sa.String(36), nullable=False),
            sa.Column("shift_id", sa.String(36), nullable=True),
            sa.Column("customer_id", sa.String(36), nullable=True),
            sa.Column("status", sa.String(8), nullable=False),
            sa.Column("currency", sa.String(3), nullable=False),
            sa.Column("discount_minor", sa.Integer(), nullable=False),
            sa.Column("subtotal_minor", sa.Integer(), nullable=False),
            sa.Column("tax_minor", sa.Integer(), nullable=False),
            sa.Column("total_minor", sa.Integer(), nullable=False),
            sa.Column("paid_minor", sa.Integer(), nullable=False),
            sa.Column("change_minor", sa.Integer(), nullable=False),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_sales_branch_id", "sales", ["branch_id"])
        _index("ix_sales_number", "sales", ["number"])
    if "shifts" not in have:
        op.create_table(
            "shifts",
            sa.Column("branch_id", sa.String(36), nullable=False),
            sa.Column("user_id", sa.String(36), nullable=False),
            sa.Column("opened_at", sa.DateTime(timezone=True), nullable=False),
            sa.Column("opening_float_minor", sa.Integer(), nullable=False),
            sa.Column("closed_at", sa.DateTime(timezone=True), nullable=True),
            sa.Column("counted_cash_minor", sa.Integer(), nullable=True),
            sa.Column("expected_cash_minor", sa.Integer(), nullable=True),
            sa.Column("variance_minor", sa.Integer(), nullable=True),
            sa.Column("status", sa.String(8), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_shifts_branch_id", "shifts", ["branch_id"])
    columns = _columns("stock_movements")
    if "ref_type" not in columns:
        op.add_column("stock_movements", sa.Column("ref_type", sa.String(16), nullable=True))
    if "ref_id" not in columns:
        op.add_column("stock_movements", sa.Column("ref_id", sa.String(36), nullable=True))


def downgrade() -> None:
    columns = _columns("stock_movements")
    with op.batch_alter_table("stock_movements") as batch:
        for name in ("ref_id", "ref_type"):
            if name in columns:
                batch.drop_column(name)
    have = _tables()
    for name in reversed(_TABLES):
        if name in have:
            op.drop_table(name)
