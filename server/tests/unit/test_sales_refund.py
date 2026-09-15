"""What a return is worth and what it may take back (docs/domain/sales.md)."""

from __future__ import annotations

import pytest

from dukan.domain.sales import assert_refund_valid, refund_total_minor, returned_value_minor
from dukan.shared.errors import ValidationError


def test_a_returned_part_is_worth_its_share_of_the_line_rounded_half_up() -> None:
    assert returned_value_minor(line_total_minor=1000, sold_qty_minor=3, returned_qty_minor=1) == 333
    assert returned_value_minor(line_total_minor=1000, sold_qty_minor=3, returned_qty_minor=2) == 667
    # 1.5 kg of 3 kg sold for 9.00
    assert returned_value_minor(
        line_total_minor=900, sold_qty_minor=3000, returned_qty_minor=1500
    ) == 450
    assert returned_value_minor(line_total_minor=5, sold_qty_minor=2, returned_qty_minor=1) == 3


def test_a_return_gives_back_the_goods_less_their_share_of_the_discount() -> None:
    assert refund_total_minor(
        gross_minor=5000, sale_subtotal_minor=10000, sale_discount_minor=1000
    ) == 4500
    assert refund_total_minor(
        gross_minor=5000, sale_subtotal_minor=10000, sale_discount_minor=0
    ) == 5000


@pytest.mark.parametrize(
    ("reason", "wanted", "code"),
    [
        ("  ", {"p": 1}, "REFUND_REASON_REQUIRED"),
        ("damaged", {}, "REFUND_EMPTY"),
        ("damaged", {"p": 0}, "REFUND_QTY_INVALID"),
        ("damaged", {"p": 3}, "REFUND_QTY_INVALID"),
        ("damaged", {"q": 1}, "REFUND_QTY_INVALID"),
    ],
)
def test_a_return_says_why_and_takes_back_no_more_than_is_left(
    reason: str, wanted: dict[str, int], code: str
) -> None:
    with pytest.raises(ValidationError) as e:
        assert_refund_valid(reason=reason, wanted=wanted, returnable={"p": 2})
    assert e.value.code == code


def test_what_is_left_may_all_come_back() -> None:
    assert_refund_valid(reason="damaged", wanted={"p": 2}, returnable={"p": 2})
