"""0002 — catalog + inventory (units, categories, products, barcodes,
stock_movements).

The schema is frozen as this phase shipped it and never reads the live models,
so a later model change needs a later revision. A database an older release
built from the live models may already have these tables; those are left alone.

Revision ID: 0002
Revises: 0001
Create Date: 2026-09-11
"""

import sqlalchemy as sa
from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None

_TABLES = ["barcodes", "categories", "products", "stock_movements", "units"]


def _tables() -> set[str]:
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
    if "barcodes" not in have:
        op.create_table(
            "barcodes",
            sa.Column("product_id", sa.String(36), nullable=False),
            sa.Column("code", sa.String(64), nullable=False),
            sa.Column("symbology", sa.String(16), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_barcodes_code", "barcodes", ["code"])
        _index("ix_barcodes_product_id", "barcodes", ["product_id"])
    if "categories" not in have:
        op.create_table(
            "categories",
            sa.Column("name", sa.String(128), nullable=False),
            sa.Column("parent_id", sa.String(36), nullable=True),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
    if "products" not in have:
        op.create_table(
            "products",
            sa.Column("sku", sa.String(64), nullable=False),
            sa.Column("name", sa.String(200), nullable=False),
            sa.Column("unit_id", sa.String(36), nullable=False),
            sa.Column("category_id", sa.String(36), nullable=True),
            sa.Column("sell_price_minor", sa.Integer(), nullable=False),
            sa.Column("sell_currency", sa.String(3), nullable=False),
            sa.Column("cost_minor", sa.Integer(), nullable=True),
            sa.Column("cost_currency", sa.String(3), nullable=True),
            sa.Column("track_stock", sa.Boolean(), nullable=False),
            sa.Column("is_active", sa.Boolean(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_products_name", "products", ["name"])
        _index("ix_products_sku", "products", ["sku"])
    if "stock_movements" not in have:
        op.create_table(
            "stock_movements",
            sa.Column("product_id", sa.String(36), nullable=False),
            sa.Column("branch_id", sa.String(36), nullable=False),
            sa.Column("qty_delta", sa.Integer(), nullable=False),
            sa.Column("reason", sa.String(16), nullable=False),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_stock_movements_branch_id", "stock_movements", ["branch_id"])
        _index("ix_stock_movements_product_id", "stock_movements", ["product_id"])
    if "units" not in have:
        op.create_table(
            "units",
            sa.Column("name", sa.String(48), nullable=False),
            sa.Column("decimal_places", sa.Integer(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )


def downgrade() -> None:
    have = _tables()
    for name in reversed(_TABLES):
        if name in have:
            op.drop_table(name)
