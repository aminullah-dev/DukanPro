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


# Built-in role name -> permission set. Single source for PermissionPolicy.
BUILTIN_ROLE_PERMISSIONS: dict[str, frozenset[Permission]] = {
    "owner": frozenset(Permission),
    "manager": frozenset({
        Permission.SALE_CREATE, Permission.PRICE_CHANGE, Permission.STOCK_ADJUST,
        Permission.PRODUCT_MANAGE, Permission.REPORT_VIEW, Permission.DEBT_WRITE_OFF,
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


def assert_not_last_owner(*, target: User, active_owner_count: int) -> None:
    if target.is_owner and active_owner_count <= 1:
        raise ConflictError("USER_LAST_OWNER", user_id=target.id)


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
