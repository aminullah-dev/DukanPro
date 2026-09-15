"""0006 — notifications (Phase 9 insight/alert feed).

The schema is frozen as this phase shipped it and never reads the live models,
so a later model change needs a later revision. A database an older release
built from the live models may already have these tables; those are left alone.

Revision ID: 0006
Revises: 0005
Create Date: 2026-09-11
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0006"
down_revision = "0005"
branch_labels = None
depends_on = None

_TABLES = ["notifications"]


def _tables() -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return set(sa.inspect(op.get_bind()).get_table_names())


def _index(name: str, table: str, columns: list[str], *, unique: bool = False) -> None:
    op.create_index(name, table, columns, unique=unique)


def upgrade() -> None:
    have = _tables()
    if "notifications" not in have:
        op.create_table(
            "notifications",
            sa.Column("id", sa.String(36), nullable=False),
            sa.Column("branch_id", sa.String(36), nullable=False),
            sa.Column("code", sa.String(48), nullable=False),
            sa.Column("severity", sa.String(8), nullable=False),
            sa.Column("data", sa.JSON(), nullable=False),
            sa.Column("dedupe_key", sa.String(160), nullable=False),
            sa.Column("read_at", sa.DateTime(timezone=True), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_notifications_branch_id", "notifications", ["branch_id"])
        _index("ix_notifications_dedupe_key", "notifications", ["dedupe_key"], unique=True)


def downgrade() -> None:
    have = _tables()
    for name in reversed(_TABLES):
        if name in have:
            op.drop_table(name)
