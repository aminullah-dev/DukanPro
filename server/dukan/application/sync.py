"""SyncService port + DTOs. Row-level, idempotent sync (see docs/sync-protocol.md)."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class OpInput:
    op_id: str
    table: str
    row_id: str
    op: str  # insert | update
    data: dict[str, Any]
    base_version: int | None = None


@dataclass(frozen=True, slots=True)
class OpResult:
    op_id: str
    outcome: str  # applied | conflict | rejected
    server_seq: int | None = None
    code: str | None = None


@dataclass(frozen=True, slots=True)
class ChangeItem:
    seq: int
    table: str
    row_id: str
    op: str
    data: dict[str, Any]


@dataclass(frozen=True, slots=True)
class PullResult:
    changes: list[ChangeItem]
    watermark: int


class SyncService(Protocol):
    def push(self, *, actor: User, device_id: str, ops: list[OpInput]) -> list[OpResult]: ...

    def pull(self, *, since: int, limit: int) -> PullResult: ...
