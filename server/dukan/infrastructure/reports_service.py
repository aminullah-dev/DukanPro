"""Concrete ReportsService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.reports import DashboardView, ReportsService, TopSellerView
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.sales import line_total_minor
from dukan.infrastructure.db.models import (
    CustomerLedgerModel,
    ProductModel,
    SaleLineModel,
    SaleModel,
    StockMovementModel,
)

_POLICY = PermissionPolicy()
_LOW_STOCK_THRESHOLD = 5


class SqlReportsService(ReportsService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def dashboard(self, *, actor: User, branch_id: str) -> DashboardView:
        require_permission(_POLICY, actor, Permission.REPORT_VIEW, branch_id)
        now = datetime.now(UTC)
        start = datetime(now.year, now.month, now.day, tzinfo=UTC)

        sales = self._s.scalars(
            select(SaleModel).where(
                SaleModel.branch_id == branch_id,
                SaleModel.status == "settled",
                SaleModel.occurred_at >= start,
            )
        ).all()
        sales_today = sum(s.total_minor for s in sales)
        today_ids = {s.id for s in sales}

        profit = 0
        sellers: dict[str, tuple[str, int]] = {}
        for ln in self._s.scalars(select(SaleLineModel)):
            if ln.sale_id not in today_ids:
                continue
            cost = line_total_minor(ln.unit_cost_minor, ln.qty_minor, ln.decimal_places)
            profit += ln.line_total_minor - cost
            prev = sellers.get(ln.product_id)
            sellers[ln.product_id] = (ln.name, (prev[1] if prev else 0) + ln.qty_minor)

        ledger = self._s.scalars(
            select(CustomerLedgerModel).where(CustomerLedgerModel.deleted_at.is_(None))
        ).all()
        debt = sum(-e.amount_minor if e.type == "payment" else e.amount_minor for e in ledger)

        low = 0
        for p in self._s.scalars(select(ProductModel).where(ProductModel.deleted_at.is_(None))):
            if not p.track_stock:
                continue
            on_hand = self._s.scalar(
                select(func.coalesce(func.sum(StockMovementModel.qty_delta), 0)).where(
                    StockMovementModel.product_id == p.id,
                    StockMovementModel.branch_id == branch_id,
                    StockMovementModel.deleted_at.is_(None),
                )
            ) or 0
            if int(on_hand) <= _LOW_STOCK_THRESHOLD:
                low += 1

        top = sorted(sellers.values(), key=lambda t: -t[1])[:5]
        return DashboardView(
            sales_today_minor=sales_today,
            profit_today_minor=profit,
            outstanding_debt_minor=debt,
            low_stock_count=low,
            top_sellers=tuple(TopSellerView(name=n, qty_minor=q) for n, q in top),
        )
