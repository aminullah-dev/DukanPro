"""Sync endpoints (row-level push/pull). Authenticated; server authoritative.

Only the envelope is typed here. Every per-op rule (ids, allow-listed fields,
types, permissions, parents) is decided by the application SyncPolicy per op, so
one bad op is `rejected` on its own and never fails the batch."""

from __future__ import annotations

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Header, Query
from pydantic import BaseModel, Field

from dukan.application.sync import OpInput, SyncService
from dukan.application.sync_policy import PULL_LIMIT_MAX
from dukan.domain.identity import User
from dukan.ui.deps import get_current_actor, get_sync_service

router = APIRouter(prefix="/sync", tags=["sync"])

Actor = Annotated[User, Depends(get_current_actor)]
Sync = Annotated[SyncService, Depends(get_sync_service)]
BranchHeader = Annotated[str | None, Header()]


class OpReq(BaseModel):
    op_id: str
    table: str
    row_id: str
    op: str = "insert"
    data: dict[str, Any] = {}
    base_version: int | None = None
    actor_id: str | None = None  # outbox actorId: must equal the pusher when present
    created_at: str | None = None  # outbox createdAt: informational (audit only)


class PushRequest(BaseModel):
    device_id: str = Field(default="unknown", max_length=128)
    ops: list[OpReq]


@router.post("/push")
def push(body: PushRequest, actor: Actor, svc: Sync, x_branch_id: BranchHeader = None) -> dict:
    results = svc.push(
        actor=actor,
        device_id=body.device_id,
        # Active branch for shop-wide rows (same rule as REST); branch rows are
        # authorized in their own branch. None -> BRANCH_REQUIRED per op.
        branch_id=x_branch_id or actor.default_branch_id,
        ops=[
            OpInput(
                op_id=o.op_id, table=o.table, row_id=o.row_id, op=o.op, data=o.data,
                base_version=o.base_version, actor_id=o.actor_id, created_at=o.created_at,
            )
            for o in body.ops
        ],
    )
    return {
        "results": [
            {"op_id": r.op_id, "outcome": r.outcome, "server_seq": r.server_seq, "code": r.code}
            for r in results
        ]
    }


@router.get("/pull")
def pull(
    actor: Actor,
    svc: Sync,
    since: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=PULL_LIMIT_MAX)] = 500,
) -> dict:
    result = svc.pull(actor=actor, since=since, limit=limit)
    return {
        "watermark": result.watermark,
        "changes": [
            {"seq": c.seq, "table": c.table, "row_id": c.row_id, "op": c.op, "data": c.data}
            for c in result.changes
        ],
    }
