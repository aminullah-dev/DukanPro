"""PurchasingService port + DTOs."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class SupplierView:
    id: str
    name: str
    phone: str | None
    currency: str
    balance_minor: int


@dataclass(frozen=True, slots=True)
class ReceiptLineInput:
    product_id: str
    qty_minor: int
    unit_cost_minor: int


@dataclass(frozen=True, slots=True)
class GoodsReceiptView:
    id: str
    number: str
    supplier_id: str | None
    total_cost_minor: int


class PurchasingService(Protocol):
    def create_supplier(
        self, *, actor: User, branch_id: str, name: str, phone: str | None
    ) -> SupplierView: ...

    def list_suppliers(self) -> list[SupplierView]: ...

    def receive_goods(
        self, *, actor: User, branch_id: str, supplier_id: str | None, lines: list[ReceiptLineInput]
    ) -> GoodsReceiptView: ...
