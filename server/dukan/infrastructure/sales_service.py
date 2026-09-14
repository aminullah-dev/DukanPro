"""Concrete SalesService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_any_permission, require_permission
from dukan.application.sales import (
    PaymentInput,
    SaleLineInput,
    SaleLineView,
    SalesService,
    SaleView,
    ShiftView,
)
from dukan.domain.customers import (
    CustomerLedgerEntry,
    LedgerEntryType,
    assert_customer_can_buy_on_credit,
    assert_within_credit_limit,
    ledger_balance,
)
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.inventory import StockMovement, sell_from_stock
from dukan.domain.sales import (
    SaleLine,
    assert_discount_valid,
    assert_payment_valid,
    assert_sale_lines_valid,
    assert_sale_not_overpaid,
    assert_settleable,
    assert_shift_cash_valid,
    compute_totals,
)
from dukan.infrastructure.change_feed import record_change
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    CustomerLedgerModel,
    CustomerModel,
    PaymentModel,
    ProductModel,
    SaleLineModel,
    SaleModel,
    ShiftModel,
    StockMovementModel,
    UnitModel,
)
from dukan.infrastructure.scope import require_active_branch
from dukan.infrastructure.shift_cash import expected_cash, require_open_shift
from dukan.shared.errors import ConflictError, NotFoundError, ValidationError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()


class SqlSalesService(SalesService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def _audit(
        self, action: str, actor_id: str, entity_id: str, after: dict | None = None,
        before: dict | None = None,
    ) -> None:
        self._s.add(
            AuditEntryModel(
                id=new_id(), action=action, actor_id=actor_id, entity_type="sale",
                entity_id=entity_id, before=before, after=after, origin="api",
            )
        )

    def _next_number(self) -> str:
        year = datetime.now(UTC).year
        count = self._s.scalar(select(func.count()).select_from(SaleModel)) or 0
        return f"INV-{year}-{count + 1:05d}"

    def _decimal_places(self, unit_id: str) -> int:
        # Never 0 by default: 1.5 kg would be priced as 1500 whole kg.
        u = self._s.get(UnitModel, unit_id)
        if u is None or u.deleted_at is not None:
            raise ValidationError("UNIT_NOT_FOUND", unit_id=unit_id)
        return u.decimal_places

    def _on_hand(self, product_id: str, branch_id: str) -> int:
        return int(
            self._s.scalar(
                select(func.coalesce(func.sum(StockMovementModel.qty_delta), 0)).where(
                    StockMovementModel.product_id == product_id,
                    StockMovementModel.branch_id == branch_id,
                    StockMovementModel.deleted_at.is_(None),
                )
            ) or 0
        )

    def _customer_balance(self, customer_id: str) -> int:
        rows = self._s.scalars(
            select(CustomerLedgerModel).where(
                CustomerLedgerModel.customer_id == customer_id,
                CustomerLedgerModel.deleted_at.is_(None),
            )
        ).all()
        return ledger_balance(
            CustomerLedgerEntry(
                id=r.id, customer_id=r.customer_id, type=LedgerEntryType(r.type),
                amount_minor=r.amount_minor, currency=r.currency, occurred_at=r.occurred_at,
            )
            for r in rows
        )

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
        require_active_branch(self._s, branch_id)
        if not lines:
            raise ValidationError("SALE_EMPTY")
        if shift_id is not None:
            require_open_shift(self._s, shift_id=shift_id, user_id=actor.id, branch_id=branch_id)

        currency = "AFN"
        domain_lines: list[SaleLine] = []
        products: dict[str, ProductModel] = {}
        for item in lines:
            product = self._s.scalar(
                select(ProductModel)
                .where(ProductModel.id == item.product_id, ProductModel.deleted_at.is_(None))
                .with_for_update()  # two online sales of one product take turns (stock)
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

        assert_sale_lines_valid(domain_lines, currency=currency)
        totals = compute_totals(domain_lines, discount_minor)
        assert_discount_valid(discount_minor=discount_minor, subtotal_minor=totals.subtotal_minor)
        if discount_minor > 0:
            # A discount is money off the sale: a manager's permission, and audited.
            require_permission(_POLICY, actor, Permission.SALE_DISCOUNT, branch_id)
        paid = sum(p.amount_minor for p in payments)
        assert_settleable(
            lines=domain_lines, total_minor=totals.total_minor, paid_minor=paid,
            currency=currency, allow_credit=customer_id is not None,
        )
        for p in payments:
            assert_payment_valid(
                method=p.method, amount_minor=p.amount_minor, tendered_minor=p.tendered_minor
            )
        assert_sale_not_overpaid(paid_minor=paid, total_minor=totals.total_minor)
        # Change is cash handed back over a cash payment (tendered >= amount).
        change = sum((p.tendered_minor or p.amount_minor) - p.amount_minor for p in payments)
        # Online, a sale never takes stock the branch does not have (inventory.md
        # invariant 4); a till that sold offline finds out on sync instead.
        now = datetime.now(UTC)
        left: dict[str, int] = {}
        moves: list[StockMovement] = []
        for dl in domain_lines:
            if not products[dl.product_id].track_stock:
                continue
            available = left.get(dl.product_id)
            if available is None:
                available = self._on_hand(dl.product_id, branch_id)
            moves.append(sell_from_stock(
                id=new_id(), product_id=dl.product_id, branch_id=branch_id, qty=dl.qty_minor,
                available=available, at=now,
            ))
            left[dl.product_id] = available - dl.qty_minor
        # Credit: the customer's own row decides (active, their currency, the limit),
        # locked so two sales cannot both pass the limit.
        credit = 0
        if customer_id is not None and paid < totals.total_minor:
            credit = totals.total_minor - paid
            customer = self._s.scalar(
                select(CustomerModel)
                .where(CustomerModel.id == customer_id, CustomerModel.deleted_at.is_(None))
                .with_for_update()
            )
            if customer is None:
                raise NotFoundError("CUSTOMER_NOT_FOUND", customer_id=customer_id)
            assert_customer_can_buy_on_credit(
                is_active=customer.is_active, customer_currency=customer.currency,
                sale_currency=currency,
            )
            assert_within_credit_limit(
                balance_minor=self._customer_balance(customer_id), charge_minor=credit,
                credit_limit_minor=customer.credit_limit_minor,
            )

        sale = SaleModel(
            id=new_id(), number=self._next_number(), branch_id=branch_id, shift_id=shift_id,
            customer_id=customer_id, status="settled", currency=currency,
            discount_minor=discount_minor, subtotal_minor=totals.subtotal_minor,
            tax_minor=totals.tax_minor, total_minor=totals.total_minor, paid_minor=paid,
            change_minor=change, created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(sale)
        record_change(self._s, "sales", sale, op="insert", branch_id=branch_id)
        for dl in domain_lines:
            line_row = SaleLineModel(
                id=new_id(), sale_id=sale.id, product_id=dl.product_id, name=dl.name,
                qty_minor=dl.qty_minor, decimal_places=dl.decimal_places,
                unit_price_minor=dl.unit_price_minor, unit_cost_minor=dl.unit_cost_minor,
                line_total_minor=dl.line_total, currency=dl.currency, created_by=actor.id,
            )
            self._s.add(line_row)
            record_change(self._s, "sale_lines", line_row, op="insert", branch_id=branch_id)
        for move in moves:
            sold = StockMovementModel(
                id=move.id, product_id=move.product_id, branch_id=branch_id,
                qty_delta=move.qty_delta, reason="sale", ref_type="sale", ref_id=sale.id,
                created_by=actor.id,
            )
            self._s.add(sold)
            record_change(self._s, "stock_movements", sold, op="insert", branch_id=branch_id)
        for p in payments:
            payment = PaymentModel(
                id=new_id(), sale_id=sale.id, method=p.method, amount_minor=p.amount_minor,
                currency=currency, tendered_minor=p.tendered_minor,
                change_minor=(
                    None if p.tendered_minor is None else p.tendered_minor - p.amount_minor
                ),
                created_by=actor.id,
            )
            self._s.add(payment)
            record_change(self._s, "payments", payment, op="insert", branch_id=branch_id)
        # Credit sale: the unpaid remainder goes to the customer ledger (Phase 4).
        if customer_id is not None and credit > 0:
            charge = CustomerLedgerModel(
                id=new_id(), customer_id=customer_id, type="charge", amount_minor=credit,
                currency=currency, ref_type="sale", ref_id=sale.id, created_by=actor.id,
            )
            self._s.add(charge)
            record_change(self._s, "customer_ledger", charge, op="insert", branch_id=None)
            self._audit(
                "debt.charge_posted", actor.id, sale.id,
                {"customer_id": customer_id, "amount": credit},
            )
        if discount_minor > 0:
            self._audit(
                "discount.applied", actor.id, sale.id,
                {"amount": discount_minor, "subtotal": totals.subtotal_minor},
            )
        self._audit(
            "sale.settled", actor.id, sale.id,
            {"number": sale.number, "total": totals.total_minor},
        )
        self._s.commit()
        return self._view(sale)

    def void_sale(self, *, actor: User, sale_id: str, reason: str) -> SaleView:
        # Locked: two voids of one sale, or a void racing its shift's close, take
        # turns instead of both passing the checks below.
        sale = self._s.scalar(select(SaleModel).where(SaleModel.id == sale_id).with_for_update())
        if sale is None:
            raise NotFoundError("SALE_NOT_FOUND", sale_id=sale_id)
        # A void hands money back and restores stock: a manager's call, made in the
        # sale's own branch and recorded with its reason.
        require_permission(_POLICY, actor, Permission.SALE_VOID, sale.branch_id)
        require_active_branch(self._s, sale.branch_id)
        if not reason.strip():
            raise ValidationError("SALE_VOID_REASON_REQUIRED")
        if sale.status != "settled":
            raise ConflictError("SALE_NOT_VOIDABLE", status=sale.status)
        shift = (
            self._s.scalar(
                select(ShiftModel).where(ShiftModel.id == sale.shift_id).with_for_update()
            )
            if sale.shift_id else None
        )
        if shift is not None and shift.status != "open":
            # Its cash was counted when the shift closed; the void would vanish from it.
            raise ConflictError("SALE_SHIFT_CLOSED", shift_id=shift.id)
        sale.status = "voided"
        lines = self._s.scalars(select(SaleLineModel).where(SaleLineModel.sale_id == sale.id)).all()
        record_change(self._s, "sales", sale, op="update", branch_id=sale.branch_id)
        for l in lines:
            back = StockMovementModel(
                id=new_id(), product_id=l.product_id, branch_id=sale.branch_id,
                qty_delta=l.qty_minor, reason="returned", ref_type="void", ref_id=sale.id,
                created_by=actor.id,
            )
            self._s.add(back)
            record_change(self._s, "stock_movements", back, op="insert", branch_id=sale.branch_id)
        # The debt the sale put on a customer goes too: a compensating entry per
        # charge, since the ledger is append-only.
        reversed_debt = 0
        charges = self._s.scalars(
            select(CustomerLedgerModel).where(
                CustomerLedgerModel.type == "charge", CustomerLedgerModel.ref_type == "sale",
                CustomerLedgerModel.ref_id == sale.id, CustomerLedgerModel.deleted_at.is_(None),
            )
        ).all()
        for c in charges:
            undo = CustomerLedgerModel(
                id=new_id(), customer_id=c.customer_id, type="adjustment",
                amount_minor=-c.amount_minor, currency=c.currency, ref_type="void",
                ref_id=sale.id, created_by=actor.id,
            )
            self._s.add(undo)
            record_change(self._s, "customer_ledger", undo, op="insert", branch_id=None)
            reversed_debt += c.amount_minor
        self._audit(
            "sale.voided", actor.id, sale.id,
            {
                "number": sale.number, "status": "voided", "reason": reason.strip(),
                **({"debt_reversed": reversed_debt} if reversed_debt else {}),
            },
            before={"status": "settled"},
        )
        self._s.commit()
        return self._view(sale)

    def get_sale(self, *, actor: User, sale_id: str) -> SaleView:
        sale = self._s.get(SaleModel, sale_id)
        if sale is None:
            raise NotFoundError("SALE_NOT_FOUND", sale_id=sale_id)
        require_any_permission(
            _POLICY, actor, (Permission.SALE_CREATE, Permission.REPORT_VIEW), sale.branch_id
        )
        return self._view(sale)

    def open_shift(self, *, actor: User, branch_id: str, opening_float_minor: int) -> ShiftView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        require_active_branch(self._s, branch_id)
        assert_shift_cash_valid(amount_minor=opening_float_minor)
        already = self._s.scalar(
            select(ShiftModel.id).where(
                ShiftModel.branch_id == branch_id, ShiftModel.user_id == actor.id,
                ShiftModel.status == "open", ShiftModel.deleted_at.is_(None),
            ).limit(1)
        )
        if already is not None:
            # One drawer per seller per branch: sales would split between two counts.
            raise ConflictError("SHIFT_ALREADY_OPEN", shift_id=already)
        shift = ShiftModel(
            id=new_id(), branch_id=branch_id, user_id=actor.id,
            opening_float_minor=opening_float_minor, status="open", created_by=actor.id,
        )
        self._s.add(shift)
        record_change(self._s, "shifts", shift, op="insert", branch_id=branch_id)
        self._audit("shift.opened", actor.id, shift.id, {"opening_float": opening_float_minor})
        self._s.commit()
        return ShiftView(
            id=shift.id, status=shift.status, opening_float_minor=shift.opening_float_minor,
            expected_cash_minor=None, counted_cash_minor=None, variance_minor=None,
        )

    def close_shift(self, *, actor: User, shift_id: str, counted_cash_minor: int) -> ShiftView:
        shift = self._s.scalar(
            select(ShiftModel).where(ShiftModel.id == shift_id).with_for_update()
        )
        if shift is None:
            raise NotFoundError("SHIFT_NOT_FOUND", shift_id=shift_id)
        # Closing your own shift is a cashier's job; closing someone else's sets
        # their variance, which is a manager's.
        needed = Permission.SALE_CREATE if shift.user_id == actor.id else Permission.REPORT_VIEW
        require_permission(_POLICY, actor, needed, shift.branch_id)
        if shift.status != "open":
            raise ConflictError("SHIFT_ALREADY_CLOSED", shift_id=shift.id)
        assert_shift_cash_valid(amount_minor=counted_cash_minor)
        # The float, its sales' cash and the debts it collected in cash.
        expected = expected_cash(self._s, shift.id)
        shift.expected_cash_minor = expected
        shift.counted_cash_minor = counted_cash_minor
        shift.variance_minor = counted_cash_minor - expected
        shift.closed_at = datetime.now(UTC)
        shift.status = "closed"
        shift.version += 1  # devices take the closed image over their open one
        record_change(self._s, "shifts", shift, op="update", branch_id=shift.branch_id)
        self._audit("shift.closed", actor.id, shift.id, {"variance": shift.variance_minor})
        self._s.commit()
        return ShiftView(
            id=shift.id, status=shift.status, opening_float_minor=shift.opening_float_minor,
            expected_cash_minor=expected, counted_cash_minor=counted_cash_minor,
            variance_minor=shift.variance_minor,
        )
