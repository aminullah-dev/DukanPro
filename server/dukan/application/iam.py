"""IamService port — employee & branch administration. The UI depends on this
Protocol; the DB-backed implementation lives in infrastructure. All operations
are server-authoritative and permission-gated (user.manage / branch.manage).
See docs/domain/identity-access.md and docs/domain/branches.md.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.application.dto import BranchRole
from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class EmployeeView:
    id: str
    username: str
    display_name: str
    status: str
    default_branch_id: str | None
    branches: tuple[BranchRole, ...]


@dataclass(frozen=True, slots=True)
class BranchView:
    id: str
    name: str
    timezone: str
    currency_default: str
    is_active: bool


class IamService(Protocol):
    # ---- employees -------------------------------------------------------
    def list_employees(self, *, actor: User, branch_id: str) -> list[EmployeeView]: ...

    def create_employee(
        self,
        *,
        actor: User,
        branch_id: str,
        username: str,
        password: str,
        display_name: str,
        role_name: str,
    ) -> EmployeeView: ...

    def set_employee_status(
        self, *, actor: User, branch_id: str, user_id: str, active: bool
    ) -> EmployeeView: ...

    def assign_role(
        self, *, actor: User, branch_id: str, user_id: str, target_branch_id: str, role_name: str
    ) -> EmployeeView: ...

    def revoke_assignment(
        self, *, actor: User, branch_id: str, user_id: str, target_branch_id: str
    ) -> EmployeeView: ...

    def reset_password(
        self, *, actor: User, branch_id: str, user_id: str, new_password: str
    ) -> None: ...

    # ---- branches --------------------------------------------------------
    def list_branches(self, *, actor: User, branch_id: str) -> list[BranchView]: ...

    def create_branch(
        self,
        *,
        actor: User,
        branch_id: str,
        name: str,
        timezone: str = "Asia/Kabul",
        currency_default: str = "AFN",
    ) -> BranchView: ...

    def rename_branch(
        self, *, actor: User, branch_id: str, target_branch_id: str, name: str
    ) -> BranchView: ...

    def set_branch_active(
        self, *, actor: User, branch_id: str, target_branch_id: str, active: bool
    ) -> BranchView: ...
