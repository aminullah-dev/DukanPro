"""Concrete IamService bound to a SQLAlchemy session. Employee & branch
administration: orchestrates a transaction, delegates rules to the domain, and
writes an audit entry in the same transaction as each change. Server-
authoritative and permission-gated; disabling a user or resetting a password
revokes that user's sessions (identity-access invariant #4)."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.dto import BranchRole
from dukan.application.iam import BranchView, EmployeeView, IamService
from dukan.domain.branches import assert_not_last_active_branch
from dukan.domain.identity import (
    BranchAssignment,
    Permission,
    PermissionPolicy,
    User,
    UserStatus,
    assert_not_last_owner,
    assert_username_available,
)
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BranchAssignmentModel,
    BranchModel,
    SessionModel,
    UserModel,
)
from dukan.infrastructure.security import passwords
from dukan.shared.errors import NotFoundError, PermissionDeniedError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()


class SqlIamService(IamService):
    def __init__(self, session: Session) -> None:
        self._s = session

    # ---- helpers ---------------------------------------------------------
    def _require_any(self, actor: User, branch_id: str, perms: tuple[Permission, ...]) -> None:
        if any(_POLICY.can(actor, p, branch_id) for p in perms):
            return
        raise PermissionDeniedError(
            "ACCESS_DENIED",
            permission="|".join(p.value for p in perms),
            branch_id=branch_id,
            actor_id=actor.id,
        )

    def _assignments(self, user_id: str) -> tuple[BranchAssignment, ...]:
        rows = self._s.scalars(
            select(BranchAssignmentModel).where(
                BranchAssignmentModel.user_id == user_id,
                BranchAssignmentModel.deleted_at.is_(None),
            )
        ).all()
        return tuple(BranchAssignment(branch_id=r.branch_id, role_name=r.role_name) for r in rows)

    def _domain_user(self, m: UserModel) -> User:
        return User(
            id=m.id,
            username=m.username,
            display_name=m.display_name,
            status=UserStatus(m.status),
            assignments=self._assignments(m.id),
            default_branch_id=m.default_branch_id,
            version=m.version,
        )

    def _branch_names(self, ids: set[str]) -> dict[str, str]:
        if not ids:
            return {}
        return {
            b.id: b.name
            for b in self._s.scalars(select(BranchModel).where(BranchModel.id.in_(ids)))
        }

    def _employee_view(self, m: UserModel) -> EmployeeView:
        assignments = self._assignments(m.id)
        names = self._branch_names({a.branch_id for a in assignments})
        return EmployeeView(
            id=m.id,
            username=m.username,
            display_name=m.display_name,
            status=m.status,
            default_branch_id=m.default_branch_id,
            branches=tuple(
                BranchRole(
                    branch_id=a.branch_id,
                    branch_name=names.get(a.branch_id, ""),
                    role_name=a.role_name,
                )
                for a in assignments
            ),
        )

    def _branch_view(self, m: BranchModel) -> BranchView:
        return BranchView(
            id=m.id,
            name=m.name,
            timezone=m.timezone,
            currency_default=m.currency_default,
            is_active=m.is_active,
        )

    def _require_user(self, user_id: str) -> UserModel:
        m = self._s.scalar(
            select(UserModel).where(UserModel.id == user_id, UserModel.deleted_at.is_(None))
        )
        if m is None:
            raise NotFoundError("USER_NOT_FOUND", user_id=user_id)
        return m

    def _require_branch(self, branch_id: str) -> BranchModel:
        m = self._s.scalar(
            select(BranchModel).where(BranchModel.id == branch_id, BranchModel.deleted_at.is_(None))
        )
        if m is None:
            raise NotFoundError("BRANCH_NOT_FOUND", branch_id=branch_id)
        return m

    def _active_owner_count(self) -> int:
        rows = self._s.scalars(
            select(UserModel.id).where(
                UserModel.status == "active", UserModel.deleted_at.is_(None)
            )
        ).all()
        return sum(1 for uid in rows if self._is_owner(uid))

    def _is_owner(self, user_id: str) -> bool:
        return any(a.role_name == "owner" for a in self._assignments(user_id))

    def _revoke_sessions(self, user_id: str) -> None:
        self._s.execute(
            update(SessionModel)
            .where(SessionModel.user_id == user_id, SessionModel.revoked_at.is_(None))
            .values(revoked_at=datetime.now(UTC))
        )

    def _audit(
        self,
        action: str,
        *,
        actor_id: str,
        entity_type: str,
        entity_id: str,
        after: dict | None = None,
    ) -> None:
        self._s.add(
            AuditEntryModel(
                id=new_id(),
                action=action,
                actor_id=actor_id,
                entity_type=entity_type,
                entity_id=entity_id,
                after=after,
                origin="api",
            )
        )

    # ---- employees -------------------------------------------------------
    def list_employees(self, *, actor: User, branch_id: str) -> list[EmployeeView]:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        rows = self._s.scalars(
            select(UserModel)
            .where(UserModel.deleted_at.is_(None))
            .order_by(UserModel.display_name)
        ).all()
        return [self._employee_view(m) for m in rows]

    def create_employee(
        self,
        *,
        actor: User,
        branch_id: str,
        username: str,
        password: str,
        display_name: str,
        role_name: str,
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        taken = (
            self._s.scalar(
                select(UserModel).where(
                    UserModel.username == username, UserModel.deleted_at.is_(None)
                )
            )
            is not None
        )
        assert_username_available(username=username, taken=taken)
        m = UserModel(
            id=new_id(),
            username=username,
            display_name=display_name,
            password_hash=passwords.hash_password(password),
            status="active",
            default_branch_id=branch_id,
            created_by=actor.id,
            updated_by=actor.id,
        )
        self._s.add(m)
        self._s.add(
            BranchAssignmentModel(
                id=new_id(),
                user_id=m.id,
                branch_id=branch_id,
                role_name=role_name,
                created_by=actor.id,
            )
        )
        self._s.flush()
        self._audit(
            "user.created",
            actor_id=actor.id,
            entity_type="user",
            entity_id=m.id,
            after={"username": username, "role": role_name, "branch_id": branch_id},
        )
        self._s.commit()
        return self._employee_view(m)

    def set_employee_status(
        self, *, actor: User, branch_id: str, user_id: str, active: bool
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        m = self._require_user(user_id)
        if not active:
            target = self._domain_user(m)
            assert_not_last_owner(target=target, active_owner_count=self._active_owner_count())
        m.status = "active" if active else "disabled"
        m.updated_by = actor.id
        m.version += 1
        if not active:
            self._revoke_sessions(user_id)
        self._s.flush()
        self._audit(
            "user.enabled" if active else "user.disabled",
            actor_id=actor.id,
            entity_type="user",
            entity_id=user_id,
        )
        self._s.commit()
        return self._employee_view(m)

    def assign_role(
        self, *, actor: User, branch_id: str, user_id: str, target_branch_id: str, role_name: str
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        m = self._require_user(user_id)
        self._require_branch(target_branch_id)
        existing = self._s.scalar(
            select(BranchAssignmentModel).where(
                BranchAssignmentModel.user_id == user_id,
                BranchAssignmentModel.branch_id == target_branch_id,
                BranchAssignmentModel.deleted_at.is_(None),
            )
        )
        if existing is not None:
            existing.role_name = role_name
            existing.updated_by = actor.id
            existing.version += 1
        else:
            self._s.add(
                BranchAssignmentModel(
                    id=new_id(),
                    user_id=user_id,
                    branch_id=target_branch_id,
                    role_name=role_name,
                    created_by=actor.id,
                )
            )
        self._s.flush()
        self._audit(
            "role.assigned",
            actor_id=actor.id,
            entity_type="user",
            entity_id=user_id,
            after={"branch_id": target_branch_id, "role": role_name},
        )
        self._s.commit()
        return self._employee_view(m)

    def revoke_assignment(
        self, *, actor: User, branch_id: str, user_id: str, target_branch_id: str
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        m = self._require_user(user_id)
        row = self._s.scalar(
            select(BranchAssignmentModel).where(
                BranchAssignmentModel.user_id == user_id,
                BranchAssignmentModel.branch_id == target_branch_id,
                BranchAssignmentModel.deleted_at.is_(None),
            )
        )
        if row is None:
            raise NotFoundError("ASSIGNMENT_NOT_FOUND", user_id=user_id, branch_id=target_branch_id)
        if row.role_name == "owner":
            # Dropping the owner role must not leave the shop ownerless.
            assert_not_last_owner(
                target=self._domain_user(m), active_owner_count=self._active_owner_count()
            )
        row.deleted_at = datetime.now(UTC)
        row.updated_by = actor.id
        self._s.flush()
        self._audit(
            "role.revoked",
            actor_id=actor.id,
            entity_type="user",
            entity_id=user_id,
            after={"branch_id": target_branch_id},
        )
        self._s.commit()
        return self._employee_view(m)

    def reset_password(
        self, *, actor: User, branch_id: str, user_id: str, new_password: str
    ) -> None:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        m = self._require_user(user_id)
        m.password_hash = passwords.hash_password(new_password)
        m.updated_by = actor.id
        m.version += 1
        self._revoke_sessions(user_id)
        self._s.flush()
        self._audit(
            "password.reset", actor_id=actor.id, entity_type="user", entity_id=user_id
        )
        self._s.commit()

    # ---- branches --------------------------------------------------------
    def list_branches(self, *, actor: User, branch_id: str) -> list[BranchView]:
        self._require_any(actor, branch_id, (Permission.BRANCH_MANAGE, Permission.USER_MANAGE))
        rows = self._s.scalars(
            select(BranchModel).where(BranchModel.deleted_at.is_(None)).order_by(BranchModel.name)
        ).all()
        return [self._branch_view(m) for m in rows]

    def create_branch(
        self,
        *,
        actor: User,
        branch_id: str,
        name: str,
        timezone: str = "Asia/Kabul",
        currency_default: str = "AFN",
    ) -> BranchView:
        require_permission(_POLICY, actor, Permission.BRANCH_MANAGE, branch_id)
        m = BranchModel(
            id=new_id(),
            name=name,
            timezone=timezone,
            currency_default=currency_default,
            is_active=True,
            created_by=actor.id,
            updated_by=actor.id,
        )
        self._s.add(m)
        self._s.flush()
        self._audit(
            "branch.created",
            actor_id=actor.id,
            entity_type="branch",
            entity_id=m.id,
            after={"name": name},
        )
        self._s.commit()
        return self._branch_view(m)

    def rename_branch(
        self, *, actor: User, branch_id: str, target_branch_id: str, name: str
    ) -> BranchView:
        require_permission(_POLICY, actor, Permission.BRANCH_MANAGE, branch_id)
        m = self._require_branch(target_branch_id)
        m.name = name
        m.updated_by = actor.id
        m.version += 1
        self._s.flush()
        self._audit(
            "branch.updated",
            actor_id=actor.id,
            entity_type="branch",
            entity_id=m.id,
            after={"name": name},
        )
        self._s.commit()
        return self._branch_view(m)

    def set_branch_active(
        self, *, actor: User, branch_id: str, target_branch_id: str, active: bool
    ) -> BranchView:
        require_permission(_POLICY, actor, Permission.BRANCH_MANAGE, branch_id)
        m = self._require_branch(target_branch_id)
        if not active:
            count = len(
                self._s.scalars(
                    select(BranchModel.id).where(
                        BranchModel.is_active.is_(True), BranchModel.deleted_at.is_(None)
                    )
                ).all()
            )
            assert_not_last_active_branch(active_branch_count=count)
        m.is_active = active
        m.updated_by = actor.id
        m.version += 1
        self._s.flush()
        self._audit(
            "branch.activated" if active else "branch.deactivated",
            actor_id=actor.id,
            entity_type="branch",
            entity_id=m.id,
        )
        self._s.commit()
        return self._branch_view(m)
