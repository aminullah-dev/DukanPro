"""Sales / POS domain. Mirrors packages/dukan_core/lib/domain/sales.dart and
docs/domain/sales.md."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from enum import StrEnum

from dukan.shared.errors import ConflictError, ValidationError


class SaleStatus(StrEnum):
    OPEN = "open"
    SETTLED = "settled"
    VOIDED = "voided"


class PaymentMethod(StrEnum):
    CASH = "cash"
    CARD = "card"
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


@dataclass(frozen=True, slots=True)
class SaleLine:
    product_id: str
    name: str
    qty_minor: int
    decimal_places: int
    unit_price_minor: int
    unit_cost_minor: int
    currency: str

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


def assert_settleable(
    *,
    lines: Sequence[SaleLine],
    total_minor: int,
    paid_minor: int,
    currency: str,
    allow_credit: bool,
) -> None:
    if not lines:
        raise ValidationError("SALE_EMPTY")
    for l in lines:
        if l.currency != currency:
            raise ConflictError("SALE_CURRENCY_MISMATCH", expected=currency, got=l.currency)
    if not allow_credit and paid_minor < total_minor:
        raise ConflictError("SALE_UNDERPAID", total=total_minor, paid=paid_minor)


def assert_discount_valid(*, discount_minor: int, subtotal_minor: int) -> None:
    """A discount lies between 0 and the subtotal: a negative one is a hidden
    surcharge, a larger one a negative total. Raises ValidationError
    SALE_DISCOUNT_INVALID."""
    if not 0 <= discount_minor <= subtotal_minor:
        raise ValidationError(
            "SALE_DISCOUNT_INVALID", discount=discount_minor, subtotal=subtotal_minor
        )
