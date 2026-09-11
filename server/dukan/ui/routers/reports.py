"""Reports endpoints (read-only projections)."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header

from dukan.application.reports import ReportsService
from dukan.domain.identity import User
from dukan.ui.deps import active_branch, get_current_actor, get_reports_service
from dukan.ui.serializers import dashboard_view_dict

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/dashboard")
def dashboard(
    actor: Annotated[User, Depends(get_current_actor)],
    svc: Annotated[ReportsService, Depends(get_reports_service)],
    x_branch_id: Annotated[str | None, Header()] = None,
) -> dict:
    return dashboard_view_dict(
        svc.dashboard(actor=actor, branch_id=active_branch(actor, x_branch_id))
    )
