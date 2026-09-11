"""SQLAlchemy models. One table per Phase 1 identity concern + the audit log.
Schema parity with the Drift client is kept via docs/domain + mirrored tests."""

from __future__ import annotations

from datetime import datetime

from sqlalchemy import JSON, Boolean, DateTime, String
from sqlalchemy.orm import Mapped, mapped_column

from dukan.infrastructure.db.base import Base, RecordMixin, utcnow


class UserModel(RecordMixin, Base):
    __tablename__ = "users"
    username: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    display_name: Mapped[str] = mapped_column(String(128))
    password_hash: Mapped[str] = mapped_column(String(255))
    status: Mapped[str] = mapped_column(String(16), default="active")
    default_branch_id: Mapped[str | None] = mapped_column(String(36), default=None)


class RoleModel(RecordMixin, Base):
    __tablename__ = "roles"
    name: Mapped[str] = mapped_column(String(32), unique=True)
    permissions: Mapped[list] = mapped_column(JSON, default=list)


class BranchModel(RecordMixin, Base):
    __tablename__ = "branches"
    name: Mapped[str] = mapped_column(String(128))
    timezone: Mapped[str] = mapped_column(String(48), default="Asia/Kabul")
    currency_default: Mapped[str] = mapped_column(String(3), default="AFN")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class BranchAssignmentModel(RecordMixin, Base):
    __tablename__ = "branch_assignments"
    user_id: Mapped[str] = mapped_column(String(36), index=True)
    branch_id: Mapped[str] = mapped_column(String(36), index=True)
    role_name: Mapped[str] = mapped_column(String(32))


class SessionModel(RecordMixin, Base):
    __tablename__ = "sessions"
    user_id: Mapped[str] = mapped_column(String(36), index=True)
    device_id: Mapped[str] = mapped_column(String(128))
    refresh_hash: Mapped[str] = mapped_column(String(128), index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)


class AuditEntryModel(Base):
    """Append-only business record. Never updated; included in backups."""

    __tablename__ = "audit_entries"
    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    actor_id: Mapped[str | None] = mapped_column(String(36), default=None)
    actor_role: Mapped[str | None] = mapped_column(String(32), default=None)
    action: Mapped[str] = mapped_column(String(64))
    entity_type: Mapped[str | None] = mapped_column(String(32), default=None)
    entity_id: Mapped[str | None] = mapped_column(String(36), default=None)
    before: Mapped[dict | None] = mapped_column(JSON, default=None)
    after: Mapped[dict | None] = mapped_column(JSON, default=None)
    origin: Mapped[str] = mapped_column(String(16), default="api")
