"""0001 — identity & access foundation (users, roles, branches, assignments,
sessions, audit_entries).

Rollback note: dropping these tables discards all identity and audit data;
only run downgrade on a throwaway database.

The schema is frozen as this phase shipped it and never reads the live models,
so a later model change needs a later revision. A database an older release
built from the live models may already have these tables; those are left alone.

Revision ID: 0001
Revises: 
Create Date: 2026-09-11
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None

_TABLES = ["audit_entries", "branch_assignments", "branches", "roles", "sessions", "users"]


def _tables() -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
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
    if "audit_entries" not in have:
        op.create_table(
            "audit_entries",
            sa.Column("id", sa.String(36), nullable=False),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
            sa.Column("actor_id", sa.String(36), nullable=True),
            sa.Column("actor_role", sa.String(32), nullable=True),
            sa.Column("action", sa.String(64), nullable=False),
            sa.Column("entity_type", sa.String(32), nullable=True),
            sa.Column("entity_id", sa.String(36), nullable=True),
            sa.Column("before", sa.JSON(), nullable=True),
            sa.Column("after", sa.JSON(), nullable=True),
            sa.Column("origin", sa.String(16), nullable=False),
            sa.PrimaryKeyConstraint("id"),
        )
    if "branch_assignments" not in have:
        op.create_table(
            "branch_assignments",
            sa.Column("user_id", sa.String(36), nullable=False),
            sa.Column("branch_id", sa.String(36), nullable=False),
            sa.Column("role_name", sa.String(32), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_branch_assignments_branch_id", "branch_assignments", ["branch_id"])
        _index("ix_branch_assignments_user_id", "branch_assignments", ["user_id"])
    if "branches" not in have:
        op.create_table(
            "branches",
            sa.Column("name", sa.String(128), nullable=False),
            sa.Column("timezone", sa.String(48), nullable=False),
            sa.Column("currency_default", sa.String(3), nullable=False),
            sa.Column("is_active", sa.Boolean(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
    if "roles" not in have:
        op.create_table(
            "roles",
            sa.Column("name", sa.String(32), nullable=False),
            sa.Column("permissions", sa.JSON(), nullable=False),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("name"),
        )
    if "sessions" not in have:
        op.create_table(
            "sessions",
            sa.Column("user_id", sa.String(36), nullable=False),
            sa.Column("device_id", sa.String(128), nullable=False),
            sa.Column("refresh_hash", sa.String(128), nullable=False),
            sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
            sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_sessions_refresh_hash", "sessions", ["refresh_hash"])
        _index("ix_sessions_user_id", "sessions", ["user_id"])
    if "users" not in have:
        op.create_table(
            "users",
            sa.Column("username", sa.String(64), nullable=False),
            sa.Column("display_name", sa.String(128), nullable=False),
            sa.Column("password_hash", sa.String(255), nullable=False),
            sa.Column("status", sa.String(16), nullable=False),
            sa.Column("default_branch_id", sa.String(36), nullable=True),
            *_record(),
            sa.PrimaryKeyConstraint("id"),
        )
        _index("ix_users_username", "users", ["username"], unique=True)


def downgrade() -> None:
    have = _tables()
    for name in reversed(_TABLES):
        if name in have:
            op.drop_table(name)
