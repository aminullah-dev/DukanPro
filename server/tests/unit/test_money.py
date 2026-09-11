"""Mirror of packages/dukan_core/test/money_test.dart."""

import pytest

from dukan.shared.errors import ValidationError
from dukan.shared.money import Money


def test_adds_and_subtracts_within_a_currency() -> None:
    assert Money(500, "AFN") + Money(250, "AFN") == Money(750, "AFN")
    assert Money(500, "AFN") - Money(200, "AFN") == Money(300, "AFN")


def test_scales_by_a_whole_quantity() -> None:
    assert Money(520, "AFN") * 3 == Money(1560, "AFN")


def test_rejects_cross_currency_arithmetic() -> None:
    with pytest.raises(ValidationError) as e:
        _ = Money(500, "AFN") + Money(5, "USD")
    assert e.value.code == "MONEY_CURRENCY_MISMATCH"


def test_validates_iso4217_shape() -> None:
    with pytest.raises(ValidationError):
        Money(1, "afn").validated()
    with pytest.raises(ValidationError):
        Money(1, "AF").validated()
    assert Money(1, "AFN").validated() == Money(1, "AFN")


def test_rejects_float_scale() -> None:
    with pytest.raises(ValidationError):
        _ = Money(100, "AFN") * 1.5  # type: ignore[operator]
