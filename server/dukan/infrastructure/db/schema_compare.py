"""How Alembic compares column types (migrations/env.py and the migration tests)."""

from __future__ import annotations

from typing import Any

from sqlalchemy import Integer


def compare_type(
    context: Any,
    inspected_column: Any,
    metadata_column: Any,
    inspected_type: Any,
    metadata_type: Any,
) -> bool | None:
    """SQLite stores every integer in 64 bits whatever the declared type, so an
    INTEGER column the model calls BIGINT is no change there. Otherwise
    Alembic's own comparison decides (None)."""
    if (
        context.dialect.name == "sqlite"
        and isinstance(inspected_type, Integer)
        and isinstance(metadata_type, Integer)
    ):
        return False
    return None
