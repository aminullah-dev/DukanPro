"""Branch domain guard (mirrors packages/dukan_core branches_test.dart)."""

from __future__ import annotations

import pytest

from dukan.domain.branches import assert_not_last_active_branch
from dukan.shared.errors import ConflictError


def test_deactivating_one_of_several_is_allowed() -> None:
    assert_not_last_active_branch(active_branch_count=2)  # no raise


def test_deactivating_the_last_active_branch_is_blocked() -> None:
    with pytest.raises(ConflictError) as e:
        assert_not_last_active_branch(active_branch_count=1)
    assert e.value.code == "BRANCH_LAST_ACTIVE"
