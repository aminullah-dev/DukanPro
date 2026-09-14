"""Branches domain. Mirrors packages/dukan_core/lib/domain/branches.dart and
docs/domain/branches.md — the SAME rules in both languages. Pure: imports only
the shared error contract. A branch scopes stock, sales, shifts, and staff to a
physical location.
"""

from __future__ import annotations

from dataclasses import dataclass

from dukan.shared.errors import ConflictError


@dataclass(frozen=True, slots=True)
class Branch:
    id: str
    name: str
    timezone: str = "Asia/Kabul"
    currency_default: str = "AFN"
    is_active: bool = True
    version: int = 1


def assert_not_last_active_branch(*, active_branch_count: int) -> None:
    """A shop must always retain at least one active branch.

    `active_branch_count` counts active branches *including* the one being
    deactivated, before the change.
    """
    if active_branch_count <= 1:
        raise ConflictError("BRANCH_LAST_ACTIVE")


def assert_branch_active(*, branch_id: str, is_active: bool) -> None:
    """Writes happen only in an active branch; a deactivated branch keeps its
    history readable. Raises ConflictError BRANCH_INACTIVE."""
    if not is_active:
        raise ConflictError("BRANCH_INACTIVE", branch_id=branch_id)
