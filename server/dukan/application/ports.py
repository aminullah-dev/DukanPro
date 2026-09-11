"""Application ports. Mirrors packages/dukan_core/lib/application/ports.dart.

Interfaces the application layer needs; concrete implementations live outward in
infrastructure. Imports only the domain + shared, never a framework.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from typing import Any, Protocol

from dukan.domain.inventory import StockMovement


class StockMovementRepository(Protocol):
    async def append(self, movement: StockMovement) -> None: ...
    async def for_product(self, product_id: str, branch_id: str) -> list[StockMovement]: ...


class OutboxStatus(StrEnum):
    PENDING = "pending"
    SENT = "sent"
    ACKED = "acked"
    CONFLICT = "conflict"
    REJECTED = "rejected"


@dataclass(frozen=True, slots=True)
class OutboxOp:
    """One entry in the offline operation queue. See docs/sync-protocol.md."""

    op_id: str  # UUIDv7 — also the idempotency key
    aggregate_type: str
    aggregate_id: str
    op_type: str
    payload: dict[str, Any]
    local_seq: int
    device_id: str
    actor_id: str
    created_at: datetime
    base_version: int | None = None
    status: OutboxStatus = OutboxStatus.PENDING


class SyncOutbox(Protocol):
    async def enqueue(self, op: OutboxOp) -> None: ...
    async def pending(self) -> list[OutboxOp]: ...
    async def mark_acked(self, op_id: str) -> None: ...
