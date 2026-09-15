"""SalesService port + DTOs. Concrete impl in infrastructure."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class SaleLineInput:
    product_id: str
    qty_minor: int


@dataclass(frozen=True, slots=True)
class PaymentInput:
    method: str
    amount_minor: int
    tendered_minor: int | None = None


@dataclass(frozen=True, slots=True)
class RefundLineInput:
    product_id: str
    qty_minor: int  # how much of the product comes back, in its unit's minor units


@dataclass(frozen=True, slots=True)
class SaleLineView:
    product_id: str
    name: str
    qty_minor: int
    unit_price_minor: int
    line_total_minor: int


@dataclass(frozen=True, slots=True)
class SaleView:
    id: str
    number: str
    branch_id: str
    status: str
    currency: str
    subtotal_minor: int
    discount_minor: int
    total_minor: int
    paid_minor: int
    change_minor: int
    customer_id: str | None
    lines: tuple[SaleLineView, ...]
    refund_of: str | None = None  # a return: the sale it takes goods back from


@dataclass(frozen=True, slots=True)
class ShiftView:
    id: str
    status: str
    opening_float_minor: int
    expected_cash_minor: int | None
    counted_cash_minor: int | None
    variance_minor: int | None


class SalesService(Protocol):
    def settle_sale(
        self,
        *,
        actor: User,
        branch_id: str,
        lines: list[SaleLineInput],
        discount_minor: int,
        payments: list[PaymentInput],
        shift_id: str | None,
        customer_id: str | None,
    ) -> SaleView: ...

    def void_sale(self, *, actor: User, sale_id: str, reason: str) -> SaleView: ...

    def refund_sale(
        self, *, actor: User, sale_id: str, lines: list[RefundLineInput], reason: str,
        method: str, shift_id: str | None,
    ) -> SaleView: ...

    def get_sale(self, *, actor: User, sale_id: str) -> SaleView: ...

    def open_shift(self, *, actor: User, branch_id: str, opening_float_minor: int) -> ShiftView: ...

    def close_shift(self, *, actor: User, shift_id: str, counted_cash_minor: int) -> ShiftView: ...
