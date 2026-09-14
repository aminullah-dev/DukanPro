"""Business days and branch settings (docs/domain/branches.md), mirrored by
packages/dukan_core/test/calendar_test.dart."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from dukan.domain.branches import assert_branch_settings_valid, branch_wall_clock, business_day
from dukan.shared.errors import ValidationError


def test_a_kabul_day_runs_from_1930_utc_to_1930_utc() -> None:
    # 01:00 on 12 September in Kabul is still 11 September in UTC.
    start, end = business_day("Asia/Kabul", datetime(2026, 9, 11, 20, 30, tzinfo=UTC))
    assert start == datetime(2026, 9, 11, 19, 30, tzinfo=UTC)
    assert end == datetime(2026, 9, 12, 19, 30, tzinfo=UTC)
    assert business_day("Asia/Kabul", datetime(2026, 9, 11, 19, 29, tzinfo=UTC))[1] == start


def test_the_wall_clock_and_an_unknown_zone() -> None:
    at = datetime(2026, 9, 11, 10, tzinfo=UTC)
    assert branch_wall_clock("Asia/Kabul", at) == datetime(2026, 9, 11, 14, 30)
    assert branch_wall_clock("UTC", at) == datetime(2026, 9, 11, 10)
    assert branch_wall_clock("Europe/Nowhere", at) == datetime(2026, 9, 11, 14, 30)


def test_branch_zone_and_currency_are_supported_ones() -> None:
    assert_branch_settings_valid(timezone="Asia/Kabul", currency_default="AFN")
    with pytest.raises(ValidationError) as zone:
        assert_branch_settings_valid(timezone="Mars/Olympus", currency_default="AFN")
    assert zone.value.code == "BRANCH_TIMEZONE_INVALID"
    with pytest.raises(ValidationError) as money:
        assert_branch_settings_valid(timezone="Asia/Kabul", currency_default="ZZZ")
    assert money.value.code == "BRANCH_CURRENCY_INVALID"
