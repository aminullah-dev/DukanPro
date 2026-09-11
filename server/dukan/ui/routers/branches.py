"""Branch administration (Phase 7). Listing is open to user.manage or
branch.manage (the employee-assignment UI needs it); mutations require
branch.manage. See docs/domain/branches.md."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel

from dukan.application.iam import IamService
from dukan.domain.identity import Permission, User
from dukan.shared.errors import ValidationError
from dukan.ui.deps import get_current_actor, get_iam_service, requires
from dukan.ui.serializers import branch_dict

router = APIRouter(prefix="/branches", tags=["branches"])

_Manager = Annotated[User, Depends(requires(Permission.BRANCH_MANAGE))]
_Iam = Annotated[IamService, Depends(get_iam_service)]


def _active_branch(actor: User, x_branch_id: str | None) -> str:
    branch_id = x_branch_id or actor.default_branch_id
    if not branch_id:
        raise ValidationError("BRANCH_REQUIRED")
    return branch_id


class CreateBranchRequest(BaseModel):
    name: str
    timezone: str = "Asia/Kabul"
    currency_default: str = "AFN"


class UpdateBranchRequest(BaseModel):
    name: str | None = None
    active: bool | None = None


@router.get("")
def list_branches(
    actor: Annotated[User, Depends(get_current_actor)],
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    items = svc.list_branches(actor=actor, branch_id=branch_id)
    return {"branches": [branch_dict(b) for b in items]}


@router.post("")
def create_branch(
    body: CreateBranchRequest,
    actor: _Manager,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    return branch_dict(
        svc.create_branch(
            actor=actor,
            branch_id=branch_id,
            name=body.name,
            timezone=body.timezone,
            currency_default=body.currency_default,
        )
    )


@router.patch("/{target_branch_id}")
def update_branch(
    target_branch_id: str,
    body: UpdateBranchRequest,
    actor: _Manager,
    svc: _Iam,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    view = None
    if body.name is not None:
        view = svc.rename_branch(
            actor=actor, branch_id=branch_id, target_branch_id=target_branch_id, name=body.name
        )
    if body.active is not None:
        view = svc.set_branch_active(
            actor=actor, branch_id=branch_id, target_branch_id=target_branch_id, active=body.active
        )
    if view is None:
        raise ValidationError("BRANCH_NO_CHANGES")
    return branch_dict(view)
