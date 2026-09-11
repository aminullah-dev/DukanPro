"""Mirror of packages/dukan_core/test/sales_test.dart."""

import pytest

from dukan.domain.sales import SaleLine, assert_settleable, compute_totals, line_total_minor
from dukan.shared.errors import ConflictError, ValidationError


def _line(price: int, qty: int, dp: int, cur: str = "AFN") -> SaleLine:
    return SaleLine(
        product_id="p", name="x", qty_minor=qty, decimal_places=dp,
        unit_price_minor=price, unit_cost_minor=0, currency=cur,
    )


def test_line_total_minor() -> None:
    assert line_total_minor(52000, 3, 0) == 156000
    assert line_total_minor(1000, 1500, 3) == 1500
    assert line_total_minor(1500, 1, 3) == 2


def test_compute_totals() -> None:
    t = compute_totals([_line(52000, 3, 0), _line(85000, 1, 0)], 1000)
    assert t.total_minor == 156000 + 85000 - 1000


def test_empty_raises() -> None:
    with pytest.raises(ValidationError) as e:
        assert_settleable(lines=[], total_minor=0, paid_minor=0, currency="AFN", allow_credit=False)
    assert e.value.code == "SALE_EMPTY"


def test_underpaid_raises() -> None:
    with pytest.raises(ConflictError) as e:
        assert_settleable(lines=[_line(500, 1, 0)], total_minor=500, paid_minor=300, currency="AFN", allow_credit=False)
    assert e.value.code == "SALE_UNDERPAID"


def test_credit_allows_underpay() -> None:
    assert_settleable(lines=[_line(500, 1, 0)], total_minor=500, paid_minor=300, currency="AFN", allow_credit=True)


def test_currency_mismatch_raises() -> None:
    with pytest.raises(ConflictError) as e:
        assert_settleable(lines=[_line(500, 1, 0, cur="USD")], total_minor=500, paid_minor=500, currency="AFN", allow_credit=False)
    assert e.value.code == "SALE_CURRENCY_MISMATCH"
