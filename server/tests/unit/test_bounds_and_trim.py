"""Totals stay within MONEY_MAX, drawer cash is never negative, and both number
parsers trim the same characters. The same rows as
packages/dukan_core/test/bounds_test.dart."""

from __future__ import annotations

from collections.abc import Callable

import pytest

from dukan.domain.numbers import parse_scaled
from dukan.domain.purchasing import ReceiptLine, assert_receivable, receipt_total
from dukan.domain.sales import (
    SaleLine,
    assert_sale_lines_valid,
    assert_shift_cash_valid,
    line_total_fits,
)
from dukan.shared.errors import AppError
from dukan.shared.limits import MONEY_MAX


def _code(rule: Callable[[], object]) -> str:
    with pytest.raises(AppError) as e:
        rule()
    return e.value.code


def _line(qty: int, *, price: int = 52000, places: int = 0) -> SaleLine:
    return SaleLine(
        product_id="p1", name="Soap", qty_minor=qty, decimal_places=places,
        unit_price_minor=price, unit_cost_minor=0, currency="AFN",
    )


def _receipt(qty: int, cost: int) -> ReceiptLine:
    return ReceiptLine(product_id="p1", qty_minor=qty, unit_cost_minor=cost, decimal_places=0)


def test_a_line_fits_until_its_value_passes_money_max() -> None:
    assert line_total_fits(MONEY_MAX, 1, 0)
    assert not line_total_fits(MONEY_MAX, 2, 0)
    assert line_total_fits(MONEY_MAX, 1000, 3)  # 1.000 kg
    assert not line_total_fits(52000, 2 * 10**15, 0)  # would wrap a 64-bit product


def test_a_sale_total_past_money_max_is_refused() -> None:
    assert _code(lambda: assert_sale_lines_valid([_line(10**14)], currency="AFN")) == (
        "SALE_TOTAL_TOO_LARGE"
    )
    half = MONEY_MAX // 2 + 1
    two = [_line(1, price=half), _line(1, price=half)]
    assert _code(lambda: assert_sale_lines_valid(two, currency="AFN")) == "SALE_TOTAL_TOO_LARGE"
    assert_sale_lines_valid([_line(1, price=MONEY_MAX)], currency="AFN")


def test_a_receipt_past_money_max_is_refused() -> None:
    assert _code(lambda: assert_receivable(_receipt(MONEY_MAX, MONEY_MAX))) == (
        "GRN_TOTAL_TOO_LARGE"
    )
    half = _receipt(1, MONEY_MAX // 2 + 1)
    assert _code(lambda: receipt_total([half, half])) == "GRN_TOTAL_TOO_LARGE"
    assert receipt_total([half]) == MONEY_MAX // 2 + 1


def test_drawer_cash_is_never_negative() -> None:
    assert _code(lambda: assert_shift_cash_valid(amount_minor=-1)) == "SHIFT_CASH_INVALID"
    assert_shift_cash_valid(amount_minor=0)


@pytest.mark.parametrize("text", ["﻿12", "12﻿", "\x1c12\x1f", " 　١٢\t"])
def test_both_parsers_trim_the_same_characters(text: str) -> None:
    assert parse_scaled(text, 0) == (12, None)
