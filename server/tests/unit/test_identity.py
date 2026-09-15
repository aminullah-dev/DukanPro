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
    assert_branch_keeps_owner,
    assert_keeps_an_assignment,
    assert_password_strong,
    assert_role_known,
    assert_role_mutable,
    assert_shop_keeps_owner,
    assert_username_available,
    login_locked,
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


def test_every_branch_keeps_an_owner() -> None:
    with pytest.raises(ConflictError) as e:
        assert_branch_keeps_owner(branch_id="B1", owners_after=0)
    assert e.value.code == "USER_LAST_OWNER"
    assert_branch_keeps_owner(branch_id="B1", owners_after=1)  # no raise


def test_the_shop_keeps_an_owner_of_every_branch() -> None:
    with pytest.raises(ConflictError) as e:
        assert_shop_keeps_owner(owners_after=0)
    assert e.value.code == "USER_LAST_OWNER" and e.value.context["scope"] == "shop"
    assert_shop_keeps_owner(owners_after=1)  # no raise


def test_a_user_keeps_an_assignment() -> None:
    with pytest.raises(ConflictError) as e:
        assert_keeps_an_assignment(user_id="u", remaining=0)
    assert e.value.code == "USER_LAST_ASSIGNMENT"
    assert_keeps_an_assignment(user_id="u", remaining=1)  # no raise


def test_only_builtin_roles_are_assignable() -> None:
    with pytest.raises(ValidationError) as e:
        assert_role_known(role_name="admin")
    assert e.value.code == "ROLE_UNKNOWN"
    assert_role_known(role_name="stock_keeper")  # no raise


def test_money_permissions_belong_to_owner_and_manager() -> None:
    money = (Permission.SALE_VOID, Permission.SALE_DISCOUNT, Permission.CUSTOMER_CREDIT,
             Permission.PURCHASE_COST)
    for role, allowed in (("owner", True), ("manager", True), ("cashier", False),
                          ("stock_keeper", False), ("accountant", False)):
        u = _user([BranchAssignment("B1", role)])
        assert all(POLICY.can(u, p, "B1") is allowed for p in money), role


def test_device_settings_belong_to_owner_and_manager() -> None:
    for role, allowed in (("owner", True), ("manager", True), ("cashier", False),
                          ("stock_keeper", False), ("accountant", False)):
        u = _user([BranchAssignment("B1", role)])
        assert POLICY.can(u, Permission.SETTINGS_MANAGE, "B1") is allowed, role


def test_sign_in_closes_after_five_wrong_passwords() -> None:
    assert not login_locked(failures_since_success=4)
    assert login_locked(failures_since_success=5)


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
