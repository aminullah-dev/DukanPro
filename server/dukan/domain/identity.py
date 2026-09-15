"""Identity & Access domain. Mirrors packages/dukan_core/lib/domain/identity.dart
and docs/domain/identity-access.md — the SAME rules and test table in both
languages. Pure: imports only the shared error contract.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

from dukan.shared.errors import ConflictError, ValidationError


class Permission(StrEnum):
    SALE_CREATE = "sale.create"
    PRICE_CHANGE = "price.change"
    STOCK_ADJUST = "stock.adjust"
    PRODUCT_MANAGE = "product.manage"
    USER_MANAGE = "user.manage"
    REPORT_VIEW = "report.view"
    BRANCH_MANAGE = "branch.manage"
    DEBT_WRITE_OFF = "debt.write_off"
    AUDIT_VIEW = "audit.view"
    SALE_VOID = "sale.void"
    SALE_DISCOUNT = "sale.discount"
    CUSTOMER_CREDIT = "customer.credit"
    PURCHASE_COST = "purchase.cost"
    SETTINGS_MANAGE = "settings.manage"  # a device's own settings (idle lock)


# Built-in role name -> permission set. Single source for PermissionPolicy.
BUILTIN_ROLE_PERMISSIONS: dict[str, frozenset[Permission]] = {
    "owner": frozenset(Permission),
    "manager": frozenset({
        Permission.SALE_CREATE, Permission.PRICE_CHANGE, Permission.STOCK_ADJUST,
        Permission.PRODUCT_MANAGE, Permission.REPORT_VIEW, Permission.DEBT_WRITE_OFF,
        Permission.SALE_VOID, Permission.SALE_DISCOUNT, Permission.CUSTOMER_CREDIT,
        Permission.PURCHASE_COST, Permission.SETTINGS_MANAGE,
    }),
    "cashier": frozenset({Permission.SALE_CREATE}),
    "stock_keeper": frozenset({Permission.STOCK_ADJUST}),
    "accountant": frozenset({Permission.REPORT_VIEW, Permission.DEBT_WRITE_OFF}),
}


class UserStatus(StrEnum):
    ACTIVE = "active"
    DISABLED = "disabled"


@dataclass(frozen=True, slots=True)
class BranchAssignment:
    branch_id: str
    role_name: str


@dataclass(frozen=True, slots=True)
class User:
    id: str
    username: str
    display_name: str
    status: UserStatus
    assignments: tuple[BranchAssignment, ...] = ()
    default_branch_id: str | None = None
    version: int = 1

    @property
    def is_active(self) -> bool:
        return self.status is UserStatus.ACTIVE

    @property
    def is_owner(self) -> bool:
        return any(a.role_name == "owner" for a in self.assignments)


@dataclass(frozen=True, slots=True)
class PermissionPolicy:
    """The only place access is decided. Pure."""

    def permissions_for(self, user: User, branch_id: str) -> frozenset[Permission]:
        perms: set[Permission] = set()
        for a in user.assignments:
            if a.branch_id == branch_id:
                perms |= BUILTIN_ROLE_PERMISSIONS.get(a.role_name, frozenset())
        return frozenset(perms)

    def can(self, user: User, permission: Permission, branch_id: str) -> bool:
        if not user.is_active:
            return False
        return permission in self.permissions_for(user, branch_id)


def assert_branch_keeps_owner(*, branch_id: str, owners_after: int) -> None:
    """Every branch keeps at least one active owner, so someone can always
    administer it. `owners_after` counts the branch's active owners once the
    change applies. Raises ConflictError USER_LAST_OWNER."""
    if owners_after < 1:
        raise ConflictError("USER_LAST_OWNER", branch_id=branch_id)


def assert_shop_keeps_owner(*, owners_after: int) -> None:
    """Some active user keeps owning every branch, or nobody could open a branch
    or read the shop-wide audit trail. `owners_after` counts such users once the
    change applies. Raises ConflictError USER_LAST_OWNER."""
    if owners_after < 1:
        raise ConflictError("USER_LAST_OWNER", scope="shop")


def assert_keeps_an_assignment(*, user_id: str, remaining: int) -> None:
    """A user keeps at least one branch assignment. Raises ConflictError
    USER_LAST_ASSIGNMENT."""
    if remaining < 1:
        raise ConflictError("USER_LAST_ASSIGNMENT", user_id=user_id)


def assert_role_known(*, role_name: str) -> None:
    """Only built-in roles can be assigned until custom roles exist. Raises
    ValidationError ROLE_UNKNOWN."""
    if role_name not in BUILTIN_ROLE_PERMISSIONS:
        raise ValidationError("ROLE_UNKNOWN", role=role_name)


def assert_username_available(*, username: str, taken: bool) -> None:
    if taken:
        raise ConflictError("USER_DUPLICATE_USERNAME", username=username)


def assert_role_mutable(*, role_name: str) -> None:
    if role_name in BUILTIN_ROLE_PERMISSIONS:
        raise ConflictError("ROLE_BUILTIN_IMMUTABLE", role=role_name)


def assert_password_strong(*, password: str, min_length: int = 8) -> None:
    """A password must meet the minimum strength before it is hashed.
    Raises ValidationError WEAK_PASSWORD."""
    if len(password) < min_length:
        raise ValidationError("WEAK_PASSWORD", min_length=min_length)
