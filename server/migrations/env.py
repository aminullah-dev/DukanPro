"""Alembic environment. Uses the app's metadata and DUKAN_DATABASE_URL."""

import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import Connection, engine_from_config, pool

import dukan.infrastructure.db.models  # noqa: F401  (populate metadata)
from dukan.infrastructure.db.base import Base
from dukan.infrastructure.db.schema_compare import compare_type

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

db_url = os.environ.get("DUKAN_DATABASE_URL", config.get_main_option("sqlalchemy.url"))
if db_url:
    # The config file format reads "%" as interpolation (a percent-encoded
    # password would crash it), so it is doubled here.
    config.set_main_option("sqlalchemy.url", db_url.replace("%", "%%"))

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    context.configure(
        url=db_url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=compare_type,
    )
    with context.begin_transaction():
        context.run_migrations()


def _run(connection: Connection) -> None:
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=compare_type,
        render_as_batch=connection.dialect.name == "sqlite",
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    # A caller may hand in its own connection (the tests do): migrate on it.
    given = config.attributes.get("connection")
    if given is not None:
        _run(given)
        return
    section = config.get_section(config.config_ini_section, {})
    section["sqlalchemy.url"] = db_url
    connectable = engine_from_config(section, prefix="sqlalchemy.", poolclass=pool.NullPool)
    with connectable.connect() as connection:
        _run(connection)


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
