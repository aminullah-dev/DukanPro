"""AuditService port + DTO. Read-only access to the append-only audit trail
(the AuditEntryModel written in-transaction by every service). Gated by
audit.view. See docs/domain/read-models-sync-audit.md."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any, Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class AuditEntryView:
    id: str
    occurred_at: datetime
    actor_id: str | None
    action: str
    entity_type: str | None
    entity_id: str | None
    after: dict[str, Any] | None
    actor_name: str | None = None  # the actor's display name, for the app to show


class AuditService(Protocol):
    def query(
        self,
        *,
        actor: User,
        branch_id: str,
        action: str | None = None,
        entity_type: str | None = None,
        actor_id: str | None = None,
        limit: int = 100,
    ) -> list[AuditEntryView]: ...

    def export_csv(
        self,
        *,
        actor: User,
        branch_id: str,
        action: str | None = None,
        entity_type: str | None = None,
        actor_id: str | None = None,
        limit: int = 1000,
    ) -> str: ...
