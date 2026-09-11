"""Mirror of packages/dukan_core/test/catalog_test.dart."""

import pytest

from dukan.domain.catalog import (
    assert_unique_barcode,
    assert_unique_sku,
    format_quantity,
    quantity_to_minor,
)
from dukan.shared.errors import ConflictError, ValidationError


def test_duplicate_sku_rejected() -> None:
    with pytest.raises(ConflictError) as e:
        assert_unique_sku(sku="A1", taken=True)
    assert e.value.code == "PRODUCT_DUPLICATE_SKU"


def test_duplicate_barcode_rejected() -> None:
    with pytest.raises(ConflictError) as e:
        assert_unique_barcode(code="5001", taken=True)
    assert e.value.code == "BARCODE_DUPLICATE"


def test_fractional_piece_rejected() -> None:
    with pytest.raises(ValidationError) as e:
        quantity_to_minor("1.5", 0)
    assert e.value.code == "CATALOG_UNIT_PRECISION"


def test_kg_round_trips() -> None:
    assert quantity_to_minor("1.250", 3) == 1250
    assert format_quantity(1250, 3) == "1.250"


def test_whole_and_negative() -> None:
    assert quantity_to_minor("2", 0) == 2
    assert format_quantity(-1500, 3) == "-1.500"
