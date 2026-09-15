"""Sales / POS domain. Mirrors packages/dukan_core/lib/domain/sales.dart and
docs/domain/sales.md."""

from __future__ import annotations

from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from enum import StrEnum

from dukan.shared.errors import ConflictError, ValidationError
from dukan.shared.limits import MONEY_MAX


class SaleStatus(StrEnum):
    OPEN = "open"
    SETTLED = "settled"
    VOIDED = "voided"


class PaymentMethod(StrEnum):
    CASH = "cash"
    CARD = "card"
    TRANSFER = "transfer"  # mobile money or a bank transfer (M-Paisa, HesabPay)
    CREDIT = "credit"


def _scale(decimal_places: int) -> int:
    return 10**decimal_places


def line_total_minor(unit_price_minor: int, qty_minor: int, decimal_places: int) -> int:
    """Money value of qty_minor units at unit_price_minor per whole unit, ROUND_HALF_UP."""
    scale = _scale(decimal_places)
    product = unit_price_minor * qty_minor
    negative = product < 0
    magnitude = abs(product)
    rounded = (magnitude + scale // 2) // scale
    return -rounded if negative else rounded


def line_total_fits(unit_price_minor: int, qty_minor: int, decimal_places: int) -> bool:
    """Whether a line's money value stays within MONEY_MAX, the most a money
    column or a client's JSON number holds. (The device asks before it
    multiplies: a 64-bit product wraps.)"""
    return abs(unit_price_minor * qty_minor) <= MONEY_MAX * _scale(decimal_places)


@dataclass(frozen=True, slots=True)
class SaleLine:
    product_id: str
    name: str
    qty_minor: int
    decimal_places: int
    unit_price_minor: int
    unit_cost_minor: int
    currency: str
    track_stock: bool = True  # an untracked product (a service) moves no stock

    @property
    def line_total(self) -> int:
        return line_total_minor(self.unit_price_minor, self.qty_minor, self.decimal_places)


@dataclass(frozen=True, slots=True)
class SaleTotals:
    subtotal_minor: int
    tax_minor: int
    total_minor: int


def compute_totals(lines: Sequence[SaleLine], discount_minor: int = 0) -> SaleTotals:
    subtotal = sum(l.line_total for l in lines)
    tax = 0
    return SaleTotals(
        subtotal_minor=subtotal, tax_minor=tax, total_minor=subtotal - discount_minor + tax
    )


def assert_sale_lines_valid(lines: Sequence[SaleLine], *, currency: str) -> None:
    """Every line sells a positive quantity at a price of zero or more, in the
    sale's currency, and the sale's total stays within MONEY_MAX. Raises
    ValidationError SALE_EMPTY, SALE_LINE_INVALID_QTY, SALE_LINE_INVALID_PRICE or
    SALE_TOTAL_TOO_LARGE, or ConflictError SALE_CURRENCY_MISMATCH."""
    if not lines:
        raise ValidationError("SALE_EMPTY")
    total = 0
    for l in lines:
        if l.qty_minor <= 0:
            raise ValidationError("SALE_LINE_INVALID_QTY", product_id=l.product_id, qty=l.qty_minor)
        if l.unit_price_minor < 0:
            raise ValidationError(
                "SALE_LINE_INVALID_PRICE", product_id=l.product_id, price=l.unit_price_minor
            )
        if l.currency != currency:
            raise ConflictError("SALE_CURRENCY_MISMATCH", expected=currency, got=l.currency)
        if not line_total_fits(l.unit_price_minor, l.qty_minor, l.decimal_places):
            raise ValidationError("SALE_TOTAL_TOO_LARGE", product_id=l.product_id)
        total += l.line_total
    if total > MONEY_MAX:
        raise ValidationError("SALE_TOTAL_TOO_LARGE")


def assert_settleable(
    *,
    lines: Sequence[SaleLine],
    total_minor: int,
    paid_minor: int,
    currency: str,
    allow_credit: bool,
) -> None:
    """paid_minor is the amount offered toward the balance. Raises what
    assert_sale_lines_valid raises, SALE_PAYMENT_INVALID for a negative amount,
    or (cash-only) SALE_UNDERPAID."""
    assert_sale_lines_valid(lines, currency=currency)
    if paid_minor < 0:
        raise ValidationError("SALE_PAYMENT_INVALID", reason="amount", paid=paid_minor)
    if not allow_credit and paid_minor < total_minor:
        raise ConflictError("SALE_UNDERPAID", total=total_minor, paid=paid_minor)


_TENDERS = frozenset({PaymentMethod.CASH, PaymentMethod.CARD, PaymentMethod.TRANSFER})


def assert_payment_valid(
    *, method: str, amount_minor: int, tendered_minor: int | None = None
) -> None:
    """A payment is a positive amount by cash, card or transfer: credit is the unpaid
    remainder, never a payment. Cash handed over is at least the amount, and only
    cash is handed over. Raises ValidationError SALE_PAYMENT_INVALID."""
    if method not in _TENDERS:
        raise ValidationError("SALE_PAYMENT_INVALID", reason="method", method=method[:16])
    if amount_minor <= 0:
        raise ValidationError("SALE_PAYMENT_INVALID", reason="amount", amount=amount_minor)
    if tendered_minor is not None and (
        method != PaymentMethod.CASH or tendered_minor < amount_minor
    ):
        raise ValidationError(
            "SALE_PAYMENT_INVALID", reason="tendered", amount=amount_minor, tendered=tendered_minor
        )


def assert_sale_not_overpaid(*, paid_minor: int, total_minor: int) -> None:
    """The payments applied to a sale never add up to more than its total: cash
    over the total is change handed back, not a payment. Raises ConflictError
    SALE_OVERPAID."""
    if paid_minor > total_minor:
        raise ConflictError("SALE_OVERPAID", paid=paid_minor, total=total_minor)


def assert_discount_valid(*, discount_minor: int, subtotal_minor: int) -> None:
    """A discount lies between 0 and the subtotal: a negative one is a hidden
    surcharge, a larger one a negative total. Raises ValidationError
    SALE_DISCOUNT_INVALID."""
    if not 0 <= discount_minor <= subtotal_minor:
        raise ValidationError(
            "SALE_DISCOUNT_INVALID", discount=discount_minor, subtotal=subtotal_minor
        )


def assert_shift_cash_valid(*, amount_minor: int) -> None:
    """Cash in a drawer (a shift's opening float, the count at its close) is zero
    or more. Raises ValidationError SHIFT_CASH_INVALID."""
    if amount_minor < 0:
        raise ValidationError("SHIFT_CASH_INVALID", amount=amount_minor)


def _div_round_half_up(numerator: int, denominator: int) -> int:
    """numerator / denominator, half away from zero; denominator > 0."""
    magnitude = (2 * abs(numerator) + denominator) // (2 * denominator)
    return -magnitude if numerator < 0 else magnitude


def returned_value_minor(
    *, line_total_minor: int, sold_qty_minor: int, returned_qty_minor: int
) -> int:
    """What returned_qty_minor of goods sold as sold_qty_minor for line_total_minor
    is worth: the same share of the line's total, ROUND_HALF_UP."""
    if sold_qty_minor <= 0:
        return 0
    return _div_round_half_up(line_total_minor * returned_qty_minor, sold_qty_minor)


def refund_total_minor(
    *, gross_minor: int, sale_subtotal_minor: int, sale_discount_minor: int
) -> int:
    """The money a return gives back: the returned goods' value less their share
    of the sale's discount (the discount spread over the sale by value)."""
    if sale_subtotal_minor <= 0 or sale_discount_minor == 0:
        return gross_minor
    share = _div_round_half_up(sale_discount_minor * gross_minor, sale_subtotal_minor)
    return gross_minor - share


def assert_refund_valid(
    *, reason: str, wanted: Mapping[str, int], returnable: Mapping[str, int]
) -> None:
    """A return says why and takes back at least one thing, and of each product
    no more than the sale sold less what earlier returns took back. Raises
    ValidationError REFUND_REASON_REQUIRED, REFUND_EMPTY or REFUND_QTY_INVALID."""
    if not reason.strip():
        raise ValidationError("REFUND_REASON_REQUIRED")
    if not wanted:
        raise ValidationError("REFUND_EMPTY")
    for product_id, qty in wanted.items():
        left = returnable.get(product_id, 0)
        if qty <= 0 or qty > left:
            raise ValidationError("REFUND_QTY_INVALID", product_id=product_id, returnable=left)

