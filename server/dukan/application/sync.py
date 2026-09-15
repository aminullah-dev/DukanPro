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
    # Device-recorded actor + time from the client outbox. A claim, never trusted
    # for attribution: an op is applied only when actor_id equals the pusher.
    actor_id: str | None = None
    created_at: str | None = None


@dataclass(frozen=True, slots=True)
class OpResult:
    op_id: str
    outcome: str  # applied | conflict | rejected
    server_seq: int | None = None  # the change_log seq of an applied op
    code: str | None = None
    version: int | None = None  # the master row's new version, when just applied
    current: dict[str, Any] | None = None  # the server's row, for a conflict


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
    max_seq: int = 0  # the feed's newest seq: a device ahead of it was restored from
    watermark_token: str | None = None  # names the change at the watermark (change_token)
    scope: str = ""  # the puller's read scope (scope_fingerprint)
    reset: bool = False  # the change at since_token is gone: the device reads the feed again


class SyncService(Protocol):
    def push(
        self, *, actor: User, device_id: str, branch_id: str | None, ops: list[OpInput]
    ) -> list[OpResult]: ...

    def pull(
        self, *, actor: User, since: int, limit: int, since_token: str | None = None
    ) -> PullResult: ...
