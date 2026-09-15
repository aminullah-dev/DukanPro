"""0008 — sync hardening (review theme 1): processed_ops keeps each op's outcome
code, server_seq, actor and device; change_log gains the row's branch for pull
scoping, back-filled for rows logged before this revision.

Revision ID: 0008
Revises: 0007
Create Date: 2026-09-12
"""

import json
from typing import Any

import sqlalchemy as sa
from alembic import context, op

revision = "0008"
down_revision = "0007"
branch_labels = None
depends_on = None

# A database an older release built from the live models may already have these
# columns. Add (or drop) only what's needed.
_COLUMNS: dict[str, list[tuple[str, sa.types.TypeEngine]]] = {
    "processed_ops": [
        ("code", sa.String(64)),
        ("server_seq", sa.Integer()),
        ("actor_id", sa.String(36)),
        ("device_id", sa.String(128)),
    ],
    "change_log": [("branch_id", sa.String(36))],
}

# Pull hides a branch row whose branch it cannot tell, so older feed rows get it
# here: sales and stock movements carry it in their data, lines and payments
# through their sale.
_BRANCH_ROWS = ("sales", "stock_movements", "sale_lines", "payments")


def _existing(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def _backfill_branch_ids(bind: sa.engine.Connection) -> None:
    change_log = sa.table(
        "change_log",
        sa.column("seq", sa.Integer),
        sa.column("table_name", sa.String),
        sa.column("data", sa.JSON),
        sa.column("branch_id", sa.String),
    )
    sales = sa.table("sales", sa.column("id", sa.String), sa.column("branch_id", sa.String))
    sale_branch = dict(bind.execute(sa.select(sales.c.id, sales.c.branch_id)).tuples().all())
    rows = bind.execute(
        sa.select(change_log.c.seq, change_log.c.table_name, change_log.c.data).where(
            change_log.c.branch_id.is_(None), change_log.c.table_name.in_(_BRANCH_ROWS)
        )
    ).all()
    for seq, table, raw in rows:
        data: Any = json.loads(raw) if isinstance(raw, str) else (raw or {})
        if table in ("sales", "stock_movements"):
            branch = data.get("branch_id")
        else:
            branch = sale_branch.get(data.get("sale_id"))
        if isinstance(branch, str):
            bind.execute(
                sa.update(change_log).where(change_log.c.seq == seq).values(branch_id=branch)
            )


def upgrade() -> None:
    for table, cols in _COLUMNS.items():
        have = _existing(table)
        for name, type_ in cols:
            if name not in have:
                op.add_column(table, sa.Column(name, type_, nullable=True))
    if not context.is_offline_mode():  # a script's database has no feed yet
        _backfill_branch_ids(op.get_bind())


def downgrade() -> None:
    for table, cols in _COLUMNS.items():
        have = _existing(table)
        with op.batch_alter_table(table) as batch:
            for name, _type in cols:
                if name in have:
                    batch.drop_column(name)
