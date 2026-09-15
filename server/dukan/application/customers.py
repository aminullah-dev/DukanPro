"""CustomerService port + DTOs."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class CustomerView:
    id: str
    name: str
    phone: str | None
    credit_limit_minor: int | None
    currency: str
    balance_minor: int
    version: int
    is_active: bool


class CustomerService(Protocol):
    def create_customer(
        self, *, actor: User, branch_id: str, name: str, phone: str | None,
        credit_limit_minor: int | None,
    ) -> CustomerView: ...

    def list_customers(
        self, *, actor: User, branch_id: str, search: str | None
    ) -> list[CustomerView]: ...

    def get_customer(self, *, actor: User, branch_id: str, customer_id: str) -> CustomerView: ...

    def set_credit_limit(
        self, *, actor: User, branch_id: str, customer_id: str, credit_limit_minor: int | None,
        version: int,
    ) -> CustomerView: ...

    def record_payment(
        self, *, actor: User, branch_id: str, customer_id: str, amount_minor: int,
        method: str = "cash", shift_id: str | None = None,
    ) -> CustomerView: ...

    def set_active(
        self, *, actor: User, branch_id: str, customer_id: str, is_active: bool, version: int
    ) -> CustomerView: ...

    def write_off(
        self, *, actor: User, branch_id: str, customer_id: str, amount_minor: int
    ) -> CustomerView: ...
