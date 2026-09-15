"""Scope checks the Sql*Services share: writes happen only in an active branch,
and shop-wide actions need the permission in every branch."""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.domain.branches import assert_branch_active
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.infrastructure.db.models import BranchModel
from dukan.shared.errors import NotFoundError

_POLICY = PermissionPolicy()


def require_active_branch(session: Session, branch_id: str) -> BranchModel:
    """The branch a write happens in: it must exist and be active."""
    branch = session.scalar(
        select(BranchModel).where(BranchModel.id == branch_id, BranchModel.deleted_at.is_(None))
    )
    if branch is None:
        raise NotFoundError("BRANCH_NOT_FOUND", branch_id=branch_id)
    assert_branch_active(branch_id=branch_id, is_active=branch.is_active)
    return branch


def require_everywhere(session: Session, actor: User, permission: Permission) -> None:
    """Shop-wide actions (creating a branch, reading the whole audit trail) need
    the permission in every branch, not only in the one the request names."""
    for branch_id in session.scalars(
        select(BranchModel.id).where(BranchModel.deleted_at.is_(None)).order_by(BranchModel.id)
    ):
        require_permission(_POLICY, actor, permission, branch_id)
