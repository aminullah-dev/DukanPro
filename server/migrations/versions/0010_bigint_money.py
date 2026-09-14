"""0010 — money and quantities as 64-bit integers, and the sale reference on
stock movements for databases that never got it.

PostgreSQL INTEGER is 32-bit, so a sale, receipt or price over about 21.5
million AFN (in minor units) did not fit. SQLite already stores every integer
in 64 bits; there only the declared type would change, so it is left alone.
Each PostgreSQL table is altered in one statement, so it is rewritten once.

Before 0003 was frozen, an upgrade from 0002 skipped stock_movements.ref_type and
ref_id; a database upgraded that way gets them here.

Revision ID: 0010
Revises: 0009
Create Date: 2026-09-14
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0010"
down_revision = "0009"
branch_labels = None
depends_on = None

_BIG: dict[str, tuple[str, ...]] = {
    "products": ("sell_price_minor", "cost_minor"),
    "stock_movements": ("qty_delta",),
    "shifts": (
        "opening_float_minor", "counted_cash_minor", "expected_cash_minor", "variance_minor",
    ),
    "sales": (
        "discount_minor", "subtotal_minor", "tax_minor", "total_minor", "paid_minor",
        "change_minor",
    ),
    "sale_lines": ("qty_minor", "unit_price_minor", "unit_cost_minor", "line_total_minor"),
    "payments": ("amount_minor", "tendered_minor", "change_minor"),
    "customers": ("credit_limit_minor",),
    "customer_ledger": ("amount_minor",),
    "supplier_ledger": ("amount_minor",),
    "goods_receipts": ("total_cost_minor",),
    "goods_receipt_lines": ("qty_minor", "unit_cost_minor"),
    "processed_ops": ("server_seq",),
    "change_log": ("seq",),
}


def _columns(table: str) -> set[str]:
    if context.is_offline_mode():
        # alembic --sql builds from 0001, and 0003 adds the sale reference.
        return {"ref_type", "ref_id"}
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def _postgres() -> bool:
    return op.get_context().dialect.name == "postgresql"


def _retype(type_name: str) -> None:
    for table, names in _BIG.items():
        changes = ", ".join(f"ALTER COLUMN {name} TYPE {type_name}" for name in names)
        op.execute(f"ALTER TABLE {table} {changes}")


def upgrade() -> None:
    columns = _columns("stock_movements")
    for name, length in (("ref_type", 16), ("ref_id", 36)):
        if name not in columns:
            op.add_column("stock_movements", sa.Column(name, sa.String(length), nullable=True))
    if not _postgres():
        return
    _retype("BIGINT")
    op.execute("ALTER SEQUENCE IF EXISTS change_log_seq_seq AS BIGINT")


def downgrade() -> None:
    # The sale reference belongs to 0003 and stays. Back to 32 bits works only
    # while every value still fits.
    if not _postgres():
        return
    op.execute("ALTER SEQUENCE IF EXISTS change_log_seq_seq AS INTEGER")
    _retype("INTEGER")
