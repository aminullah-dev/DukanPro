"""0012 — one copy of each built-in unit, and every device told about them.

Before 0011 every device seeded the five built-in units with ids of its own and
pushed them, so a shop that synced held several "kg" rows (GET /units listed
each more than once). Products now point at the fixed unit, the copies are
soft-deleted, and each product change goes into change_log so devices converge
on their next pull. 0011 and bootstrap wrote the built-in units without a feed
row, so a device never pulled them; they get one here. A device merges its own
copies the same way when it upgrades (dukan_data schema 9).

Revision ID: 0012
Revises: 0011
Create Date: 2026-09-14
"""

import json
from datetime import UTC, datetime
from typing import Any

import sqlalchemy as sa
from alembic import context, op

revision = "0012"
down_revision = "0011"
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

# What a pull returns of a product (sync_policy.READ_FIELDS), frozen here.
_PRODUCT_FIELDS = (
    "sku", "name", "unit_id", "category_id", "sell_price_minor", "sell_currency",
    "cost_minor", "cost_currency", "track_stock", "is_active", "version",
)

_units = sa.table(
    "units",
    sa.column("id", sa.String),
    sa.column("name", sa.String),
    sa.column("decimal_places", sa.Integer),
    sa.column("updated_at", sa.DateTime(timezone=True)),
    sa.column("deleted_at", sa.DateTime(timezone=True)),
    sa.column("version", sa.Integer),
)
_products = sa.table(
    "products",
    sa.column("id", sa.String),
    sa.column("sku", sa.String),
    sa.column("name", sa.String),
    sa.column("unit_id", sa.String),
    sa.column("category_id", sa.String),
    sa.column("sell_price_minor", sa.BigInteger),
    sa.column("sell_currency", sa.String),
    sa.column("cost_minor", sa.BigInteger),
    sa.column("cost_currency", sa.String),
    sa.column("track_stock", sa.Boolean),
    sa.column("is_active", sa.Boolean),
    sa.column("updated_at", sa.DateTime(timezone=True)),
    sa.column("version", sa.Integer),
)
_feed = sa.table(
    "change_log",
    sa.column("table_name", sa.String),
    sa.column("row_id", sa.String),
    sa.column("op", sa.String),
    sa.column("data", sa.JSON),
    sa.column("branch_id", sa.String),
    sa.column("occurred_at", sa.DateTime(timezone=True)),
)


def _entry(table: str, row_id: str, kind: str, data: dict[str, Any], now: datetime) -> dict:
    return {
        "table_name": table, "row_id": row_id, "op": kind, "data": data, "branch_id": None,
        "occurred_at": now,
    }


def upgrade() -> None:
    now = datetime.now(UTC)
    if context.is_offline_mode():
        # alembic --sql: the script's database has only the units 0011 wrote. A
        # script spells the JSON out as text, which both databases take.
        script_feed = sa.table(
            "change_log",
            sa.column("table_name", sa.String),
            sa.column("row_id", sa.String),
            sa.column("op", sa.String),
            sa.column("data", sa.Text),
            sa.column("branch_id", sa.String),
            sa.column("occurred_at", sa.DateTime(timezone=True)),
        )
        op.bulk_insert(script_feed, [
            _entry("units", unit_id, "insert", {}, now) | {
                "data": json.dumps({"name": name, "decimal_places": places, "version": 1}),
            }
            for unit_id, name, places in _UNITS
        ])
        return
    bind = op.get_bind()
    for unit_id, name, places in _UNITS:
        fixed = bind.execute(sa.select(_units.c.version).where(_units.c.id == unit_id)).first()
        if fixed is None:
            continue
        copies = list(bind.execute(
            sa.select(_units.c.id).where(
                _units.c.name == name, _units.c.decimal_places == places,
                _units.c.id != unit_id, _units.c.deleted_at.is_(None),
            )
        ).scalars())
        if copies:
            columns = [_products.c.id, *(_products.c[f] for f in _PRODUCT_FIELDS)]
            moving = bind.execute(
                sa.select(*columns).where(_products.c.unit_id.in_(copies))
            ).mappings().all()
            for row in moving:
                version = row["version"] + 1
                bind.execute(
                    sa.update(_products).where(_products.c.id == row["id"])
                    .values(unit_id=unit_id, version=version, updated_at=now)
                )
                image = {f: row[f] for f in _PRODUCT_FIELDS} | {
                    "unit_id": unit_id, "version": version,
                }
                bind.execute(sa.insert(_feed).values(
                    _entry("products", row["id"], "update", image, now)
                ))
            bind.execute(
                sa.update(_units).where(_units.c.id.in_(copies))
                .values(deleted_at=now, updated_at=now, version=_units.c.version + 1)
            )
        logged = bind.execute(
            sa.select(_feed.c.row_id).where(
                _feed.c.table_name == "units", _feed.c.row_id == unit_id
            ).limit(1)
        ).first()
        if logged is None:
            bind.execute(sa.insert(_feed).values(_entry(
                "units", unit_id, "insert",
                {"name": name, "decimal_places": places, "version": fixed.version}, now,
            )))


def downgrade() -> None:
    # A data fix: the copies stay merged.
    pass
