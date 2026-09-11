"""0001 — identity & access foundation (users, roles, branches, assignments,
sessions, audit_entries).

Forward-only. Rollback note: dropping these tables discards all identity and
audit data; only run downgrade on a throwaway database.

Revision ID: 0001
Revises:
Create Date: 2026-09-11
"""

from alembic import op

import dukan.infrastructure.db.models  # noqa: F401  (populate metadata)
from dukan.infrastructure.db.base import Base

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Initial schema is created directly from the models' metadata so the
    # migration can never drift from the mapped tables.
    Base.metadata.create_all(bind=op.get_bind())


def downgrade() -> None:
    Base.metadata.drop_all(bind=op.get_bind())
