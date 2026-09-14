"""0008 — sync hardening (review theme 1): processed_ops keeps each op's outcome
code, server_seq, actor and device; change_log gains the row's branch for pull
scoping.

Revision ID: 0008
Revises: 0007
Create Date: 2026-09-12
"""

import sqlalchemy as sa
from alembic import op

revision = "0008"
down_revision = "0007"
branch_labels = None
depends_on = None

# 0002-0006 build their tables from the live models, so on a FRESH database these
# columns already exist when this revision runs. Add (or drop) only what's needed.
_COLUMNS: dict[str, list[tuple[str, sa.types.TypeEngine]]] = {
    "processed_ops": [
        ("code", sa.String(64)),
        ("server_seq", sa.Integer()),
        ("actor_id", sa.String(36)),
        ("device_id", sa.String(128)),
    ],
    "change_log": [("branch_id", sa.String(36))],
}


def _existing(table: str) -> set[str]:
    return {c["name"] for c in sa.inspect(op.get_bind()).get_columns(table)}


def upgrade() -> None:
    for table, cols in _COLUMNS.items():
        have = _existing(table)
        for name, type_ in cols:
            if name not in have:
                op.add_column(table, sa.Column(name, type_, nullable=True))


def downgrade() -> None:
    for table, cols in _COLUMNS.items():
        have = _existing(table)
        with op.batch_alter_table(table) as batch:
            for name, _type in cols:
                if name in have:
                    batch.drop_column(name)
