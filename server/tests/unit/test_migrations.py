"""The migrations are frozen and exercised: an empty database upgrades to head
and matches the models; every revision upgrades one step at a time with a row in
every table; downgrade to base and back works; a database an older release left
without stock_movements.ref_type/ref_id gets them. On SQLite, and on PostgreSQL
when DUKAN_TEST_DATABASE_URL is set (CI)."""

from __future__ import annotations

import importlib.util
import uuid
from datetime import UTC, datetime
from pathlib import Path

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
            assert count == 1, table
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
