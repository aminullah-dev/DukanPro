"""Branch, discount and credit-limit guards (review theme 2). Mirror of
packages/dukan_core/test/access_rules_test.dart."""

import pytest

from dukan.domain.branches import assert_branch_active
from dukan.domain.customers import assert_credit_limit_valid
from dukan.domain.sales import assert_discount_valid
from dukan.shared.errors import ConflictError, ValidationError


def test_writes_need_an_active_branch() -> None:
    with pytest.raises(ConflictError) as e:
        assert_branch_active(branch_id="B1", is_active=False)
    assert e.value.code == "BRANCH_INACTIVE"
    assert_branch_active(branch_id="B1", is_active=True)  # no raise


@pytest.mark.parametrize("bad", [-1, 101])
def test_a_discount_lies_between_zero_and_the_subtotal(bad: int) -> None:
    with pytest.raises(ValidationError) as e:
        assert_discount_valid(discount_minor=bad, subtotal_minor=100)
    assert e.value.code == "SALE_DISCOUNT_INVALID"
    assert_discount_valid(discount_minor=0, subtotal_minor=100)  # no raise
    assert_discount_valid(discount_minor=100, subtotal_minor=100)  # no raise


def test_a_credit_limit_is_never_negative() -> None:
    with pytest.raises(ValidationError) as e:
        assert_credit_limit_valid(credit_limit_minor=-1)
    assert e.value.code == "CUSTOMER_CREDIT_LIMIT_INVALID"
    assert_credit_limit_valid(credit_limit_minor=None)  # unlimited
    assert_credit_limit_valid(credit_limit_minor=0)  # no credit
