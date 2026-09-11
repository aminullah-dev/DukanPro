"""InsightService port + DTOs, and the NarrativeGenerator seam. Insights are
returned as localizable codes + data params (like AppError) so the client
renders them per-locale. The NarrativeGenerator is where a real LLM (Claude)
can later summarize/rank insights; the shipped default is deterministic.
See docs/domain/read-models-sync-audit.md.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class Insight:
    code: str  # e.g. "insight.reorder", "insight.dead_stock", "insight.debt_risk"
    severity: str  # info | warning | critical
    data: dict[str, Any] = field(default_factory=dict)
    entity_type: str | None = None
    entity_id: str | None = None


@dataclass(frozen=True, slots=True)
class Notification:
    id: str
    code: str
    severity: str
    data: dict[str, Any]
    read: bool
    created_at: datetime


class NarrativeGenerator(Protocol):
    """Turns a list of insights into a short human summary. The default is a
    deterministic template; an LLM-backed implementation plugs in here."""

    def summarize(self, insights: list[Insight]) -> str: ...


class TemplateNarrativeGenerator(NarrativeGenerator):
    """Deterministic, offline summary — counts insights by severity."""

    def summarize(self, insights: list[Insight]) -> str:
        if not insights:
            return "All clear — nothing needs attention."
        critical = sum(1 for i in insights if i.severity == "critical")
        warning = sum(1 for i in insights if i.severity == "warning")
        parts = []
        if critical:
            parts.append(f"{critical} critical")
        if warning:
            parts.append(f"{warning} to watch")
        rest = len(insights) - critical - warning
        if rest:
            parts.append(f"{rest} for info")
        return f"{len(insights)} insights: " + ", ".join(parts) + "."


class InsightService(Protocol):
    def insights(self, *, actor: User, branch_id: str) -> list[Insight]: ...

    def notifications(
        self, *, actor: User, branch_id: str, unread_only: bool = False
    ) -> list[Notification]: ...

    def refresh(self, *, actor: User, branch_id: str) -> int: ...

    def mark_read(self, *, actor: User, notification_id: str) -> None: ...
