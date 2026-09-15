"""The change feed devices pull from (change_log). Every write to a synced table,
through sync or REST, appends the row's post-image here in the same transaction.

On PostgreSQL a transaction-scoped advisory lock, taken before the append and
held until commit, makes change_log.seq follow commit order: a pull can never
pass a row that later commits with a lower seq. SQLite serializes writers anyway.
"""

from __future__ import annotations

import hashlib
from datetime import UTC, datetime
from typing import Any

from sqlalchemy import text
from sqlalchemy.orm import Session

from dukan.application.sync_policy import READ_FIELDS
from dukan.infrastructure.db.models import ChangeLogModel

_FEED_LOCK = 0x44554B41  # one advisory-lock key for every change_log writer


def jsonable(value: Any) -> Any:
    if isinstance(value, datetime):
        # SQLite hands back naive datetimes; every stored time is UTC.
        return (value if value.tzinfo else value.replace(tzinfo=UTC)).isoformat()
    return value


def post_image(table: str, row: Any) -> dict[str, Any]:
    """The row's business columns, plus `version` on master rows: what a pull returns."""
    return {k: jsonable(getattr(row, k)) for k in READ_FIELDS[table]}


def record_change(
    session: Session, table: str, row: Any, *, op: str, branch_id: str | None
) -> int:
    """Append the row's post-image to the feed, before the caller commits, and
    return its seq. branch_id scopes branch rows in pull; None is shop-wide."""
    if session.get_bind().dialect.name == "postgresql":
        session.execute(text("SELECT pg_advisory_xact_lock(:key)"), {"key": _FEED_LOCK})
    session.flush()  # the row's own write and defaults (version, times) first
    entry = ChangeLogModel(
        table_name=table, row_id=row.id, op=op, data=post_image(table, row), branch_id=branch_id
    )
    session.add(entry)
    session.flush()
    return int(entry.seq)


def change_token(row: ChangeLogModel) -> str:
    """Names one change for a device's cursor. After a restore from a backup the
    seq a device stopped at holds another change, or none, and so another token."""
    key = f"{row.seq}:{row.table_name}:{row.row_id}:{jsonable(row.occurred_at)}"
    return hashlib.sha256(key.encode()).hexdigest()[:24]
