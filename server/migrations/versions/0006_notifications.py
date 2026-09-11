"""0006 — notifications (Phase 9 insight/alert feed).

Revision ID: 0006
Revises: 0005
Create Date: 2026-09-11
"""

from alembic import op

import dukan.infrastructure.db.models  # noqa: F401  (populate metadata)
from dukan.infrastructure.db.base import Base

revision = "0006"
down_revision = "0005"
branch_labels = None
depends_on = None

_NEW_TABLES = ["notifications"]


def upgrade() -> None:
    bind = op.get_bind()
    Base.metadata.create_all(bind=bind, tables=[Base.metadata.tables[n] for n in _NEW_TABLES])


def downgrade() -> None:
    bind = op.get_bind()
    Base.metadata.drop_all(bind=bind, tables=[Base.metadata.tables[n] for n in _NEW_TABLES])
