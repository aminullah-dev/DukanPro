"""0016 — a return names the sale it takes goods back from: sales.refund_of.

Revision ID: 0016
Revises: 0015
Create Date: 2026-09-15
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0016"
down_revision = "0015"
branch_labels = None
depends_on = None


def _columns(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def upgrade() -> None:
    if "refund_of" not in _columns("sales"):
        op.add_column("sales", sa.Column("refund_of", sa.String(length=36), nullable=True))
        op.create_index("ix_sales_refund_of", "sales", ["refund_of"])


def downgrade() -> None:
    op.drop_index("ix_sales_refund_of", table_name="sales")
    with op.batch_alter_table("sales") as batch:
        batch.drop_column("refund_of")
