"""Test fixtures. Sets required env before importing the app, then builds an
isolated app per test: on a new SQLite database, or on the PostgreSQL test
database when DUKAN_TEST_DATABASE_URL is set (CI), migrated as in production."""

from __future__ import annotations

import os
from collections.abc import Iterator
from pathlib import Path

# Required settings must exist before `dukan.composition` is imported (it builds
# a module-level app). Tests use their own per-test DB via the `client` fixture.
os.environ.setdefault("DUKAN_SECRET_KEY", "test-secret-key-at-least-32-bytes-long-00")
os.environ.setdefault("DUKAN_DATABASE_URL", "sqlite:///./.pytest_import.db")
os.environ.setdefault("DUKAN_BOOTSTRAP_TOKEN", "test-setup-token")

import pytest  # noqa: E402
import sqlalchemy as sa  # noqa: E402
from alembic import command  # noqa: E402
from alembic.config import Config  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from dukan.composition import create_app  # noqa: E402
from dukan.config import Settings  # noqa: E402
from dukan.infrastructure.db.base import Base  # noqa: E402

MIGRATIONS = Path(__file__).resolve().parents[1] / "migrations"
_PG_URL = os.environ.get("DUKAN_TEST_DATABASE_URL")


def alembic_config(connection: sa.Connection) -> Config:
    """Alembic, migrating on `connection` (env.py uses a connection it is given)."""
    cfg = Config()
    cfg.set_main_option("script_location", str(MIGRATIONS))
    cfg.attributes["connection"] = connection
    return cfg


@pytest.fixture
def empty_database_url(tmp_path: Path) -> str:
    """An empty database: a new SQLite file, or the PostgreSQL test database with
    its schema dropped."""
    if not _PG_URL:
        return f"sqlite:///{tmp_path / 't.db'}"
    engine = sa.create_engine(_PG_URL)
    with engine.begin() as conn:
        conn.execute(sa.text("DROP SCHEMA IF EXISTS public CASCADE"))
        conn.execute(sa.text("CREATE SCHEMA public"))
    engine.dispose()
    return _PG_URL


@pytest.fixture
def client(empty_database_url: str) -> Iterator[TestClient]:
    settings = Settings(
        secret_key="test-secret-key-at-least-32-bytes-long-00",
        database_url=empty_database_url,
        bootstrap_token="test-setup-token",
    )
    app = create_app(settings)
    if empty_database_url.startswith("sqlite"):
        Base.metadata.create_all(app.state.engine)
    else:
        with app.state.engine.begin() as conn:
            command.upgrade(alembic_config(conn), "head")
    yield TestClient(app)
    app.state.engine.dispose()
