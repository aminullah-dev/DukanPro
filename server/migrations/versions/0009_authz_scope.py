"""0009 — authorization on the right scope (review theme 2): sessions keep the
refresh hash the last refresh rotated out (reuse detection), every branch gets
an owner, and the owners of the shop's first branch own every branch (before
0009 they acted everywhere). The owner back-fill is a data fix and is not undone.

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
    """Before 0009 a new branch was given to nobody, and a request acted with the
    rights its branch header named, so an owner of the shop's first branch acted
    in every branch. From 0009 an owner acts only where they own, so:

    1. a branch with no active owner goes to its creator, when active;
    2. the active owners of the shop's first branch (the one bootstrap made) own
       every branch; when it has none, every active owner does.

    Running it again changes nothing."""
    branches = sa.table(
        "branches",
        sa.column("id", sa.String),
        sa.column("created_by", sa.String),
        sa.column("created_at", sa.DateTime),
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
    live = list(
        bind.execute(
            sa.select(branches.c.id, branches.c.created_by)
            .where(branches.c.deleted_at.is_(None))
            .order_by(branches.c.created_at, branches.c.id)
        ).tuples()
    )
    live_ids = {branch_id for branch_id, _ in live}
    # (user, branch) -> (assignment id, role) of every live assignment
    held: dict[tuple[str, str], tuple[str, str]] = {
        (user_id, branch_id): (row_id, role)
        for row_id, user_id, branch_id, role in bind.execute(
            sa.select(
                assignments.c.id, assignments.c.user_id, assignments.c.branch_id,
                assignments.c.role_name,
            ).where(assignments.c.deleted_at.is_(None))
        ).tuples()
    }
    now = datetime.now(UTC)

    def owns(user_id: str, branch_id: str) -> bool:
        return held.get((user_id, branch_id), ("", ""))[1] == "owner"

    def owners_of(branch_id: str) -> set[str]:
        return {u for u in active if owns(u, branch_id)}

    def make_owner(user_id: str, branch_id: str) -> None:
        current = held.get((user_id, branch_id))
        if current is None:
            row_id = new_id()
            bind.execute(
                sa.insert(assignments).values(
                    id=row_id, user_id=user_id, branch_id=branch_id, role_name="owner",
                    created_by=user_id, created_at=now, updated_at=now, version=1,
                )
            )
        else:
            row_id = current[0]
            bind.execute(
                sa.update(assignments)
                .where(assignments.c.id == row_id)
                .values(role_name="owner", updated_at=now, version=assignments.c.version + 1)
            )
        held[(user_id, branch_id)] = (row_id, "owner")

    for branch_id, creator in live:
        if not owners_of(branch_id) and creator in active:
            make_owner(creator, branch_id)
    if not live:
        return
    shop_owners = owners_of(live[0][0]) or {
        u for (u, b), (_, role) in held.items() if role == "owner" and u in active and b in live_ids
    }
    for user_id in sorted(shop_owners):
        for branch_id, _ in live:
            if not owns(user_id, branch_id):
                make_owner(user_id, branch_id)


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
