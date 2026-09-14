"""0009 — authorization on the right scope (review theme 2): sessions keep the
refresh hash the last refresh rotated out (reuse detection), and every branch
gets an owner: a branch created before its creator was made its owner is given
to that creator. The owner back-fill is a data fix and is not undone.

Revision ID: 0009
Revises: 0008
Create Date: 2026-09-14
"""

from datetime import UTC, datetime

import sqlalchemy as sa
from alembic import op

from dukan.shared.ids import new_id

revision = "0009"
down_revision = "0008"
branch_labels = None
depends_on = None


def _columns(table: str) -> set[str]:
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def _backfill_branch_owners(bind: sa.engine.Connection) -> None:
    branches = sa.table(
        "branches",
        sa.column("id", sa.String),
        sa.column("created_by", sa.String),
        sa.column("deleted_at", sa.DateTime),
    )
    users = sa.table(
        "users",
        sa.column("id", sa.String),
        sa.column("status", sa.String),
        sa.column("deleted_at", sa.DateTime),
    )
    assignments = sa.table(
        "branch_assignments",
        sa.column("id", sa.String),
        sa.column("user_id", sa.String),
        sa.column("branch_id", sa.String),
        sa.column("role_name", sa.String),
        sa.column("created_by", sa.String),
        sa.column("created_at", sa.DateTime),
        sa.column("updated_at", sa.DateTime),
        sa.column("version", sa.Integer),
        sa.column("deleted_at", sa.DateTime),
    )
    active = set(
        bind.execute(
            sa.select(users.c.id).where(users.c.status == "active", users.c.deleted_at.is_(None))
        ).scalars()
    )
    owned = set(
        bind.execute(
            sa.select(assignments.c.branch_id).where(
                assignments.c.role_name == "owner",
                assignments.c.deleted_at.is_(None),
                assignments.c.user_id.in_(active),
            )
        ).scalars()
    )
    now = datetime.now(UTC)
    rows = bind.execute(
        sa.select(branches.c.id, branches.c.created_by).where(branches.c.deleted_at.is_(None))
    ).tuples()
    for branch_id, creator in rows:
        if branch_id not in owned and creator in active:
            bind.execute(
                sa.insert(assignments).values(
                    id=new_id(), user_id=creator, branch_id=branch_id, role_name="owner",
                    created_by=creator, created_at=now, updated_at=now, version=1,
                )
            )


def upgrade() -> None:
    # 0001 builds its tables from the live models, so a FRESH database already has
    # the column (and its index) when this revision runs.
    if "prev_refresh_hash" not in _columns("sessions"):
        op.add_column("sessions", sa.Column("prev_refresh_hash", sa.String(128), nullable=True))
        op.create_index("ix_sessions_prev_refresh_hash", "sessions", ["prev_refresh_hash"])
    _backfill_branch_owners(op.get_bind())


def downgrade() -> None:
    if "prev_refresh_hash" not in _columns("sessions"):
        return
    indexes = [
        ix["name"]
        for ix in sa.inspect(op.get_bind()).get_indexes("sessions")
        if ix["column_names"] == ["prev_refresh_hash"] and ix["name"]
    ]
    with op.batch_alter_table("sessions") as batch:
        for name in indexes:
            batch.drop_index(name)
        batch.drop_column("prev_refresh_hash")
