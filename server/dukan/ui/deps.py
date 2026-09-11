"""FastAPI dependencies. Depend only on APPLICATION ports + domain — never on
infrastructure. The concrete, DB-backed auth service is injected by the
composition root via dependency override."""

from __future__ import annotations

from collections.abc import Callable
from typing import Annotated

from fastapi import Depends, Header

from dukan.application.access import require_permission
from dukan.application.auth import AuthService
from dukan.application.catalog import CatalogService
from dukan.application.customers import CustomerService
from dukan.application.purchasing import PurchasingService
from dukan.application.sales import SalesService
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.shared.errors import AuthError, ValidationError

_POLICY = PermissionPolicy()


def get_auth_service() -> AuthService:
    # Replaced in composition.py with a request-scoped, DB-backed implementation.
    raise NotImplementedError("auth service not wired")


def get_catalog_service() -> CatalogService:
    # Replaced in composition.py with a request-scoped, DB-backed implementation.
    raise NotImplementedError("catalog service not wired")


def get_sales_service() -> SalesService:
    # Replaced in composition.py with a request-scoped, DB-backed implementation.
    raise NotImplementedError("sales service not wired")


def get_customer_service() -> CustomerService:
    raise NotImplementedError("customer service not wired")


def get_purchasing_service() -> PurchasingService:
    raise NotImplementedError("purchasing service not wired")


def active_branch(actor: User, x_branch_id: str | None) -> str:
    branch_id = x_branch_id or actor.default_branch_id
    if not branch_id:
        raise ValidationError("BRANCH_REQUIRED")
    return branch_id


def get_current_actor(
    svc: Annotated[AuthService, Depends(get_auth_service)],
    authorization: Annotated[str | None, Header()] = None,
) -> User:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise AuthError("AUTH_REQUIRED")
    token = authorization.split(" ", 1)[1].strip()
    return svc.authenticated_user(access_token=token)


def requires(permission: Permission) -> Callable[..., User]:
    """Build a dependency that enforces `permission` for the active branch."""

    def dependency(
        actor: Annotated[User, Depends(get_current_actor)],
        x_branch_id: Annotated[str | None, Header()] = None,
    ) -> User:
        branch_id = x_branch_id or actor.default_branch_id
        if not branch_id:
            raise ValidationError("BRANCH_REQUIRED")
        require_permission(_POLICY, actor, permission, branch_id)
        return actor

    return dependency
