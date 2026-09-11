"""Sample domain slice. Mirrors docs/domain/inventory.md and the Dart
implementation in packages/dukan_core/lib/domain/inventory.dart — the SAME test
table is applied in both languages (see tests/unit/test_inventory.py).

Pure: imports nothing but the shared error contract. No framework, no I/O, no
datetime.now() (a time value is passed in).
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from dukan.shared.errors import ConflictError, ValidationError


class StockReason(StrEnum):
    SALE = "sale"
    PURCHASE = "purchase"
    ADJUSTMENT = "adjustment"
    TRANSFER_IN = "transfer_in"
    TRANSFER_OUT = "transfer_out"
    COUNT = "count"
    RETURNED = "returned"


@dataclass(frozen=True, slots=True)
class StockMovement:
    """Append-only, immutable stock ledger entry."""

    id: str
    product_id: str
    branch_id: str
    qty_delta: int  # signed: negative for a sale
    reason: StockReason
    occurred_at: datetime


def on_hand(movements: Iterable[StockMovement]) -> int:
    """On-hand = sum of movement deltas."""
    return sum(m.qty_delta for m in movements)


def sell_from_stock(
    *,
    id: str,
    product_id: str,
    branch_id: str,
    qty: int,
    available: int,
    at: datetime,
) -> StockMovement:
    """Produce the sale movement, enforcing the single-device/online oversell rule.

    Raises ValidationError(STOCK_INVALID_QTY) or ConflictError(STOCK_INSUFFICIENT).
    """
    if qty <= 0:
        raise ValidationError("STOCK_INVALID_QTY", qty=qty)
    if qty > available:
        raise ConflictError("STOCK_INSUFFICIENT", requested=qty, available=available)
    return StockMovement(
        id=id,
        product_id=product_id,
        branch_id=branch_id,
        qty_delta=-qty,
        reason=StockReason.SALE,
        occurred_at=at,
    )


def adjust_stock(
    *,
    id: str,
    product_id: str,
    branch_id: str,
    qty_delta: int,
    at: datetime,
) -> StockMovement:
    """Manual stock adjustment; qty_delta is signed and must be non-zero.

    Raises ValidationError(STOCK_INVALID_QTY) when qty_delta == 0.
    """
    if qty_delta == 0:
        raise ValidationError("STOCK_INVALID_QTY", qty=qty_delta)
    return StockMovement(
        id=id,
        product_id=product_id,
        branch_id=branch_id,
        qty_delta=qty_delta,
        reason=StockReason.ADJUSTMENT,
        occurred_at=at,
    )
