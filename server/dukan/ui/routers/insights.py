"""AI insights + notification feed (Phase 9). Gated by report.view."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header

from dukan.application.insights import InsightService
from dukan.domain.identity import Permission, User
from dukan.shared.errors import ValidationError
from dukan.ui.deps import get_insight_service, requires
from dukan.ui.serializers import insight_dict, notification_dict

router = APIRouter(tags=["insights"])

_Viewer = Annotated[User, Depends(requires(Permission.REPORT_VIEW))]
_Insights = Annotated[InsightService, Depends(get_insight_service)]


def _active_branch(actor: User, x_branch_id: str | None) -> str:
    branch_id = x_branch_id or actor.default_branch_id
    if not branch_id:
        raise ValidationError("BRANCH_REQUIRED")
    return branch_id


@router.get("/insights")
def list_insights(
    actor: _Viewer,
    svc: _Insights,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    items = svc.insights(actor=actor, branch_id=branch_id)
    return {"insights": [insight_dict(i) for i in items]}


@router.get("/notifications")
def list_notifications(
    actor: _Viewer,
    svc: _Insights,
    unread_only: bool = False,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    items = svc.notifications(actor=actor, branch_id=branch_id, unread_only=unread_only)
    return {"notifications": [notification_dict(n) for n in items]}


@router.post("/notifications/refresh")
def refresh_notifications(
    actor: _Viewer,
    svc: _Insights,
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    branch_id = _active_branch(actor, x_branch_id)
    return {"created": svc.refresh(actor=actor, branch_id=branch_id)}


@router.patch("/notifications/{notification_id}/read")
def mark_read(
    notification_id: str,
    actor: _Viewer,
    svc: _Insights,
) -> dict:
    svc.mark_read(actor=actor, notification_id=notification_id)
    return {"status": "ok"}
