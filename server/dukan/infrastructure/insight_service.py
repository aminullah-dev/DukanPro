"""Concrete InsightService bound to a SQLAlchemy session. Computes AI-style
business insights deterministically from the ledgers (reorder suggestions,
dead stock, debtor risk, daily digest) and materialises them into a persisted,
idempotent notification feed. Gated by report.view. See docs/domain/
read-models-sync-audit.md."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.insights import Insight, InsightService, Notification
from dukan.domain.branches import DEFAULT_BRANCH_ZONE, branch_wall_clock, business_day
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.insights import (
    InsightSeverity,
    debt_severity,
    is_dead_stock,
    reorder_suggestion,
)
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BranchModel,
    CustomerLedgerModel,
    CustomerModel,
    NotificationModel,
    ProductModel,
    SaleLineModel,
    SaleModel,
    StockMovementModel,
)
from dukan.shared.errors import NotFoundError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()
_VELOCITY_WINDOW_DAYS = 30
_DEAD_STOCK_DAYS = 30


def _now() -> datetime:
    """The current instant (tests move it)."""
    return datetime.now(UTC)


class SqlInsightService(InsightService):
    def __init__(self, session: Session) -> None:
        self._s = session

    # ---- compute ---------------------------------------------------------
    def insights(self, *, actor: User, branch_id: str) -> list[Insight]:
        require_permission(_POLICY, actor, Permission.REPORT_VIEW, branch_id)
        now = _now()
        out: list[Insight] = []
        out.extend(self._stock_insights(branch_id, now))
        out.extend(self._debt_insights())
        out.append(self._digest(branch_id, now))
        return out

    def _on_hand(self, product_id: str, branch_id: str) -> int:
        return int(
            self._s.scalar(
                select(func.coalesce(func.sum(StockMovementModel.qty_delta), 0)).where(
                    StockMovementModel.product_id == product_id,
                    StockMovementModel.branch_id == branch_id,
                    StockMovementModel.deleted_at.is_(None),
                )
            )
            or 0
        )

    def _stock_insights(self, branch_id: str, now: datetime) -> list[Insight]:
        cutoff = now - timedelta(days=_VELOCITY_WINDOW_DAYS)
        sales = self._s.scalars(
            select(SaleModel).where(
                SaleModel.branch_id == branch_id, SaleModel.status == "settled"
            )
        ).all()
        sale_time = {s.id: s.occurred_at for s in sales}
        window_qty: dict[str, int] = {}
        last_sold: dict[str, datetime] = {}
        for ln in self._s.scalars(select(SaleLineModel)):
            when = sale_time.get(ln.sale_id)
            if when is None:
                continue
            when = when if when.tzinfo else when.replace(tzinfo=UTC)
            if when >= cutoff:
                window_qty[ln.product_id] = window_qty.get(ln.product_id, 0) + ln.qty_minor
            if ln.product_id not in last_sold or when > last_sold[ln.product_id]:
                last_sold[ln.product_id] = when

        out: list[Insight] = []
        products = self._s.scalars(
            select(ProductModel).where(
                ProductModel.deleted_at.is_(None), ProductModel.track_stock.is_(True)
            )
        ).all()
        for p in products:
            on_hand = self._on_hand(p.id, branch_id)
            velocity = window_qty.get(p.id, 0) // _VELOCITY_WINDOW_DAYS
            qty = reorder_suggestion(on_hand_minor=on_hand, avg_daily_sales_minor=velocity)
            if qty > 0:
                out.append(
                    Insight(
                        code="insight.reorder",
                        severity="critical" if on_hand <= 0 else "warning",
                        data={"product": p.name, "suggested_minor": qty, "on_hand_minor": on_hand},
                        entity_type="product",
                        entity_id=p.id,
                    )
                )
            last = last_sold.get(p.id)
            days_since = (now - last).days if last is not None else 10_000
            if is_dead_stock(
                on_hand_minor=on_hand,
                days_since_last_sale=days_since,
                dead_after_days=_DEAD_STOCK_DAYS,
            ):
                out.append(
                    Insight(
                        code="insight.dead_stock",
                        severity="info",
                        data={"product": p.name, "days": days_since, "on_hand_minor": on_hand},
                        entity_type="product",
                        entity_id=p.id,
                    )
                )
        return out

    def _debt_insights(self) -> list[Insight]:
        entries = self._s.scalars(
            select(CustomerLedgerModel).where(CustomerLedgerModel.deleted_at.is_(None))
        ).all()
        balance: dict[str, int] = {}
        for e in entries:
            delta = -e.amount_minor if e.type == "payment" else e.amount_minor
            balance[e.customer_id] = balance.get(e.customer_id, 0) + delta

        out: list[Insight] = []
        for cid, bal in balance.items():
            if bal <= 0:
                continue
            c = self._s.get(CustomerModel, cid)
            if c is None:
                continue
            limit = c.credit_limit_minor or 0
            severity = debt_severity(balance_minor=bal, credit_limit_minor=limit)
            if severity is InsightSeverity.INFO:
                continue
            out.append(
                Insight(
                    code="insight.debt_risk",
                    severity=str(severity),
                    data={"customer": c.name, "balance_minor": bal, "limit_minor": limit},
                    entity_type="customer",
                    entity_id=cid,
                )
            )
        return out

    def _zone(self, branch_id: str) -> str:
        branch = self._s.get(BranchModel, branch_id)
        return branch.timezone if branch else DEFAULT_BRANCH_ZONE

    def _digest(self, branch_id: str, now: datetime) -> Insight:
        start, end = business_day(self._zone(branch_id), now)  # the branch's today
        sales = self._s.scalars(
            select(SaleModel).where(
                SaleModel.branch_id == branch_id,
                SaleModel.status == "settled",
                SaleModel.occurred_at >= start,
                SaleModel.occurred_at < end,
            )
        ).all()
        return Insight(
            code="insight.digest",
            severity="info",
            data={"sales_minor": sum(s.total_minor for s in sales), "count": len(sales)},
        )

    # ---- notification feed ----------------------------------------------
    def _to_notification(self, m: NotificationModel) -> Notification:
        return Notification(
            id=m.id,
            code=m.code,
            severity=m.severity,
            data=m.data,
            read=m.read_at is not None,
            created_at=m.created_at,
        )

    def notifications(
        self, *, actor: User, branch_id: str, unread_only: bool = False
    ) -> list[Notification]:
        require_permission(_POLICY, actor, Permission.REPORT_VIEW, branch_id)
        q = select(NotificationModel).where(NotificationModel.branch_id == branch_id)
        if unread_only:
            q = q.where(NotificationModel.read_at.is_(None))
        q = q.order_by(NotificationModel.created_at.desc())
        return [self._to_notification(m) for m in self._s.scalars(q)]

    def refresh(self, *, actor: User, branch_id: str) -> int:
        require_permission(_POLICY, actor, Permission.REPORT_VIEW, branch_id)
        # One alert per branch-local day.
        day = branch_wall_clock(self._zone(branch_id), _now()).strftime("%Y-%m-%d")
        created = 0
        for ins in self.insights(actor=actor, branch_id=branch_id):
            if ins.code == "insight.digest":
                continue  # the digest is a live view, not a persisted alert
            dedupe = f"{branch_id}:{ins.code}:{ins.entity_id or ''}:{day}"
            exists = self._s.scalar(
                select(NotificationModel).where(NotificationModel.dedupe_key == dedupe)
            )
            if exists is not None:
                continue
            self._s.add(
                NotificationModel(
                    id=new_id(),
                    branch_id=branch_id,
                    code=ins.code,
                    severity=ins.severity,
                    data=ins.data,
                    dedupe_key=dedupe,
                )
            )
            created += 1
        if created:
            self._s.add(
                AuditEntryModel(
                    id=new_id(),
                    action="notifications.refreshed",
                    actor_id=actor.id,
                    entity_type="branch",
                    entity_id=branch_id,
                    after={"created": created},
                    origin="api",
                )
            )
        self._s.commit()
        return created

    def mark_read(self, *, actor: User, notification_id: str) -> None:
        m = self._s.get(NotificationModel, notification_id)
        if m is None:
            raise NotFoundError("NOTIFICATION_NOT_FOUND", notification_id=notification_id)
        require_permission(_POLICY, actor, Permission.REPORT_VIEW, m.branch_id)
        if m.read_at is None:
            m.read_at = datetime.now(UTC)
            self._s.commit()
