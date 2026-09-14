"""Concrete ReportsService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.reports import DashboardView, ReportsService, TopSellerView
from dukan.domain.branches import DEFAULT_BRANCH_ZONE, business_day
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.sales import line_total_minor
from dukan.infrastructure.db.models import (
    BranchModel,
    CustomerLedgerModel,
    ProductModel,
    SaleLineModel,
    SaleModel,
    StockMovementModel,
    UnitModel,
)

_POLICY = PermissionPolicy()
_LOW_STOCK_THRESHOLD = 5


def _now() -> datetime:
    """The current instant (tests move it)."""
    return datetime.now(UTC)


class SqlReportsService(ReportsService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def dashboard(self, *, actor: User, branch_id: str) -> DashboardView:
        require_permission(_POLICY, actor, Permission.REPORT_VIEW, branch_id)
        # "Today" is the branch's business day, not UTC's (docs/domain/branches.md).
        branch = self._s.get(BranchModel, branch_id)
        start, end = business_day(branch.timezone if branch else DEFAULT_BRANCH_ZONE, _now())

        sales = self._s.scalars(
            select(SaleModel).where(
                SaleModel.branch_id == branch_id,
                SaleModel.status == "settled",
                SaleModel.occurred_at >= start,
                SaleModel.occurred_at < end,
            )
        ).all()
        sales_today = sum(s.total_minor for s in sales)
        today_ids = {s.id for s in sales}

        units = {u.id: u for u in self._s.scalars(select(UnitModel))}
        products = self._s.scalars(
            select(ProductModel).where(ProductModel.deleted_at.is_(None))
        ).all()
        unit_of = {p.id: units.get(p.unit_id) for p in products}

        costs = 0
        unknown_cost = 0
        sellers: dict[str, TopSellerView] = {}
        today_lines: list[SaleLineModel] = (
            list(self._s.scalars(select(SaleLineModel).where(SaleLineModel.sale_id.in_(today_ids))))
            if today_ids else []
        )
        for ln in today_lines:
            costs += line_total_minor(ln.unit_cost_minor, ln.qty_minor, ln.decimal_places)
            if ln.unit_cost_minor == 0:
                unknown_cost += 1  # sold before any cost was known
            prev = sellers.get(ln.product_id)
            unit = unit_of.get(ln.product_id)
            sellers[ln.product_id] = TopSellerView(
                name=ln.name, qty_minor=(prev.qty_minor if prev else 0) + ln.qty_minor,
                decimal_places=ln.decimal_places, unit_name=unit.name if unit else "",
                revenue_minor=(prev.revenue_minor if prev else 0) + ln.line_total_minor,
            )

        ledger = self._s.scalars(
            select(CustomerLedgerModel).where(CustomerLedgerModel.deleted_at.is_(None))
        ).all()
        debt = sum(-e.amount_minor if e.type == "payment" else e.amount_minor for e in ledger)

        low = 0
        for p in products:
            if not p.track_stock or not p.is_active:
                continue
            on_hand = self._s.scalar(
                select(func.coalesce(func.sum(StockMovementModel.qty_delta), 0)).where(
                    StockMovementModel.product_id == p.id,
                    StockMovementModel.branch_id == branch_id,
                    StockMovementModel.deleted_at.is_(None),
                )
            ) or 0
            # The threshold is in whole units: 5 kg is 5000 grams.
            unit = units.get(p.unit_id)
            scale = 10 ** (unit.decimal_places if unit else 0)
            if int(on_hand) <= _LOW_STOCK_THRESHOLD * scale:
                low += 1

        # Ranked by revenue: 2 kg of rice and 500 soaps are not comparable counts.
        top = sorted(sellers.values(), key=lambda t: -t.revenue_minor)[:5]
        return DashboardView(
            sales_today_minor=sales_today,
            # What the sales took (after discounts), less what the goods cost.
            profit_today_minor=sales_today - costs,
            outstanding_debt_minor=debt,
            low_stock_count=low,
            top_sellers=tuple(top),
            unknown_cost_lines=unknown_cost,
        )
