"""Employee administration (Phase 7). Server-authoritative; every endpoint is
gated by the `user.manage` permission. Builds on the Identity & Access domain
shipped in Phase 1. See docs/domain/identity-access.md."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel

from dukan.application.iam import IamService
from dukan.domain.identity import Permission, User
from dukan.shared.errors import ValidationError
from dukan.ui.deps import get_iam_service, requires
from dukan.ui.fields import Id, Secret, Str32, Str64, Str128
from dukan.ui.serializers import employee_dict

router = APIRouter(prefix="/users", tags=["users"])

_Actor = Annotated[User, Depends(requires(Permission.USER_MANAGE))]
_Iam = Annotated[IamService, Depends(get_iam_service)]


def _active_branch(actor: User, x_branch_id: str | None) -> str:
    branch_id = x_branch_id or actor.default_branch_id
    if not branch_id:
        raise ValidationError("BRANCH_REQUIRED")
    return branch_id


class CreateUserRequest(BaseModel):
    username: Str64
    password: Secret
    display_name: Str128
    role_name: Str32 = "cashier"
    branch_id: Id | None = None


class StatusRequest(BaseModel):
    active: bool


class RoleRequest(BaseModel):
    branch_id: Id
    role_name: Str32


class PasswordRequest(BaseModel):
    new_password: Secret


@router.get("")
def list_users(
    actor: _Actor,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    employees = svc.list_employees(actor=actor, branch_id=branch_id)
    return {"users": [employee_dict(e) for e in employees]}


@router.post("")
def create_user(
    body: CreateUserRequest,
    actor: _Actor,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = body.branch_id or _active_branch(actor, x_branch_id)
    return employee_dict(
        svc.create_employee(
            actor=actor,
            branch_id=branch_id,
            username=body.username,
            password=body.password,
            display_name=body.display_name,
            role_name=body.role_name,
        )
    )


@router.patch("/{user_id}/status")
def set_status(
    user_id: str,
    body: StatusRequest,
    actor: _Actor,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    view = svc.set_employee_status(
        actor=actor, branch_id=branch_id, user_id=user_id, active=body.active
    )
    return employee_dict(view)


@router.post("/{user_id}/roles")
def assign_role(
    user_id: str,
    body: RoleRequest,
    actor: _Actor,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    return employee_dict(
        svc.assign_role(
            actor=actor,
            branch_id=branch_id,
            user_id=user_id,
            target_branch_id=body.branch_id,
            role_name=body.role_name,
        )
    )


@router.delete("/{user_id}/roles/{target_branch_id}")
def revoke_assignment(
    user_id: str,
    target_branch_id: str,
    actor: _Actor,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    return employee_dict(
        svc.revoke_assignment(
            actor=actor, branch_id=branch_id, user_id=user_id, target_branch_id=target_branch_id
        )
    )


@router.post("/{user_id}/password")
def reset_password(
    user_id: str,
    body: PasswordRequest,
    actor: _Actor,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    svc.reset_password(
        actor=actor, branch_id=branch_id, user_id=user_id, new_password=body.new_password
    )
    return {"status": "ok"}
