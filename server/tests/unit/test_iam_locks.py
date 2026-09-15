"""The owner checks lock what they count: the owner assignments AND their users,
so a concurrent disable of an owner waits for a demotion (and the reverse)."""

from __future__ import annotations

from sqlalchemy.dialects import postgresql

from dukan.infrastructure.iam_service import _active_owner_query


def test_owner_checks_lock_the_assignment_and_user_rows() -> None:
    sql = str(_active_owner_query().compile(dialect=postgresql.dialect()))
    assert sql.rstrip().endswith("FOR UPDATE")  # not "FOR UPDATE OF branch_assignments"
    assert "JOIN users" in sql
