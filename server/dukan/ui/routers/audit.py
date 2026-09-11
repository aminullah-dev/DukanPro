"""Audit trail query + export (Phase 10). Gated by audit.view (owner)."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from fastapi.responses import PlainTextResponse

from dukan.application.audit import AuditService
from dukan.domain.identity import Permission, User
from dukan.shared.errors import ValidationError
from dukan.ui.deps import get_audit_service, requires
from dukan.ui.serializers import audit_entry_dict

router = APIRouter(prefix="/audit", tags=["audit"])

_Auditor = Annotated[User, Depends(requires(Permission.AUDIT_VIEW))]
_Audit = Annotated[AuditService, Depends(get_audit_service)]


def _active_branch(actor: User, x_branch_id: str | None) -> str:
    branch_id = x_branch_id or actor.default_branch_id
    if not branch_id:
        raise ValidationError("BRANCH_REQUIRED")
    return branch_id


@router.get("")
def list_audit(
    actor: _Auditor,
    svc: _Audit,
    action: str | None = None,
    entity_type: str | None = None,
    actor_id: str | None = None,
    limit: int = 100,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    entries = svc.query(
        actor=actor, branch_id=branch_id,
        action=action, entity_type=entity_type, actor_id=actor_id, limit=limit,
    )
    return {"entries": [audit_entry_dict(e) for e in entries]}


@router.get("/export")
def export_audit(
    actor: _Auditor,
    svc: _Audit,
    action: str | None = None,
    entity_type: str | None = None,
    actor_id: str | None = None,
    limit: int = 1000,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> PlainTextResponse:
    branch_id = _active_branch(actor, x_branch_id)
    csv_text = svc.export_csv(
        actor=actor, branch_id=branch_id,
        action=action, entity_type=entity_type, actor_id=actor_id, limit=limit,
    )
    return PlainTextResponse(
        content=csv_text,
        media_type="text/csv",
        headers={"content-disposition": "attachment; filename=audit.csv"},
    )
