"""Branches domain. Mirrors packages/dukan_core/lib/domain/branches.dart and
docs/domain/branches.md — the SAME rules in both languages. Pure: imports only
the shared error contract. A branch scopes stock, sales, shifts, and staff to a
physical location.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

from dukan.shared.errors import ConflictError, ValidationError


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


# The time zones a branch can be in, with their offsets from UTC. None of them
# keeps daylight saving time, so the device needs no time zone database and the
# server and every device agree on each business day. Mirrors
# packages/dukan_core/lib/domain/branches.dart branchZoneOffsets.
BRANCH_ZONE_OFFSETS: dict[str, timedelta] = {
    "Asia/Kabul": timedelta(hours=4, minutes=30),
    "Asia/Karachi": timedelta(hours=5),
    "Asia/Tashkent": timedelta(hours=5),
    "Asia/Dushanbe": timedelta(hours=5),
    "Asia/Dubai": timedelta(hours=4),
    "Asia/Tehran": timedelta(hours=3, minutes=30),
    "UTC": timedelta(0),
}
DEFAULT_BRANCH_ZONE = "Asia/Kabul"

# The currencies a branch can keep its prices in (docs/localization.md, Money).
BRANCH_CURRENCIES = frozenset({"AFN", "USD", "PKR", "EUR"})


def assert_branch_settings_valid(*, timezone: str, currency_default: str) -> None:
    """A branch's time zone and currency are ones the shop supports. Raises
    ValidationError BRANCH_TIMEZONE_INVALID or BRANCH_CURRENCY_INVALID."""
    if timezone not in BRANCH_ZONE_OFFSETS:
        raise ValidationError("BRANCH_TIMEZONE_INVALID", timezone=timezone)
    if currency_default not in BRANCH_CURRENCIES:
        raise ValidationError("BRANCH_CURRENCY_INVALID", currency=currency_default)


def _offset(zone: str) -> timedelta:
    return BRANCH_ZONE_OFFSETS.get(zone, BRANCH_ZONE_OFFSETS[DEFAULT_BRANCH_ZONE])


def branch_wall_clock(zone: str, instant: datetime) -> datetime:
    """`instant` (tz-aware) on the wall clock of a branch in `zone`, naive. A
    zone the table lacks reads as Kabul's."""
    return (instant.astimezone(UTC) + _offset(zone)).replace(tzinfo=None)


def business_day(zone: str, instant: datetime) -> tuple[datetime, datetime]:
    """The business day of a branch in `zone` that holds `instant`: from the
    branch's local midnight to the next, as UTC instants [start, end). "Today"
    in every report is this range, never UTC's day."""
    local = branch_wall_clock(zone, instant)
    start = datetime(local.year, local.month, local.day, tzinfo=UTC) - _offset(zone)
    return start, start + timedelta(days=1)
