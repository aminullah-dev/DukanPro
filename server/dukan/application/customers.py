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


class CustomerService(Protocol):
    def create_customer(
        self, *, actor: User, branch_id: str, name: str, phone: str | None,
        credit_limit_minor: int | None,
    ) -> CustomerView: ...

    def list_customers(self, *, search: str | None) -> list[CustomerView]: ...

    def get_customer(self, *, customer_id: str) -> CustomerView: ...

    def record_payment(
        self, *, actor: User, branch_id: str, customer_id: str, amount_minor: int
    ) -> CustomerView: ...
