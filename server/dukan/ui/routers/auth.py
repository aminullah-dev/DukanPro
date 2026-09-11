"""Auth endpoints. Depend on the AuthService port only."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from dukan.application.auth import AuthService
from dukan.domain.identity import User
from dukan.ui.deps import get_auth_service, get_current_actor
from dukan.ui.serializers import auth_result, profile_dict, tokens_dict

router = APIRouter(prefix="/auth", tags=["auth"])


class BootstrapRequest(BaseModel):
    username: str
    password: str
    display_name: str
    shop_name: str = "My Shop"
    device_id: str = "unknown"


class LoginRequest(BaseModel):
    username: str
    password: str
    device_id: str = "unknown"


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutRequest(BaseModel):
    refresh_token: str


@router.post("/bootstrap")
def bootstrap(
    body: BootstrapRequest, svc: Annotated[AuthService, Depends(get_auth_service)]
) -> dict:
    return auth_result(
        svc.bootstrap_owner(
            username=body.username,
            password=body.password,
            display_name=body.display_name,
            shop_name=body.shop_name,
            device_id=body.device_id,
        )
    )


@router.post("/login")
def login(body: LoginRequest, svc: Annotated[AuthService, Depends(get_auth_service)]) -> dict:
    return auth_result(
        svc.authenticate(username=body.username, password=body.password, device_id=body.device_id)
    )


@router.post("/refresh")
def refresh(body: RefreshRequest, svc: Annotated[AuthService, Depends(get_auth_service)]) -> dict:
    return tokens_dict(svc.refresh(refresh_token=body.refresh_token))


@router.post("/logout")
def logout(body: LogoutRequest, svc: Annotated[AuthService, Depends(get_auth_service)]) -> dict:
    svc.logout(refresh_token=body.refresh_token)
    return {"status": "ok"}


@router.get("/me")
def me(
    actor: Annotated[User, Depends(get_current_actor)],
    svc: Annotated[AuthService, Depends(get_auth_service)],
) -> dict:
    return profile_dict(svc.profile(actor))
