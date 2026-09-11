"""0002 — catalog + inventory (units, categories, products, barcodes,
stock_movements).

Forward-only; builds the new tables from the models' metadata (create_all only
creates missing tables, so 0001's tables are untouched).

Revision ID: 0002
Revises: 0001
Create Date: 2026-09-11
"""

from alembic import op

import dukan.infrastructure.db.models  # noqa: F401  (populate metadata)
from dukan.infrastructure.db.base import Base

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None

_NEW_TABLES = ["units", "categories", "products", "barcodes", "stock_movements"]


def upgrade() -> None:
    bind = op.get_bind()
    tables = [Base.metadata.tables[name] for name in _NEW_TABLES]
    Base.metadata.create_all(bind=bind, tables=tables)


def downgrade() -> None:
    bind = op.get_bind()
    tables = [Base.metadata.tables[name] for name in _NEW_TABLES]
    Base.metadata.drop_all(bind=bind, tables=tables)
