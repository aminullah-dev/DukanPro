"""Concrete AuditService bound to a SQLAlchemy session. Read-only queries and
CSV export over the append-only audit trail. Gated by audit.view."""

from __future__ import annotations

import csv
import io

from sqlalchemy import Select, select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.audit import AuditEntryView, AuditService
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.infrastructure.db.models import AuditEntryModel
from dukan.infrastructure.scope import require_everywhere

_POLICY = PermissionPolicy()


class SqlAuditService(AuditService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def _filtered(
        self,
        action: str | None,
        entity_type: str | None,
        actor_id: str | None,
        limit: int,
    ) -> Select[tuple[AuditEntryModel]]:
        q = select(AuditEntryModel)
        if action:
            q = q.where(AuditEntryModel.action == action)
        if entity_type:
            q = q.where(AuditEntryModel.entity_type == entity_type)
        if actor_id:
            q = q.where(AuditEntryModel.actor_id == actor_id)
        return q.order_by(AuditEntryModel.occurred_at.desc()).limit(max(1, min(limit, 5000)))

    def _require_reader(self, actor: User, branch_id: str) -> None:
        # Entries carry no branch, so the trail is shop-wide: only an actor with
        # audit.view in every branch (an owner of the whole shop) reads it.
        require_permission(_POLICY, actor, Permission.AUDIT_VIEW, branch_id)
        require_everywhere(self._s, actor, Permission.AUDIT_VIEW)

    def _view(self, m: AuditEntryModel) -> AuditEntryView:
        return AuditEntryView(
            id=m.id,
            occurred_at=m.occurred_at,
            actor_id=m.actor_id,
            action=m.action,
            entity_type=m.entity_type,
            entity_id=m.entity_id,
            after=m.after,
        )

    def query(
        self,
        *,
        actor: User,
        branch_id: str,
        action: str | None = None,
        entity_type: str | None = None,
        actor_id: str | None = None,
        limit: int = 100,
    ) -> list[AuditEntryView]:
        self._require_reader(actor, branch_id)
        rows = self._s.scalars(self._filtered(action, entity_type, actor_id, limit)).all()
        return [self._view(m) for m in rows]

    def export_csv(
        self,
        *,
        actor: User,
        branch_id: str,
        action: str | None = None,
        entity_type: str | None = None,
        actor_id: str | None = None,
        limit: int = 1000,
    ) -> str:
        self._require_reader(actor, branch_id)
        rows = self._s.scalars(self._filtered(action, entity_type, actor_id, limit)).all()
        buf = io.StringIO()
        writer = csv.writer(buf)
        writer.writerow(["occurred_at", "actor_id", "action", "entity_type", "entity_id"])
        for m in rows:
            writer.writerow([
                m.occurred_at.isoformat(),
                m.actor_id or "",
                m.action,
                m.entity_type or "",
                m.entity_id or "",
            ])
        return buf.getvalue()
