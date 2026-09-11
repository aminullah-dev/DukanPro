"""Customers & debt domain. Mirrors packages/dukan_core/lib/domain/customers.dart."""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from dukan.shared.errors import ConflictError


class LedgerEntryType(StrEnum):
    OPENING = "opening"
    CHARGE = "charge"
    PAYMENT = "payment"
    ADJUSTMENT = "adjustment"


@dataclass(frozen=True, slots=True)
class Customer:
    id: str
    name: str
    phone: str | None = None
    credit_limit_minor: int | None = None
    currency: str = "AFN"
    is_active: bool = True
    version: int = 1


@dataclass(frozen=True, slots=True)
class CustomerLedgerEntry:
    id: str
    customer_id: str
    type: LedgerEntryType
    amount_minor: int
    currency: str
    occurred_at: datetime
    ref_type: str | None = None
    ref_id: str | None = None

    @property
    def signed(self) -> int:
        return -self.amount_minor if self.type is LedgerEntryType.PAYMENT else self.amount_minor


def ledger_balance(entries: Iterable[CustomerLedgerEntry]) -> int:
    return sum(e.signed for e in entries)


def assert_within_credit_limit(
    *, balance_minor: int, charge_minor: int, credit_limit_minor: int | None = None
) -> None:
    if credit_limit_minor is not None and balance_minor + charge_minor > credit_limit_minor:
        raise ConflictError(
            "SALE_OVER_CREDIT_LIMIT",
            limit=credit_limit_minor, balance=balance_minor, attempted=charge_minor,
        )


def assert_not_overpaid(*, balance_minor: int, payment_minor: int) -> None:
    if payment_minor > balance_minor:
        raise ConflictError("DEBT_OVERPAYMENT", balance=balance_minor, payment=payment_minor)
