"""0013 — the drawer a debt collection went into: customer_ledger.shift_id and
method (cash, card, transfer), so a shift's expected cash counts the debts it
collected in cash. sales.shift_id is indexed for the same count.

Revision ID: 0013
Revises: 0012
Create Date: 2026-09-14
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0013"
down_revision = "0012"
branch_labels = None
depends_on = None


def _columns(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def _indexes(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()
    return {ix["name"] for ix in sa.inspect(op.get_bind()).get_indexes(table) if ix["name"]}


def upgrade() -> None:
    have = _columns("customer_ledger")
    if "shift_id" not in have:
        op.add_column("customer_ledger", sa.Column("shift_id", sa.String(36), nullable=True))
    if "method" not in have:
        op.add_column("customer_ledger", sa.Column("method", sa.String(8), nullable=True))
    if "ix_customer_ledger_shift_id" not in _indexes("customer_ledger"):
        op.create_index("ix_customer_ledger_shift_id", "customer_ledger", ["shift_id"])
    if "ix_sales_shift_id" not in _indexes("sales"):
        op.create_index("ix_sales_shift_id", "sales", ["shift_id"])


def downgrade() -> None:
    op.drop_index("ix_sales_shift_id", table_name="sales")
    op.drop_index("ix_customer_ledger_shift_id", table_name="customer_ledger")
    with op.batch_alter_table("customer_ledger") as batch:
        batch.drop_column("method")
        batch.drop_column("shift_id")
