"""Purchasing domain. Mirrors packages/dukan_core/lib/domain/purchasing.dart."""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from dukan.domain.sales import line_total_fits, line_total_minor
from dukan.shared.errors import ValidationError
from dukan.shared.limits import MONEY_MAX


class SupplierEntryType(StrEnum):
    BILL = "bill"
    PAYMENT = "payment"
    ADJUSTMENT = "adjustment"


@dataclass(frozen=True, slots=True)
class Supplier:
    id: str
    name: str
    phone: str | None = None
    currency: str = "AFN"
    is_active: bool = True
    version: int = 1


@dataclass(frozen=True, slots=True)
class SupplierLedgerEntry:
    id: str
    supplier_id: str
    type: SupplierEntryType
    amount_minor: int
    currency: str
    occurred_at: datetime

    @property
    def signed(self) -> int:
        return -self.amount_minor if self.type is SupplierEntryType.PAYMENT else self.amount_minor


def supplier_balance(entries: Iterable[SupplierLedgerEntry]) -> int:
    return sum(e.signed for e in entries)


@dataclass(frozen=True, slots=True)
class ReceiptLine:
    """qty_minor in the unit's minor granularity (10**decimal_places) at
    unit_cost_minor per whole unit."""

    product_id: str
    qty_minor: int
    unit_cost_minor: int
    decimal_places: int

    @property
    def line_cost(self) -> int:
        """Quantity x cost at the unit's scale, ROUND_HALF_UP like a sale line:
        2.500 kg at 40.00 is 100.00."""
        return line_total_minor(self.unit_cost_minor, self.qty_minor, self.decimal_places)


def assert_receivable(line: ReceiptLine) -> None:
    """A received line adds a positive quantity at a cost of zero or more (zero:
    a quantity-only receipt), costing at most MONEY_MAX. Raises ValidationError
    GRN_LINE_INVALID or GRN_TOTAL_TOO_LARGE."""
    if line.qty_minor <= 0 or line.unit_cost_minor < 0:
        raise ValidationError(
            "GRN_LINE_INVALID", product_id=line.product_id, qty=line.qty_minor,
            cost=line.unit_cost_minor,
        )
    if not line_total_fits(line.unit_cost_minor, line.qty_minor, line.decimal_places):
        raise ValidationError("GRN_TOTAL_TOO_LARGE", product_id=line.product_id)


def receipt_total(lines: Iterable[ReceiptLine]) -> int:
    """What a receipt of valid lines bills: their costs, at most MONEY_MAX. Raises
    ValidationError GRN_TOTAL_TOO_LARGE."""
    total = sum(line.line_cost for line in lines)
    if total > MONEY_MAX:
        raise ValidationError("GRN_TOTAL_TOO_LARGE")
    return total
