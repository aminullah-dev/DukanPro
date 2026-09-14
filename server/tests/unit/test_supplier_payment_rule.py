"""A payment to a supplier: positive, and no more than owed. The same rows as
packages/dukan_core/test/supplier_payment_test.dart."""

from __future__ import annotations

import pytest

from dukan.domain.purchasing import assert_supplier_payment_valid
from dukan.shared.errors import AppError


@pytest.mark.parametrize(
    ("amount", "balance", "code"),
    [(0, 4000, "SUPPLIER_PAYMENT_INVALID"), (4001, 4000, "SUPPLIER_OVERPAYMENT")],
)
def test_a_supplier_payment_is_positive_and_within_the_balance(
    amount: int, balance: int, code: str
) -> None:
    with pytest.raises(AppError) as e:
        assert_supplier_payment_valid(amount_minor=amount, balance_minor=balance)
    assert e.value.code == code
    assert_supplier_payment_valid(amount_minor=1500, balance_minor=4000)
