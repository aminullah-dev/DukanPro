"""Minimal user management (Phase 1). Gated by the `user.manage` permission."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from dukan.application.auth import AuthService
from dukan.domain.identity import Permission, User
from dukan.shared.errors import ValidationError
from dukan.ui.deps import get_auth_service, requires
from dukan.ui.serializers import profile_dict

router = APIRouter(prefix="/users", tags=["users"])


class CreateUserRequest(BaseModel):
    username: str
    password: str
    display_name: str
    role_name: str = "cashier"
    branch_id: str | None = None


@router.post("")
def create_user(
    body: CreateUserRequest,
    actor: Annotated[User, Depends(requires(Permission.USER_MANAGE))],
    svc: Annotated[AuthService, Depends(get_auth_service)],
) -> dict:
    branch_id = body.branch_id or actor.default_branch_id
    if not branch_id:
        raise ValidationError("BRANCH_REQUIRED")
    return profile_dict(
        svc.create_user(
            actor=actor,
            branch_id=branch_id,
            username=body.username,
            password=body.password,
            display_name=body.display_name,
            role_name=body.role_name,
        )
    )
