"""Sync endpoints (row-level push/pull). Authenticated; server authoritative."""

from __future__ import annotations

from typing import Annotated, Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from dukan.application.sync import OpInput, SyncService
from dukan.domain.identity import User
from dukan.ui.deps import get_current_actor, get_sync_service

router = APIRouter(prefix="/sync", tags=["sync"])

Actor = Annotated[User, Depends(get_current_actor)]
Sync = Annotated[SyncService, Depends(get_sync_service)]


class OpReq(BaseModel):
    op_id: str
    table: str
    row_id: str
    op: str = "insert"
    data: dict[str, Any] = {}
    base_version: int | None = None


class PushRequest(BaseModel):
    device_id: str = "unknown"
    ops: list[OpReq]


@router.post("/push")
def push(body: PushRequest, actor: Actor, svc: Sync) -> dict:
    results = svc.push(
        actor=actor,
        device_id=body.device_id,
        ops=[
            OpInput(
                op_id=o.op_id, table=o.table, row_id=o.row_id, op=o.op,
                data=o.data, base_version=o.base_version,
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
def pull(actor: Actor, svc: Sync, since: int = 0, limit: int = 500) -> dict:
    result = svc.pull(since=since, limit=limit)
    return {
        "watermark": result.watermark,
        "changes": [
            {"seq": c.seq, "table": c.table, "row_id": c.row_id, "op": c.op, "data": c.data}
            for c in result.changes
        ],
    }
