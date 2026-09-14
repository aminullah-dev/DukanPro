"""0011 — the built-in units (piece, kg, litre, dozen, meter) with the fixed ids
every device uses. Before, GET /units seeded them with new ids on first read
(two first readers seeded twice) and each device seeded its own set, so units
split after sync. Rows already there are left alone.

Revision ID: 0011
Revises: 0010
Create Date: 2026-09-14
"""

from datetime import UTC, datetime

import sqlalchemy as sa
from alembic import op

revision = "0011"
down_revision = "0010"
branch_labels = None
depends_on = None

# (id, name, decimal places): dukan.domain.catalog.BUILTIN_UNITS, frozen here.
_UNITS = (
    ("00000000-0000-7000-8000-000000000001", "piece", 0),
    ("00000000-0000-7000-8000-000000000002", "kg", 3),
    ("00000000-0000-7000-8000-000000000003", "litre", 3),
    ("00000000-0000-7000-8000-000000000004", "dozen", 0),
    ("00000000-0000-7000-8000-000000000005", "meter", 2),
)


def upgrade() -> None:
    units = sa.table(
        "units",
        sa.column("id", sa.String),
        sa.column("name", sa.String),
        sa.column("decimal_places", sa.Integer),
        sa.column("created_at", sa.DateTime),
        sa.column("updated_at", sa.DateTime),
        sa.column("version", sa.Integer),
    )
    bind = op.get_bind()
    have = set(bind.execute(sa.select(units.c.id)).scalars())
    now = datetime.now(UTC)
    for unit_id, name, places in _UNITS:
        if unit_id not in have:
            bind.execute(
                sa.insert(units).values(
                    id=unit_id, name=name, decimal_places=places, created_at=now, updated_at=now,
                    version=1,
                )
            )


def downgrade() -> None:
    # Products may point at these units: they stay.
    pass
