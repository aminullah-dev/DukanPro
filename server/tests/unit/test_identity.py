"""Mirror of packages/dukan_core/test/identity_test.dart and
docs/domain/identity-access.md."""

import pytest

from dukan.application.access import require_permission
from dukan.domain.identity import (
    BranchAssignment,
    Permission,
    PermissionPolicy,
    User,
    UserStatus,
    assert_not_last_owner,
    assert_password_strong,
    assert_role_mutable,
    assert_username_available,
)
from dukan.shared.errors import ConflictError, PermissionDeniedError, ValidationError

POLICY = PermissionPolicy()


def _user(assignments, status=UserStatus.ACTIVE) -> User:
    return User(id="x", username="u", display_name="U", status=status, assignments=tuple(assignments))


def test_cashier_cannot_change_price() -> None:
    u = _user([BranchAssignment("B1", "cashier")])
    assert POLICY.can(u, Permission.PRICE_CHANGE, "B1") is False
    with pytest.raises(PermissionDeniedError) as e:
        require_permission(POLICY, u, Permission.PRICE_CHANGE, "B1")
    assert e.value.code == "ACCESS_DENIED"


def test_owner_can_manage_users() -> None:
    u = _user([BranchAssignment("B1", "owner")])
    assert POLICY.can(u, Permission.USER_MANAGE, "B1") is True


def test_role_is_scoped_per_branch() -> None:
    u = _user([BranchAssignment("B1", "manager"), BranchAssignment("B2", "cashier")])
    assert POLICY.can(u, Permission.PRICE_CHANGE, "B1") is True
    assert POLICY.can(u, Permission.PRICE_CHANGE, "B2") is False


def test_disabled_user_has_no_permissions() -> None:
    u = _user([BranchAssignment("B1", "owner")], status=UserStatus.DISABLED)
    assert POLICY.can(u, Permission.SALE_CREATE, "B1") is False


def test_last_owner_protected() -> None:
    owner = _user([BranchAssignment("B1", "owner")])
    with pytest.raises(ConflictError) as e:
        assert_not_last_owner(target=owner, active_owner_count=1)
    assert e.value.code == "USER_LAST_OWNER"
    assert_not_last_owner(target=owner, active_owner_count=2)  # no raise


def test_duplicate_username_rejected() -> None:
    with pytest.raises(ConflictError) as e:
        assert_username_available(username="ahmad", taken=True)
    assert e.value.code == "USER_DUPLICATE_USERNAME"
    assert_username_available(username="ahmad", taken=False)  # no raise


def test_builtin_role_immutable() -> None:
    with pytest.raises(ConflictError) as e:
        assert_role_mutable(role_name="cashier")
    assert e.value.code == "ROLE_BUILTIN_IMMUTABLE"


def test_only_owner_can_view_audit() -> None:
    owner = _user([BranchAssignment("B1", "owner")])
    manager = _user([BranchAssignment("B1", "manager")])
    assert POLICY.can(owner, Permission.AUDIT_VIEW, "B1") is True
    assert POLICY.can(manager, Permission.AUDIT_VIEW, "B1") is False


def test_weak_password_rejected() -> None:
    with pytest.raises(ValidationError) as e:
        assert_password_strong(password="short")
    assert e.value.code == "WEAK_PASSWORD"
    assert_password_strong(password="longenough")  # no raise
