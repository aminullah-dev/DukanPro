"""0004 — customers, debt, purchasing.

Revision ID: 0004
Revises: 0003
Create Date: 2026-09-11
"""

from alembic import op

import dukan.infrastructure.db.models  # noqa: F401  (populate metadata)
from dukan.infrastructure.db.base import Base

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None

_NEW_TABLES = [
    "customers", "customer_ledger", "suppliers", "supplier_ledger",
    "goods_receipts", "goods_receipt_lines",
]


def upgrade() -> None:
    bind = op.get_bind()
    Base.metadata.create_all(bind=bind, tables=[Base.metadata.tables[n] for n in _NEW_TABLES])


def downgrade() -> None:
    bind = op.get_bind()
    Base.metadata.drop_all(bind=bind, tables=[Base.metadata.tables[n] for n in _NEW_TABLES])
