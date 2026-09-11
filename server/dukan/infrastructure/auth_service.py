"""Concrete AuthService bound to a SQLAlchemy session. Implements the
application AuthService port: orchestrates a transaction, delegates all rules to
the domain, and writes an audit entry in the same transaction as each change."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from dukan.application.auth import AuthService
from dukan.application.dto import AuthenticatedUser, AuthResult, AuthTokens, BranchRole
from dukan.config import Settings
from dukan.domain.identity import (
    BUILTIN_ROLE_PERMISSIONS,
    BranchAssignment,
    User,
    UserStatus,
)
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BranchAssignmentModel,
    BranchModel,
    RoleModel,
    SessionModel,
    UserModel,
)
from dukan.infrastructure.security import passwords, tokens
from dukan.shared.errors import AuthError, ConflictError
from dukan.shared.ids import new_id


def _as_utc(dt: datetime) -> datetime:
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=UTC)


class SqlAuthService(AuthService):
    def __init__(self, session: Session, settings: Settings) -> None:
        self._s = session
        self._cfg = settings

    # ---- helpers ----------------------------------------------------------
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

    def _issue_session(self, user: User, device_id: str) -> AuthTokens:
        sid = new_id()
        raw_refresh = tokens.new_refresh_token()
        now = datetime.now(UTC)
        self._s.add(
            SessionModel(
                id=sid,
                user_id=user.id,
                device_id=device_id,
                refresh_hash=tokens.hash_refresh(raw_refresh),
                expires_at=now + timedelta(days=self._cfg.refresh_ttl_days),
            )
        )
        access = tokens.issue_access(
            secret=self._cfg.secret_key,
            user_id=user.id,
            session_id=sid,
            ttl_minutes=self._cfg.access_ttl_minutes,
        )
        return AuthTokens(access_token=access, refresh_token=raw_refresh)

    def _audit(
        self,
        action: str,
        *,
        actor_id: str | None = None,
        entity_type: str | None = None,
        entity_id: str | None = None,
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

    # ---- AuthService ------------------------------------------------------
    def bootstrap_owner(
        self, *, username: str, password: str, display_name: str, shop_name: str, device_id: str
    ) -> AuthResult:
        if self._s.scalar(select(UserModel).limit(1)) is not None:
            raise ConflictError("BOOTSTRAP_ALREADY_DONE")
        for name, perms in BUILTIN_ROLE_PERMISSIONS.items():
            self._s.add(RoleModel(id=new_id(), name=name, permissions=[p.value for p in perms]))
        branch = BranchModel(id=new_id(), name=shop_name)
        self._s.add(branch)
        owner = UserModel(
            id=new_id(),
            username=username,
            display_name=display_name,
            password_hash=passwords.hash_password(password),
            status="active",
            default_branch_id=branch.id,
        )
        self._s.add(owner)
        self._s.add(
            BranchAssignmentModel(
                id=new_id(), user_id=owner.id, branch_id=branch.id, role_name="owner"
            )
        )
        self._s.flush()
        user = self._domain_user(owner)
        toks = self._issue_session(user, device_id)
        self._audit("owner.bootstrapped", actor_id=owner.id, entity_type="user", entity_id=owner.id)
        self._s.commit()
        return AuthResult(user=self.profile(user), tokens=toks)

    def authenticate(self, *, username: str, password: str, device_id: str) -> AuthResult:
        m = self._s.scalar(
            select(UserModel).where(
                UserModel.username == username, UserModel.deleted_at.is_(None)
            )
        )
        if m is None or not passwords.verify_password(m.password_hash, password):
            raise AuthError("INVALID_CREDENTIALS")
        if m.status != "active":
            raise AuthError("USER_DISABLED")
        user = self._domain_user(m)
        toks = self._issue_session(user, device_id)
        self._audit("user.authenticated", actor_id=m.id, entity_type="user", entity_id=m.id)
        self._s.commit()
        return AuthResult(user=self.profile(user), tokens=toks)

    def refresh(self, *, refresh_token: str) -> AuthTokens:
        sess = self._s.scalar(
            select(SessionModel).where(
                SessionModel.refresh_hash == tokens.hash_refresh(refresh_token)
            )
        )
        now = datetime.now(UTC)
        if sess is None or sess.revoked_at is not None or _as_utc(sess.expires_at) <= now:
            raise AuthError("REFRESH_INVALID")
        m = self._s.get(UserModel, sess.user_id)
        if m is None or m.status != "active":
            raise AuthError("USER_DISABLED")
        sess.revoked_at = now  # rotate: invalidate the presented refresh token
        toks = self._issue_session(self._domain_user(m), sess.device_id)
        self._s.commit()
        return toks

    def logout(self, *, refresh_token: str) -> None:
        sess = self._s.scalar(
            select(SessionModel).where(
                SessionModel.refresh_hash == tokens.hash_refresh(refresh_token)
            )
        )
        if sess is not None and sess.revoked_at is None:
            sess.revoked_at = datetime.now(UTC)
            self._audit("user.logout", actor_id=sess.user_id)
            self._s.commit()

    def authenticated_user(self, *, access_token: str) -> User:
        claims = tokens.decode_access(secret=self._cfg.secret_key, token=access_token)
        sess = self._s.get(SessionModel, claims.get("sid", ""))
        if sess is None or sess.revoked_at is not None:
            raise AuthError("SESSION_REVOKED")
        m = self._s.get(UserModel, claims.get("sub", ""))
        if m is None or m.status != "active":
            raise AuthError("USER_DISABLED")
        return self._domain_user(m)

    def profile(self, user: User) -> AuthenticatedUser:
        branch_ids = {a.branch_id for a in user.assignments}
        names: dict[str, str] = {}
        if branch_ids:
            for b in self._s.scalars(select(BranchModel).where(BranchModel.id.in_(branch_ids))):
                names[b.id] = b.name
        branches = tuple(
            BranchRole(
                branch_id=a.branch_id,
                branch_name=names.get(a.branch_id, ""),
                role_name=a.role_name,
            )
            for a in user.assignments
        )
        return AuthenticatedUser(
            id=user.id,
            username=user.username,
            display_name=user.display_name,
            default_branch_id=user.default_branch_id,
            branches=branches,
        )
