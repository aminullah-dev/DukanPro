"""Catalog domain. Mirrors packages/dukan_core/lib/domain/catalog.dart and
docs/domain/catalog.md. Simple products with multiple barcodes (no variants).
Quantities are integers in the unit's minor granularity (10^decimal_places).
"""

from __future__ import annotations

from dataclasses import dataclass

from dukan.domain.numbers import NumberProblem, parse_scaled
from dukan.shared.errors import ConflictError, ValidationError
from dukan.shared.limits import MONEY_MAX
from dukan.shared.money import Money


@dataclass(frozen=True, slots=True)
class Unit:
    id: str
    name: str
    decimal_places: int


@dataclass(frozen=True, slots=True)
class Category:
    id: str
    name: str
    parent_id: str | None = None


@dataclass(frozen=True, slots=True)
class Product:
    id: str
    sku: str
    name: str
    unit_id: str
    sell_price: Money
    category_id: str | None = None
    cost: Money | None = None
    track_stock: bool = True
    is_active: bool = True
    version: int = 1


@dataclass(frozen=True, slots=True)
class Barcode:
    id: str
    product_id: str
    code: str
    symbology: str = "ean13"


def assert_unique_sku(*, sku: str, taken: bool) -> None:
    if taken:
        raise ConflictError("PRODUCT_DUPLICATE_SKU", sku=sku)


def assert_unique_barcode(*, code: str, taken: bool) -> None:
    if taken:
        raise ConflictError("BARCODE_DUPLICATE", barcode=code)


def quantity_to_minor(value: str, decimal_places: int) -> int:
    """Parse a user quantity (Persian or Latin digits) into integer minor units.

    Raises ValidationError CATALOG_UNIT_PRECISION (too many decimals) or
    CATALOG_QTY_INVALID (not a number, or too large).
    """
    parsed, problem = parse_scaled(value, decimal_places)
    if problem is NumberProblem.TOO_PRECISE:
        raise ValidationError("CATALOG_UNIT_PRECISION", allowed=decimal_places)
    if parsed is None:
        raise ValidationError("CATALOG_QTY_INVALID", input=value[:32])
    return parsed


def assert_price_valid(*, sell_price_minor: int) -> None:
    """A selling price is zero or more: a free item is fine, a negative price
    would pay the customer. Raises ValidationError CATALOG_PRICE_INVALID."""
    if not 0 <= sell_price_minor <= MONEY_MAX:
        raise ValidationError("CATALOG_PRICE_INVALID", price=sell_price_minor)


def format_quantity(minor: int, decimal_places: int) -> str:
    if decimal_places == 0:
        return str(minor)
    negative = minor < 0
    magnitude = abs(minor)
    unit = 10**decimal_places
    whole = magnitude // unit
    frac = str(magnitude % unit).rjust(decimal_places, "0")
    return f"{'-' if negative else ''}{whole}.{frac}"
