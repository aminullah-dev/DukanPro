"""The migrations are frozen and exercised: an empty database upgrades to head
and matches the models; every revision upgrades one step at a time with a row in
every table; downgrade to base and back works; a database an older release left
without stock_movements.ref_type/ref_id gets them. On SQLite, and on PostgreSQL
when DUKAN_TEST_DATABASE_URL is set (CI)."""

from __future__ import annotations

import importlib.util
import io
import uuid
from datetime import UTC, datetime
from pathlib import Path

import pytest
import sqlalchemy as sa
from alembic import command
from alembic.autogenerate import compare_metadata
from alembic.config import Config
from alembic.migration import MigrationContext
from alembic.script import ScriptDirectory

import dukan.infrastructure.db.models  # noqa: F401  (populate metadata)
from dukan.infrastructure.db.base import Base
from dukan.infrastructure.db.schema_compare import compare_type

_CONFTEST = Path(__file__).resolve().parents[1] / "conftest.py"
_MIGRATIONS = Path(__file__).resolve().parents[2] / "migrations"


def _alembic_config(connection: sa.Connection) -> Config:
    spec = importlib.util.spec_from_file_location("dukan_tests_conftest", _CONFTEST)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    config: Config = module.alembic_config(connection)
    return config


def _migrate(engine: sa.Engine, target: str, *, down: bool = False) -> None:
    with engine.begin() as conn:
        (command.downgrade if down else command.upgrade)(_alembic_config(conn), target)


def _tables(engine: sa.Engine) -> set[str]:
    return set(sa.inspect(engine).get_table_names()) - {"alembic_version"}


def _columns(engine: sa.Engine, table: str) -> set[str]:
    return {c["name"] for c in sa.inspect(engine).get_columns(table)}


def _sample(column: sa.Column) -> object:
    kind = column.type
    if isinstance(kind, sa.Boolean):
        return True
    if isinstance(kind, sa.Integer):
        return 1
    if isinstance(kind, sa.DateTime):
        return datetime.now(UTC)
    if isinstance(kind, sa.JSON):
        return {}
    if isinstance(kind, sa.String):
        return str(uuid.uuid4())[: kind.length or 36]
    raise AssertionError(f"no sample for {column.table.name}.{column.name}: {kind!r}")


def _seed(engine: sa.Engine, name: str) -> None:
    """One row, with a value in every column that needs one."""
    table = sa.Table(name, sa.MetaData(), autoload_with=engine)
    row = {
        c.name: _sample(c)
        for c in table.columns
        if not c.nullable and not (c.primary_key and isinstance(c.type, sa.Integer))
    }
    with engine.begin() as conn:
        conn.execute(table.insert().values(**row))


def test_an_empty_database_upgrades_to_the_models_and_back(empty_database_url: str) -> None:
    engine = sa.create_engine(empty_database_url)
    _migrate(engine, "head")
    with engine.connect() as conn:
        context = MigrationContext.configure(conn, opts={"compare_type": compare_type})
        assert compare_metadata(context, Base.metadata) == []
    _migrate(engine, "base", down=True)
    assert _tables(engine) == set()
    _migrate(engine, "head")
    assert _tables(engine) == set(Base.metadata.tables)
    engine.dispose()


def test_every_revision_upgrades_with_rows_in_every_table(empty_database_url: str) -> None:
    engine = sa.create_engine(empty_database_url)
    with engine.connect() as conn:
        script = ScriptDirectory.from_config(_alembic_config(conn))
    revisions = [s.revision for s in reversed(list(script.walk_revisions()))]
    seeded: set[str] = set()
    for revision in revisions:
        _migrate(engine, revision)
        for table in sorted(_tables(engine) - seeded):
            _seed(engine, table)
            seeded.add(table)
    with engine.connect() as conn:
        for table in sorted(seeded):
            count = conn.execute(sa.text(f'SELECT COUNT(*) FROM "{table}"')).scalar_one()
            assert count >= 1, table  # 0011 adds the built-in units
    engine.dispose()


def test_a_database_left_at_0002_gets_the_sale_reference(empty_database_url: str) -> None:
    engine = sa.create_engine(empty_database_url)
    _migrate(engine, "0002")
    assert {"ref_type", "ref_id"}.isdisjoint(_columns(engine, "stock_movements"))
    _migrate(engine, "head")
    assert {"ref_type", "ref_id"} <= _columns(engine, "stock_movements")
    engine.dispose()


def test_0010_restores_a_sale_reference_an_old_upgrade_skipped(empty_database_url: str) -> None:
    engine = sa.create_engine(empty_database_url)
    _migrate(engine, "head")
    with engine.begin() as conn:  # as an upgrade by an older release left it
        conn.execute(sa.text("ALTER TABLE stock_movements DROP COLUMN ref_type"))
        conn.execute(sa.text("ALTER TABLE stock_movements DROP COLUMN ref_id"))
        command.stamp(_alembic_config(conn), "0009")
    _migrate(engine, "head")
    assert {"ref_type", "ref_id"} <= _columns(engine, "stock_movements")
    engine.dispose()


def _row(table: sa.Table, **values: object) -> dict[str, object]:
    row = {
        c.name: _sample(c)
        for c in table.columns
        if not c.nullable and not (c.primary_key and isinstance(c.type, sa.Integer))
    }
    return {**row, **values}


def test_0012_merges_seeded_copies_of_the_built_in_units(empty_database_url: str) -> None:
    engine = sa.create_engine(empty_database_url)
    _migrate(engine, "0011")
    kg = "00000000-0000-7000-8000-000000000002"
    copy, box, rice = (str(uuid.uuid4()) for _ in range(3))
    meta = sa.MetaData()
    units = sa.Table("units", meta, autoload_with=engine)
    products = sa.Table("products", meta, autoload_with=engine)
    with engine.begin() as conn:
        # A device from before the fixed ids pushed its own "kg"; Rice uses it.
        conn.execute(units.insert().values(**_row(units, id=copy, name="kg", decimal_places=3)))
        conn.execute(units.insert().values(**_row(units, id=box, name="box", decimal_places=0)))
        conn.execute(products.insert().values(**_row(products, id=rice, unit_id=copy, version=3)))
    _migrate(engine, "0012")
    feed_table = sa.Table("change_log", sa.MetaData(), autoload_with=engine)
    with engine.connect() as conn:
        product = conn.execute(sa.select(products).where(products.c.id == rice)).mappings().one()
        live = conn.execute(
            sa.select(units.c.name).where(units.c.deleted_at.is_(None))
        ).scalars().all()
        feed = conn.execute(
            sa.select(
                feed_table.c.table_name, feed_table.c.row_id, feed_table.c.op, feed_table.c.data
            ).order_by(feed_table.c.seq)
        ).all()
    engine.dispose()
    assert (product["unit_id"], product["version"]) == (kg, 4)
    assert sorted(live) == ["box", "dozen", "kg", "litre", "meter", "piece"]
    moved = [(kind, data) for table, row_id, kind, data in feed if (table, row_id) == ("products", rice)]
    assert len(moved) == 1 and moved[0][0] == "update"
    assert (moved[0][1]["unit_id"], moved[0][1]["version"]) == (kg, 4)
    assert len({row_id for table, row_id, _, _ in feed if table == "units"}) == 5


def _offline_sql(url: str, monkeypatch: pytest.MonkeyPatch) -> str:
    """The migrations as a SQL script (alembic --sql): no database is touched."""
    monkeypatch.setenv("DUKAN_DATABASE_URL", url)
    buffer = io.StringIO()
    cfg = Config(output_buffer=buffer)
    cfg.set_main_option("script_location", str(_MIGRATIONS))
    command.upgrade(cfg, "head", sql=True)
    return buffer.getvalue()


@pytest.mark.parametrize(
    "url", ["sqlite:///offline.db", "postgresql://dukan:p%40ss@db.invalid/dukan"]
)
def test_the_migrations_render_as_a_sql_script(url: str, monkeypatch: pytest.MonkeyPatch) -> None:
    # A percent-encoded password in the URL is fine too.
    sql = _offline_sql(url, monkeypatch)
    assert "CREATE TABLE products" in sql
    assert "INSERT INTO units" in sql
    if url.startswith("postgresql"):
        # 0010 alters each table in one statement, so it is rewritten once.
        assert sql.count("ALTER TABLE sales ALTER COLUMN") == 1

