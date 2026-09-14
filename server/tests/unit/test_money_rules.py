"""Money and quantity rules, mirrored in dukan_core: numbers typed with Persian
or Latin digits, and the sign and range of every amount."""

from __future__ import annotations

from collections.abc import Callable

import pytest

from dukan.domain.catalog import BUILTIN_UNITS, assert_price_valid, quantity_to_minor
from dukan.domain.customers import (
    assert_customer_can_buy_on_credit,
    assert_debt_payment_valid,
    assert_write_off_valid,
)
from dukan.domain.numbers import NumberProblem, money_to_minor, parse_scaled
from dukan.domain.purchasing import ReceiptLine, assert_receivable
from dukan.domain.sales import (
    SaleLine,
    assert_payment_valid,
    assert_sale_lines_valid,
    assert_sale_not_overpaid,
    assert_settleable,
)
from dukan.shared.errors import AppError
from dukan.shared.limits import MONEY_MAX

# The same rows as packages/dukan_core/test/numbers_test.dart.
VALID = [
    ("12", 0, 12), ("۱۲", 0, 12), ("١٢", 0, 12), ("1.5", 3, 1500), ("۱٫۵", 3, 1500),
    (".5", 2, 50), ("1,000", 0, 1000), ("۱٬۰۰۰", 0, 1000), (" 7 ", 0, 7), ("-5", 0, -5),
    ("12.50", 2, 1250), ("0", 2, 0),
]
NOT_A_NUMBER = [
    "abc", "0x10", "1_000", "1.-5", "1. 5", "--5", ".", "", "1.2.3", "+5", "5.", "1,00", "12,5",
    "۱۲a",
]


def _code(fn: Callable[[], object]) -> str:
    with pytest.raises(AppError) as e:
        fn()
    return e.value.code


@pytest.mark.parametrize(("text", "places", "want"), VALID)
def test_typed_numbers(text: str, places: int, want: int) -> None:
    assert parse_scaled(text, places) == (want, None)


@pytest.mark.parametrize("text", NOT_A_NUMBER)
def test_what_is_not_a_number(text: str) -> None:
    assert parse_scaled(text, 2) == (None, NumberProblem.NOT_A_NUMBER)


def test_precision_and_size() -> None:
    assert parse_scaled("1.5", 0) == (None, NumberProblem.TOO_PRECISE)
    assert parse_scaled("1.234", 2) == (None, NumberProblem.TOO_PRECISE)
    assert parse_scaled("9007199254740991", 0) == (MONEY_MAX, None)
    assert parse_scaled("9007199254740992", 0) == (None, NumberProblem.TOO_LARGE)
    assert parse_scaled("90071992547409.92", 2) == (None, NumberProblem.TOO_LARGE)


def test_quantities_and_amounts_raise_their_own_codes() -> None:
    assert quantity_to_minor("۵", 0) == 5
    assert quantity_to_minor("۲٫۵", 3) == 2500
    assert _code(lambda: quantity_to_minor("abc", 0)) == "CATALOG_QTY_INVALID"
    assert _code(lambda: quantity_to_minor("1.5", 0)) == "CATALOG_UNIT_PRECISION"
    assert money_to_minor("۱۲۰") == 12000
    assert _code(lambda: money_to_minor("12.345")) == "MONEY_AMOUNT_INVALID"


def _line(qty: int = 1, price: int = 5000) -> SaleLine:
    return SaleLine(
        product_id="p", name="Soap", qty_minor=qty, decimal_places=0, unit_price_minor=price,
        unit_cost_minor=0, currency="AFN",
    )


def test_sale_lines_sell_a_positive_quantity_at_a_price_of_zero_or_more() -> None:
    assert _code(lambda: assert_sale_lines_valid([_line(qty=0)], currency="AFN")) == (
        "SALE_LINE_INVALID_QTY"
    )
    assert _code(lambda: assert_sale_lines_valid([_line(qty=-5)], currency="AFN")) == (
        "SALE_LINE_INVALID_QTY"
    )
    assert _code(lambda: assert_sale_lines_valid([_line(price=-1)], currency="AFN")) == (
        "SALE_LINE_INVALID_PRICE"
    )
    assert_sale_lines_valid([_line(price=0)], currency="AFN")


@pytest.mark.parametrize(
    ("method", "amount", "tendered"),
    [("credit", 100, None), ("bogus", 100, None), ("cash", 0, None), ("cash", 500, 400),
     ("card", 500, 600)],
)
def test_a_payment_is_a_positive_cash_or_card_amount(
    method: str, amount: int, tendered: int | None
) -> None:
    assert _code(lambda: assert_payment_valid(
        method=method, amount_minor=amount, tendered_minor=tendered
    )) == "SALE_PAYMENT_INVALID"


def test_payments_never_exceed_the_total_and_none_is_negative() -> None:
    assert_payment_valid(method="cash", amount_minor=500, tendered_minor=600)
    assert _code(lambda: assert_sale_not_overpaid(paid_minor=600, total_minor=500)) == (
        "SALE_OVERPAID"
    )
    assert _code(lambda: assert_settleable(
        lines=[_line()], total_minor=5000, paid_minor=-1, currency="AFN", allow_credit=True
    )) == "SALE_PAYMENT_INVALID"


def test_debt_payments_receipts_and_prices() -> None:
    assert _code(lambda: assert_debt_payment_valid(amount_minor=0)) == "DEBT_PAYMENT_INVALID"
    assert _code(lambda: assert_debt_payment_valid(amount_minor=-500)) == "DEBT_PAYMENT_INVALID"
    for qty, cost in [(0, 100), (-5, 100), (5, -1)]:
        line = ReceiptLine(product_id="p", qty_minor=qty, unit_cost_minor=cost, decimal_places=0)
        assert _code(lambda line=line: assert_receivable(line)) == "GRN_LINE_INVALID"
    assert_receivable(ReceiptLine(product_id="p", qty_minor=5, unit_cost_minor=0, decimal_places=0))
    assert _code(lambda: assert_price_valid(sell_price_minor=-1)) == "CATALOG_PRICE_INVALID"
    assert_price_valid(sell_price_minor=0)


def test_a_receipt_line_costs_its_weight_not_its_grams() -> None:
    # The same rows as packages/dukan_core/test/customers_test.dart.
    piece = ReceiptLine(product_id="p", qty_minor=10, unit_cost_minor=40000, decimal_places=0)
    rice = ReceiptLine(product_id="p", qty_minor=2500, unit_cost_minor=4000, decimal_places=3)
    assert (piece.line_cost, rice.line_cost) == (400000, 10000)  # 2.500 kg at 40.00 is 100.00


def test_built_in_units_have_the_same_ids_everywhere() -> None:
    assert {u.name: (u.id, u.decimal_places) for u in BUILTIN_UNITS} == {
        "piece": ("00000000-0000-7000-8000-000000000001", 0),
        "kg": ("00000000-0000-7000-8000-000000000002", 3),
        "litre": ("00000000-0000-7000-8000-000000000003", 3),
        "dozen": ("00000000-0000-7000-8000-000000000004", 0),
        "meter": ("00000000-0000-7000-8000-000000000005", 2),
    }


def test_write_offs_and_who_may_buy_on_credit() -> None:
    # The same rows as packages/dukan_core/test/customers_test.dart.
    assert _code(lambda: assert_write_off_valid(amount_minor=0, balance_minor=300)) == (
        "DEBT_WRITE_OFF_INVALID"
    )
    assert _code(lambda: assert_write_off_valid(amount_minor=301, balance_minor=300)) == (
        "DEBT_WRITE_OFF_EXCEEDS_BALANCE"
    )
    assert_write_off_valid(amount_minor=300, balance_minor=300)
    assert _code(lambda: assert_customer_can_buy_on_credit(
        is_active=False, customer_currency="AFN", sale_currency="AFN"
    )) == "CUSTOMER_INACTIVE"
    assert _code(lambda: assert_customer_can_buy_on_credit(
        is_active=True, customer_currency="AFN", sale_currency="USD"
    )) == "DEBT_CURRENCY_MISMATCH"

