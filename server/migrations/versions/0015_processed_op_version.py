"""0015 — a replayed op returns the version its first push produced:
processed_ops.version.

Revision ID: 0015
Revises: 0014
Create Date: 2026-09-14
"""

import sqlalchemy as sa
from alembic import context, op

revision = "0015"
down_revision = "0014"
branch_labels = None
depends_on = None


def _columns(table: str) -> set[str]:
    if context.is_offline_mode():
        return set()  # alembic --sql: the script is for an empty database
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def upgrade() -> None:
    if "version" not in _columns("processed_ops"):
        op.add_column("processed_ops", sa.Column("version", sa.Integer(), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("processed_ops") as batch:
        batch.drop_column("version")
