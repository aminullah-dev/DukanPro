"""Customers & debt domain. Mirrors packages/dukan_core/lib/domain/customers.dart."""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from dukan.shared.errors import ConflictError, ValidationError


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


def assert_debt_payment_valid(*, amount_minor: int) -> None:
    """A debt payment is a positive amount: a negative one would add debt past
    the credit limit without a sale. Raises ValidationError DEBT_PAYMENT_INVALID."""
    if amount_minor <= 0:
        raise ValidationError("DEBT_PAYMENT_INVALID", amount=amount_minor)


def assert_write_off_valid(*, amount_minor: int, balance_minor: int) -> None:
    """A write-off forgives part or all of what the customer owes: a positive
    amount no larger than the balance. Raises ValidationError
    DEBT_WRITE_OFF_INVALID or ConflictError DEBT_WRITE_OFF_EXCEEDS_BALANCE."""
    if amount_minor <= 0:
        raise ValidationError("DEBT_WRITE_OFF_INVALID", amount=amount_minor)
    if amount_minor > balance_minor:
        raise ConflictError(
            "DEBT_WRITE_OFF_EXCEEDS_BALANCE", amount=amount_minor, balance=balance_minor
        )


def assert_customer_can_buy_on_credit(
    *, is_active: bool, customer_currency: str, sale_currency: str
) -> None:
    """Credit goes only to an active customer, in the customer's currency (ledgers
    never convert). Raises ConflictError CUSTOMER_INACTIVE or
    DEBT_CURRENCY_MISMATCH."""
    if not is_active:
        raise ConflictError("CUSTOMER_INACTIVE")
    if sale_currency != customer_currency:
        raise ConflictError(
            "DEBT_CURRENCY_MISMATCH", expected=customer_currency, got=sale_currency
        )


def assert_credit_limit_valid(*, credit_limit_minor: int | None) -> None:
    """A credit limit is None (unlimited) or a non-negative amount. Raises
    ValidationError CUSTOMER_CREDIT_LIMIT_INVALID."""
    if credit_limit_minor is not None and credit_limit_minor < 0:
        raise ValidationError("CUSTOMER_CREDIT_LIMIT_INVALID", limit=credit_limit_minor)
