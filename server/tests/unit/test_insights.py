"""Insight domain rules (mirrors packages/dukan_core insights_test.dart)."""

from __future__ import annotations

from dukan.domain.insights import (
    InsightSeverity,
    debt_severity,
    is_dead_stock,
    reorder_suggestion,
)


def test_reorder_suggests_nothing_when_covered() -> None:
    assert reorder_suggestion(on_hand_minor=1000, avg_daily_sales_minor=10) == 0


def test_reorder_refills_to_twice_the_point_when_low() -> None:
    # point = 10 * (7+3) = 100; target = 200; on-hand 20 → 180.
    assert reorder_suggestion(on_hand_minor=20, avg_daily_sales_minor=10) == 180


def test_reorder_ignores_products_with_no_sales() -> None:
    assert reorder_suggestion(on_hand_minor=0, avg_daily_sales_minor=0) == 0


def test_dead_stock_flags_unsold_past_threshold() -> None:
    assert is_dead_stock(on_hand_minor=5, days_since_last_sale=45) is True
    assert is_dead_stock(on_hand_minor=5, days_since_last_sale=3) is False
    assert is_dead_stock(on_hand_minor=0, days_since_last_sale=90) is False


def test_debt_severity_thresholds() -> None:
    assert debt_severity(balance_minor=100, credit_limit_minor=100) is InsightSeverity.CRITICAL
    assert debt_severity(balance_minor=80, credit_limit_minor=100) is InsightSeverity.WARNING
    assert debt_severity(balance_minor=50, credit_limit_minor=100) is InsightSeverity.INFO
    assert debt_severity(balance_minor=500, credit_limit_minor=0) is InsightSeverity.INFO
