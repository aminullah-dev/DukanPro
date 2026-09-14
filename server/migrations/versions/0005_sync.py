"""0005 — sync (processed_ops, change_log).

The schema is frozen as this phase shipped it and never reads the live models,
so a later model change needs a later revision. A database an older release
built from the live models may already have these tables; those are left alone.

Revision ID: 0005
Revises: 0004
Create Date: 2026-09-11
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0005"
down_revision = "0004"
branch_labels = None
depends_on = None

_TABLES = ["change_log", "processed_ops"]


def _tables() -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return set(sa.inspect(op.get_bind()).get_table_names())


def _index(name: str, table: str, columns: list[str], *, unique: bool = False) -> None:
    op.create_index(name, table, columns, unique=unique)


def upgrade() -> None:
    have = _tables()
    if "change_log" not in have:
        op.create_table(
            "change_log",
            sa.Column("seq", sa.Integer(), autoincrement=True, nullable=False),
            sa.Column("table_name", sa.String(32), nullable=False),
            sa.Column("row_id", sa.String(36), nullable=False),
            sa.Column("op", sa.String(8), nullable=False),
            sa.Column("data", sa.JSON(), nullable=False),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            sa.PrimaryKeyConstraint("seq"),
        )
        _index("ix_change_log_table_name", "change_log", ["table_name"])
    if "processed_ops" not in have:
        op.create_table(
            "processed_ops",
            sa.Column("op_id", sa.String(36), nullable=False),
            sa.Column("result", sa.String(12), nullable=False),
            sa.Column("applied_at", sa.DateTime(timezone=True), nullable=False),
            sa.PrimaryKeyConstraint("op_id"),
        )


def downgrade() -> None:
    have = _tables()
    for name in reversed(_TABLES):
        if name in have:
            op.drop_table(name)
