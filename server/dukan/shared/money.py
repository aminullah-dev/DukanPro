"""Money: integer minor units plus an ISO-4217 code. Floats are never permitted.

Mirrors packages/dukan_core/lib/shared/money.dart. Cross-currency arithmetic
raises ValidationError; there is no implicit conversion. AFN has 2 minor digits.
"""

from __future__ import annotations

from dataclasses import dataclass

from dukan.shared.errors import ValidationError


@dataclass(frozen=True, slots=True)
class Money:
    amount_minor: int
    currency: str

    def validated(self) -> Money:
        if len(self.currency) != 3 or self.currency.upper() != self.currency:
            raise ValidationError("MONEY_CURRENCY_INVALID", currency=self.currency)
        return self

    def _same(self, other: Money) -> None:
        if self.currency != other.currency:
            raise ValidationError(
                "MONEY_CURRENCY_MISMATCH", a=self.currency, b=other.currency
            )

    def __add__(self, other: Money) -> Money:
        self._same(other)
        return Money(self.amount_minor + other.amount_minor, self.currency)

    def __sub__(self, other: Money) -> Money:
        self._same(other)
        return Money(self.amount_minor - other.amount_minor, self.currency)

    def __mul__(self, qty: int) -> Money:
        if not isinstance(qty, int):
            raise ValidationError("MONEY_NON_INTEGER_SCALE", qty=repr(qty))
        return Money(self.amount_minor * qty, self.currency)

    @property
    def is_negative(self) -> bool:
        return self.amount_minor < 0

    @property
    def is_zero(self) -> bool:
        return self.amount_minor == 0
