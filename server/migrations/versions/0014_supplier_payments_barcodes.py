"""0014 — supplier payments, and one live barcode per code.

supplier_ledger gains shift_id and method, as customer_ledger did in 0013: cash
paid to a supplier out of a till's drawer comes off that shift's expected cash.

barcodes.code becomes unique among live barcodes, so a scan resolves to one
item. Duplicates already there keep their oldest row; the others are
soft-deleted and logged to change_log, so devices drop them on their next pull.

Revision ID: 0014
Revises: 0013
Create Date: 2026-09-14
"""

from datetime import UTC, datetime

import sqlalchemy as sa
from alembic import context, op

revision = "0014"
down_revision = "0013"
branch_labels = None
depends_on = None

_LIVE = sa.text("deleted_at IS NULL")

_barcodes = sa.table(
    "barcodes",
    sa.column("id", sa.String),
    sa.column("product_id", sa.String),
    sa.column("code", sa.String),
    sa.column("symbology", sa.String),
    sa.column("created_at", sa.DateTime(timezone=True)),
    sa.column("updated_at", sa.DateTime(timezone=True)),
    sa.column("deleted_at", sa.DateTime(timezone=True)),
    sa.column("version", sa.Integer),
)
_feed = sa.table(
    "change_log",
    sa.column("table_name", sa.String),
    sa.column("row_id", sa.String),
    sa.column("op", sa.String),
    sa.column("data", sa.JSON),
    sa.column("branch_id", sa.String),
    sa.column("occurred_at", sa.DateTime(timezone=True)),
)


def _columns(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def _indexes(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()
    return {ix["name"] for ix in sa.inspect(op.get_bind()).get_indexes(table) if ix["name"]}


def _drop_duplicate_barcodes(bind: sa.Connection) -> None:
    now = datetime.now(UTC)
    rows = bind.execute(
        sa.select(
            _barcodes.c.id, _barcodes.c.product_id, _barcodes.c.code, _barcodes.c.symbology,
            _barcodes.c.version,
        )
        .where(_barcodes.c.deleted_at.is_(None))
        .order_by(_barcodes.c.code, _barcodes.c.created_at, _barcodes.c.id)
    ).all()
    seen: set[str] = set()
    for row in rows:
        if row.code not in seen:
            seen.add(row.code)
            continue
        version = row.version + 1
        bind.execute(
            sa.update(_barcodes).where(_barcodes.c.id == row.id)
            .values(deleted_at=now, updated_at=now, version=version)
        )
        bind.execute(sa.insert(_feed).values(
            table_name="barcodes", row_id=row.id, op="update", branch_id=None, occurred_at=now,
            data={
                "product_id": row.product_id, "code": row.code, "symbology": row.symbology,
                "version": version, "deleted_at": now.isoformat(),
            },
        ))


def upgrade() -> None:
    have = _columns("supplier_ledger")
    if "shift_id" not in have:
        op.add_column("supplier_ledger", sa.Column("shift_id", sa.String(36), nullable=True))
        op.create_index("ix_supplier_ledger_shift_id", "supplier_ledger", ["shift_id"])
    if "method" not in have:
        op.add_column("supplier_ledger", sa.Column("method", sa.String(8), nullable=True))
    if "ux_barcodes_code_live" in _indexes("barcodes"):
        return
    if not context.is_offline_mode():  # a script's database has no barcodes yet
        _drop_duplicate_barcodes(op.get_bind())
    op.create_index(
        "ux_barcodes_code_live", "barcodes", ["code"], unique=True,
        sqlite_where=_LIVE, postgresql_where=_LIVE,
    )


def downgrade() -> None:
    # The duplicates stay dropped.
    op.drop_index("ux_barcodes_code_live", table_name="barcodes")
    op.drop_index("ix_supplier_ledger_shift_id", table_name="supplier_ledger")
    with op.batch_alter_table("supplier_ledger") as batch:
        batch.drop_column("method")
        batch.drop_column("shift_id")
