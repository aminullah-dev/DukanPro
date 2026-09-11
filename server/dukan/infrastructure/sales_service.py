"""Concrete SalesService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.sales import (
    PaymentInput,
    SaleLineInput,
    SaleLineView,
    SalesService,
    SaleView,
    ShiftView,
)
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.sales import SaleLine, assert_settleable, compute_totals
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    PaymentModel,
    ProductModel,
    SaleLineModel,
    SaleModel,
    ShiftModel,
    StockMovementModel,
    UnitModel,
)
from dukan.shared.errors import ConflictError, NotFoundError, ValidationError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()


class SqlSalesService(SalesService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def _audit(self, action: str, actor_id: str, entity_id: str, after: dict | None = None) -> None:
        self._s.add(
            AuditEntryModel(
                id=new_id(), action=action, actor_id=actor_id, entity_type="sale",
                entity_id=entity_id, after=after, origin="api",
            )
        )

    def _next_number(self) -> str:
        year = datetime.now(UTC).year
        count = self._s.scalar(select(func.count()).select_from(SaleModel)) or 0
        return f"INV-{year}-{count + 1:05d}"

    def _decimal_places(self, unit_id: str) -> int:
        u = self._s.get(UnitModel, unit_id)
        return u.decimal_places if u else 0

    def _view(self, sale: SaleModel) -> SaleView:
        lines = self._s.scalars(
            select(SaleLineModel).where(SaleLineModel.sale_id == sale.id)
        ).all()
        return SaleView(
            id=sale.id, number=sale.number, branch_id=sale.branch_id, status=sale.status,
            currency=sale.currency, subtotal_minor=sale.subtotal_minor,
            discount_minor=sale.discount_minor, total_minor=sale.total_minor,
            paid_minor=sale.paid_minor, change_minor=sale.change_minor,
            customer_id=sale.customer_id,
            lines=tuple(
                SaleLineView(
                    product_id=l.product_id, name=l.name, qty_minor=l.qty_minor,
                    unit_price_minor=l.unit_price_minor, line_total_minor=l.line_total_minor,
                )
                for l in lines
            ),
        )

    def settle_sale(
        self,
        *,
        actor: User,
        branch_id: str,
        lines: list[SaleLineInput],
        discount_minor: int,
        payments: list[PaymentInput],
        shift_id: str | None,
        customer_id: str | None,
    ) -> SaleView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        if not lines:
            raise ValidationError("SALE_EMPTY")

        currency = "AFN"
        domain_lines: list[SaleLine] = []
        products: dict[str, ProductModel] = {}
        for item in lines:
            product = self._s.scalar(
                select(ProductModel).where(
                    ProductModel.id == item.product_id, ProductModel.deleted_at.is_(None)
                )
            )
            if product is None:
                raise NotFoundError("PRODUCT_NOT_FOUND", product_id=item.product_id)
            products[item.product_id] = product
            currency = product.sell_currency
            domain_lines.append(
                SaleLine(
                    product_id=product.id, name=product.name, qty_minor=item.qty_minor,
                    decimal_places=self._decimal_places(product.unit_id),
                    unit_price_minor=product.sell_price_minor,
                    unit_cost_minor=product.cost_minor or 0, currency=product.sell_currency,
                )
            )

        totals = compute_totals(domain_lines, discount_minor)
        paid = sum(p.amount_minor for p in payments)
        assert_settleable(
            lines=domain_lines, total_minor=totals.total_minor, paid_minor=paid,
            currency=currency, allow_credit=customer_id is not None,
        )
        change = sum(
            max(0, (p.tendered_minor or p.amount_minor) - p.amount_minor) for p in payments
        )

        sale = SaleModel(
            id=new_id(), number=self._next_number(), branch_id=branch_id, shift_id=shift_id,
            customer_id=customer_id, status="settled", currency=currency,
            discount_minor=discount_minor, subtotal_minor=totals.subtotal_minor,
            tax_minor=totals.tax_minor, total_minor=totals.total_minor, paid_minor=paid,
            change_minor=change, created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(sale)
        for dl in domain_lines:
            self._s.add(
                SaleLineModel(
                    id=new_id(), sale_id=sale.id, product_id=dl.product_id, name=dl.name,
                    qty_minor=dl.qty_minor, decimal_places=dl.decimal_places,
                    unit_price_minor=dl.unit_price_minor, unit_cost_minor=dl.unit_cost_minor,
                    line_total_minor=dl.line_total, currency=dl.currency, created_by=actor.id,
                )
            )
            if products[dl.product_id].track_stock:
                self._s.add(
                    StockMovementModel(
                        id=new_id(), product_id=dl.product_id, branch_id=branch_id,
                        qty_delta=-dl.qty_minor, reason="sale", ref_type="sale", ref_id=sale.id,
                        created_by=actor.id,
                    )
                )
        for p in payments:
            self._s.add(
                PaymentModel(
                    id=new_id(), sale_id=sale.id, method=p.method, amount_minor=p.amount_minor,
                    currency=currency, tendered_minor=p.tendered_minor, created_by=actor.id,
                )
            )
        self._audit(
            "sale.settled", actor.id, sale.id,
            {"number": sale.number, "total": totals.total_minor},
        )
        self._s.commit()
        return self._view(sale)

    def void_sale(self, *, actor: User, branch_id: str, sale_id: str) -> SaleView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        sale = self._s.get(SaleModel, sale_id)
        if sale is None:
            raise NotFoundError("SALE_NOT_FOUND", sale_id=sale_id)
        if sale.status != "settled":
            raise ConflictError("SALE_NOT_VOIDABLE", status=sale.status)
        sale.status = "voided"
        lines = self._s.scalars(select(SaleLineModel).where(SaleLineModel.sale_id == sale.id)).all()
        for l in lines:
            self._s.add(
                StockMovementModel(
                    id=new_id(), product_id=l.product_id, branch_id=sale.branch_id,
                    qty_delta=l.qty_minor, reason="returned", ref_type="void", ref_id=sale.id,
                    created_by=actor.id,
                )
            )
        self._audit("sale.voided", actor.id, sale.id, {"number": sale.number})
        self._s.commit()
        return self._view(sale)

    def get_sale(self, *, sale_id: str) -> SaleView:
        sale = self._s.get(SaleModel, sale_id)
        if sale is None:
            raise NotFoundError("SALE_NOT_FOUND", sale_id=sale_id)
        return self._view(sale)

    def open_shift(self, *, actor: User, branch_id: str, opening_float_minor: int) -> ShiftView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        shift = ShiftModel(
            id=new_id(), branch_id=branch_id, user_id=actor.id,
            opening_float_minor=opening_float_minor, status="open", created_by=actor.id,
        )
        self._s.add(shift)
        self._s.commit()
        return ShiftView(
            id=shift.id, status=shift.status, opening_float_minor=shift.opening_float_minor,
            expected_cash_minor=None, counted_cash_minor=None, variance_minor=None,
        )

    def close_shift(self, *, actor: User, shift_id: str, counted_cash_minor: int) -> ShiftView:
        shift = self._s.get(ShiftModel, shift_id)
        if shift is None:
            raise NotFoundError("SHIFT_NOT_FOUND", shift_id=shift_id)
        require_permission(_POLICY, actor, Permission.SALE_CREATE, shift.branch_id)
        cash_sales = self._s.scalar(
            select(func.coalesce(func.sum(PaymentModel.amount_minor), 0))
            .select_from(PaymentModel)
            .join(SaleModel, SaleModel.id == PaymentModel.sale_id)
            .where(
                SaleModel.shift_id == shift.id, SaleModel.status == "settled",
                PaymentModel.method == "cash",
            )
        ) or 0
        expected = shift.opening_float_minor + int(cash_sales)
        shift.expected_cash_minor = expected
        shift.counted_cash_minor = counted_cash_minor
        shift.variance_minor = counted_cash_minor - expected
        shift.closed_at = datetime.now(UTC)
        shift.status = "closed"
        self._audit("shift.closed", actor.id, shift.id, {"variance": shift.variance_minor})
        self._s.commit()
        return ShiftView(
            id=shift.id, status=shift.status, opening_float_minor=shift.opening_float_minor,
            expected_cash_minor=expected, counted_cash_minor=counted_cash_minor,
            variance_minor=shift.variance_minor,
        )
