"""Mirror of packages/dukan_core/test/inventory_test.dart and
docs/domain/inventory.md. The SAME rows run in Dart and Python."""

from datetime import UTC, datetime

import pytest

from dukan.domain.inventory import StockMovement, StockReason, on_hand, sell_from_stock
from dukan.shared.errors import ConflictError, ValidationError
from dukan.shared.ids import new_id

AT = datetime(2026, 9, 11, tzinfo=UTC)


def _mv(delta: int, reason: StockReason) -> StockMovement:
    return StockMovement(
        id=new_id(), product_id="A1", branch_id="B1",
        qty_delta=delta, reason=reason, occurred_at=AT,
    )


def test_on_hand_sums_the_ledger() -> None:
    movements = [_mv(10, StockReason.PURCHASE), _mv(-3, StockReason.SALE)]
    assert on_hand(movements) == 7


def test_oversell_online_raises_stock_insufficient() -> None:
    with pytest.raises(ConflictError) as e:
        sell_from_stock(
            id=new_id(), product_id="A1", branch_id="B1",
            qty=5, available=2, at=AT,
        )
    assert e.value.code == "STOCK_INSUFFICIENT"
    assert e.value.context["available"] == 2


def test_selling_within_stock_yields_negative_movement() -> None:
    m = sell_from_stock(
        id=new_id(), product_id="A1", branch_id="B1",
        qty=3, available=7, at=AT,
    )
    assert m.qty_delta == -3
    assert m.reason is StockReason.SALE


def test_non_positive_qty_raises() -> None:
    with pytest.raises(ValidationError) as e:
        sell_from_stock(
            id=new_id(), product_id="A1", branch_id="B1",
            qty=0, available=7, at=AT,
        )
    assert e.value.code == "STOCK_INVALID_QTY"
