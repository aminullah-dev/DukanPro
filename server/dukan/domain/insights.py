"""Insight rules. Mirrors packages/dukan_core/lib/domain/insights.dart — the
SAME rules in both languages. Pure: no imports beyond the enum. Quantities are
integer minor units; an insight is a decision, its wording lives in the UI.
"""

from __future__ import annotations

from enum import StrEnum


class InsightSeverity(StrEnum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"


def reorder_suggestion(
    *,
    on_hand_minor: int,
    avg_daily_sales_minor: int,
    lead_time_days: int = 7,
    safety_days: int = 3,
) -> int:
    """Suggested reorder quantity (minor units) to reach twice the reorder
    point, or 0 when stock still covers lead + safety demand."""
    if avg_daily_sales_minor <= 0:
        return 0
    reorder_point = avg_daily_sales_minor * (lead_time_days + safety_days)
    if on_hand_minor > reorder_point:
        return 0
    qty = reorder_point * 2 - on_hand_minor
    return qty if qty > 0 else 0


def is_dead_stock(
    *, on_hand_minor: int, days_since_last_sale: int, dead_after_days: int = 30
) -> bool:
    """On hand but unsold within `dead_after_days` — capital tied up in slow stock."""
    return on_hand_minor > 0 and days_since_last_sale >= dead_after_days


def debt_severity(*, balance_minor: int, credit_limit_minor: int) -> InsightSeverity:
    """Urgency of a customer's balance vs their credit limit: at/over = critical,
    >= 80% = warning."""
    if balance_minor <= 0 or credit_limit_minor <= 0:
        return InsightSeverity.INFO
    if balance_minor >= credit_limit_minor:
        return InsightSeverity.CRITICAL
    if balance_minor * 10 >= credit_limit_minor * 8:
        return InsightSeverity.WARNING
    return InsightSeverity.INFO
