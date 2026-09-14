"""Concrete IamService bound to a SQLAlchemy session. Employee & branch
administration: orchestrates a transaction, delegates rules to the domain, and
writes an audit entry in the same transaction as each change.

Every action is authorized in the TARGET's scope: the branch a role is granted
in, or every branch a user works in when acting on that user. Every branch keeps
an active owner and every user keeps an assignment. Disabling a user or
resetting a password revokes that user's sessions (identity-access invariant #4).
"""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import Select, select, update
from sqlalchemy.orm import Session

from dukan.application.access import require_any_permission, require_permission
from dukan.application.dto import BranchRole
from dukan.application.iam import BranchView, EmployeeView, IamService
from dukan.domain.branches import assert_branch_active, assert_not_last_active_branch
from dukan.domain.identity import (
    BranchAssignment,
    Permission,
    PermissionPolicy,
    User,
    UserStatus,
    assert_branch_keeps_owner,
    assert_keeps_an_assignment,
    assert_password_strong,
    assert_role_known,
    assert_shop_keeps_owner,
    assert_username_available,
)
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BranchAssignmentModel,
    BranchModel,
    SessionModel,
    UserModel,
)
from dukan.infrastructure.scope import require_everywhere
from dukan.infrastructure.security import passwords
from dukan.shared.errors import NotFoundError, PermissionDeniedError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()
_OWNER = "owner"


def _active_owner_query() -> Select[tuple[str, str]]:
    """(user_id, branch_id) of every live owner assignment of an active user.

    It locks the assignment AND user rows, so on PostgreSQL a concurrent demotion
    or disable waits, then re-reads the first one's change: two owners unseating
    each other cannot both pass. SQLite (dev) serializes writers only at commit,
    so there the check is best effort."""
    return (
        select(BranchAssignmentModel.user_id, BranchAssignmentModel.branch_id)
        .join(UserModel, UserModel.id == BranchAssignmentModel.user_id)
        .where(
            BranchAssignmentModel.role_name == _OWNER,
            BranchAssignmentModel.deleted_at.is_(None),
            UserModel.status == UserStatus.ACTIVE.value,
            UserModel.deleted_at.is_(None),
        )
        .order_by(BranchAssignmentModel.id)
        .with_for_update()
    )


class SqlIamService(IamService):
    def __init__(self, session: Session) -> None:
        self._s = session

    # ---- helpers ---------------------------------------------------------
    def _assignments(self, user_id: str) -> tuple[BranchAssignment, ...]:
        rows = self._s.scalars(
            select(BranchAssignmentModel)
            .where(
                BranchAssignmentModel.user_id == user_id,
                BranchAssignmentModel.deleted_at.is_(None),
            )
            .order_by(BranchAssignmentModel.created_at, BranchAssignmentModel.id)
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

    def _employee_view(self, m: UserModel, actor: User) -> EmployeeView:
        # Only the branches the actor manages: another branch's roles are not theirs.
        managed = self._branches_where(actor, Permission.USER_MANAGE)
        assignments = tuple(a for a in self._assignments(m.id) if a.branch_id in managed)
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

    @staticmethod
    def _is_owner_in(user: User, branch_id: str) -> bool:
        return user.is_active and any(
            a.branch_id == branch_id and a.role_name == _OWNER for a in user.assignments
        )

    def _require_can_grant(self, actor: User, branch_id: str, role_name: str) -> None:
        """Granting a role needs user.manage in that branch; granting owner needs
        owner rights there."""
        assert_role_known(role_name=role_name)
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        if role_name == _OWNER and not self._is_owner_in(actor, branch_id):
            raise PermissionDeniedError(
                "ACCESS_DENIED", permission=_OWNER, branch_id=branch_id, actor_id=actor.id
            )

    def _require_user_admin(self, actor: User, target: User, fallback_branch: str) -> None:
        """Acting on a user (status, password) needs user.manage in every branch
        they work in; acting on an owner needs owner rights in all of them."""
        branches = sorted({a.branch_id for a in target.assignments}) or [fallback_branch]
        for branch_id in branches:
            require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        if target.is_owner and not all(self._is_owner_in(actor, b) for b in branches):
            raise PermissionDeniedError(
                "ACCESS_DENIED", permission=_OWNER, user_id=target.id, actor_id=actor.id
            )

    def _active_owner_rows(self) -> list[tuple[str, str]]:
        return [(uid, bid) for uid, bid in self._s.execute(_active_owner_query()).tuples()]

    def _assert_owner_remains(self, branch_id: str, *, losing: str) -> None:
        """The branch must keep an active owner once `losing` stops being one."""
        owners_after = sum(
            1 for uid, bid in self._active_owner_rows() if bid == branch_id and uid != losing
        )
        assert_branch_keeps_owner(branch_id=branch_id, owners_after=owners_after)

    def _assert_shop_owner_remains(self, *, losing: str) -> None:
        """Some active user keeps owning every branch: they open branches and read
        the audit trail. Data that already has no such owner is not blocked."""
        owners = self._shop_owners()
        if owners:
            assert_shop_keeps_owner(owners_after=len(owners - {losing}))

    def _require_owner_rights_over(self, actor: User, target: User) -> None:
        """Owner rights in every branch the target works in: an owner of one branch
        cannot unseat the shop's owner there."""
        if not all(self._is_owner_in(actor, a.branch_id) for a in target.assignments):
            raise PermissionDeniedError(
                "ACCESS_DENIED", permission=_OWNER, user_id=target.id, actor_id=actor.id
            )

    def _unseat_owner(self, actor: User, m: UserModel, branch_id: str) -> None:
        """Taking an owner role away: owner rights over that owner, and both the
        branch and the shop keep an owner."""
        self._require_owner_rights_over(actor, self._domain_user(m))
        self._assert_owner_remains(branch_id, losing=m.id)
        self._assert_shop_owner_remains(losing=m.id)

    def _shop_owners(self) -> set[str]:
        """Active users who own every branch of the shop."""
        branch_ids = set(
            self._s.scalars(select(BranchModel.id).where(BranchModel.deleted_at.is_(None)))
        )
        owned: dict[str, set[str]] = {}
        for uid, bid in self._active_owner_rows():
            owned.setdefault(uid, set()).add(bid)
        return {uid for uid, bids in owned.items() if branch_ids <= bids}

    @staticmethod
    def _branches_where(actor: User, *perms: Permission) -> set[str]:
        return {
            a.branch_id
            for a in actor.assignments
            if any(_POLICY.can(actor, p, a.branch_id) for p in perms)
        }

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
        """Users who work in a branch the actor manages users in."""
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        managed = self._branches_where(actor, Permission.USER_MANAGE)
        rows = self._s.scalars(
            select(UserModel)
            .where(
                UserModel.deleted_at.is_(None),
                UserModel.id.in_(
                    select(BranchAssignmentModel.user_id).where(
                        BranchAssignmentModel.branch_id.in_(managed),
                        BranchAssignmentModel.deleted_at.is_(None),
                    )
                ),
            )
            .order_by(UserModel.display_name)
        ).all()
        return [self._employee_view(m, actor) for m in rows]

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
        self._require_can_grant(actor, branch_id, role_name)
        branch = self._require_branch(branch_id)
        assert_branch_active(branch_id=branch_id, is_active=branch.is_active)
        assert_password_strong(password=password)
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
        return self._employee_view(m, actor)

    def set_employee_status(
        self, *, actor: User, branch_id: str, user_id: str, active: bool
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        m = self._require_user(user_id)
        target = self._domain_user(m)
        self._require_user_admin(actor, target, branch_id)
        if not active:
            for owned in sorted({a.branch_id for a in target.assignments if a.role_name == _OWNER}):
                self._assert_owner_remains(owned, losing=target.id)
            if target.is_owner:
                self._assert_shop_owner_remains(losing=target.id)
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
        return self._employee_view(m, actor)

    def assign_role(
        self, *, actor: User, branch_id: str, user_id: str, target_branch_id: str, role_name: str
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        self._require_can_grant(actor, target_branch_id, role_name)
        m = self._require_user(user_id)
        target_branch = self._require_branch(target_branch_id)
        assert_branch_active(branch_id=target_branch_id, is_active=target_branch.is_active)
        existing = self._s.scalar(
            select(BranchAssignmentModel).where(
                BranchAssignmentModel.user_id == user_id,
                BranchAssignmentModel.branch_id == target_branch_id,
                BranchAssignmentModel.deleted_at.is_(None),
            )
        )
        if existing is not None:
            if existing.role_name == _OWNER and role_name != _OWNER:
                self._unseat_owner(actor, m, target_branch_id)
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
        return self._employee_view(m, actor)

    def revoke_assignment(
        self, *, actor: User, branch_id: str, user_id: str, target_branch_id: str
    ) -> EmployeeView:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        require_permission(_POLICY, actor, Permission.USER_MANAGE, target_branch_id)
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
        if row.role_name == _OWNER:
            self._unseat_owner(actor, m, target_branch_id)
        remaining = [a for a in self._assignments(user_id) if a.branch_id != target_branch_id]
        assert_keeps_an_assignment(user_id=user_id, remaining=len(remaining))
        row.deleted_at = datetime.now(UTC)
        row.updated_by = actor.id
        if m.default_branch_id == target_branch_id:
            # Requests without X-Branch-Id act in the default branch: keep it live.
            m.default_branch_id = remaining[0].branch_id
            m.updated_by = actor.id
            m.version += 1
        self._s.flush()
        self._audit(
            "role.revoked",
            actor_id=actor.id,
            entity_type="user",
            entity_id=user_id,
            after={"branch_id": target_branch_id, "default_branch_id": m.default_branch_id},
        )
        self._s.commit()
        return self._employee_view(m, actor)

    def reset_password(
        self, *, actor: User, branch_id: str, user_id: str, new_password: str
    ) -> None:
        require_permission(_POLICY, actor, Permission.USER_MANAGE, branch_id)
        m = self._require_user(user_id)
        self._require_user_admin(actor, self._domain_user(m), branch_id)
        assert_password_strong(password=new_password)
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
        """Branches the actor manages (branches or their staff)."""
        perms = (Permission.BRANCH_MANAGE, Permission.USER_MANAGE)
        require_any_permission(_POLICY, actor, perms, branch_id)
        visible = self._branches_where(actor, *perms)
        rows = self._s.scalars(
            select(BranchModel)
            .where(BranchModel.deleted_at.is_(None), BranchModel.id.in_(visible))
            .order_by(BranchModel.name)
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
        # Opening a branch is a shop-wide act: branch.manage in every branch.
        require_permission(_POLICY, actor, Permission.BRANCH_MANAGE, branch_id)
        require_everywhere(self._s, actor, Permission.BRANCH_MANAGE)
        owners = self._shop_owners() | {actor.id}
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
        # The shop's owners own the new branch too, so it can be administered.
        for owner_id in sorted(owners):
            self._s.add(
                BranchAssignmentModel(
                    id=new_id(),
                    user_id=owner_id,
                    branch_id=m.id,
                    role_name=_OWNER,
                    created_by=actor.id,
                )
            )
            self._audit(
                "role.assigned",
                actor_id=actor.id,
                entity_type="user",
                entity_id=owner_id,
                after={"branch_id": m.id, "role": _OWNER},
            )
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
        require_permission(_POLICY, actor, Permission.BRANCH_MANAGE, target_branch_id)
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
        require_permission(_POLICY, actor, Permission.BRANCH_MANAGE, target_branch_id)
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
