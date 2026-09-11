"""Purchasing domain. Mirrors packages/dukan_core/lib/domain/purchasing.dart."""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum


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
    product_id: str
    qty_minor: int
    unit_cost_minor: int

    @property
    def line_cost(self) -> int:
        return self.unit_cost_minor * self.qty_minor
