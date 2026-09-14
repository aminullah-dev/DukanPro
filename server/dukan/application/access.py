"""Application-layer access guard. Mirrors packages/dukan_core/lib/application/
access.dart. ACCESS_DENIED is a permission concern raised here, never from the
pure domain predicates."""

from __future__ import annotations

from collections.abc import Iterable

from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.shared.errors import PermissionDeniedError


def require_permission(
    policy: PermissionPolicy, actor: User, permission: Permission, branch_id: str
) -> None:
    if not policy.can(actor, permission, branch_id):
        raise PermissionDeniedError(
            "ACCESS_DENIED",
            permission=permission.value,
            branch_id=branch_id,
            actor_id=actor.id,
        )


def require_any_permission(
    policy: PermissionPolicy, actor: User, permissions: Iterable[Permission], branch_id: str
) -> None:
    """Pass when the actor holds at least one of `permissions` in the branch."""
    wanted = tuple(permissions)
    if not any(policy.can(actor, p, branch_id) for p in wanted):
        raise PermissionDeniedError(
            "ACCESS_DENIED",
            permission="|".join(p.value for p in wanted),
            branch_id=branch_id,
            actor_id=actor.id,
        )
