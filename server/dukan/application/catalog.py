"""CatalogService port + view DTO. Concrete impl lives in infrastructure."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class ProductView:
    id: str
    sku: str
    name: str
    unit_id: str
    sell_price_minor: int
    sell_currency: str
    category_id: str | None
    track_stock: bool
    is_active: bool
    on_hand: int
    barcodes: tuple[str, ...]
    version: int = 1


class CatalogService(Protocol):
    def list_units(self) -> list[dict]: ...

    def create_product(
        self,
        *,
        actor: User,
        branch_id: str,
        sku: str,
        name: str,
        unit_id: str,
        sell_price_minor: int,
        currency: str,
        category_id: str | None,
        track_stock: bool,
        barcodes: list[str],
    ) -> ProductView: ...

    def update_product(
        self,
        *,
        actor: User,
        branch_id: str,
        product_id: str,
        name: str | None,
        sell_price_minor: int | None,
        is_active: bool | None,
        version: int | None = None,
        track_stock: bool | None = None,
        sku: str | None = None,
    ) -> ProductView: ...

    def add_barcode(
        self, *, actor: User, branch_id: str, product_id: str, code: str
    ) -> ProductView: ...

    def remove_barcode(
        self, *, actor: User, branch_id: str, product_id: str, code: str
    ) -> ProductView: ...

    def list_products(
        self, *, actor: User, branch_id: str, search: str | None
    ) -> list[ProductView]: ...

    def get_product(self, *, actor: User, branch_id: str, product_id: str) -> ProductView: ...

    def adjust_stock(
        self, *, actor: User, branch_id: str, product_id: str, qty_delta: int
    ) -> ProductView: ...
