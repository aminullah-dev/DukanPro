"""Application-layer access guard. Mirrors packages/dukan_core/lib/application/
access.dart. ACCESS_DENIED is a permission concern raised here, never from the
pure domain predicates."""

from __future__ import annotations

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
