"""Concrete SalesService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_any_permission, require_permission
from dukan.application.sales import (
    PaymentInput,
    RefundLineInput,
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
    assert_refund_valid,
    assert_sale_lines_valid,
    assert_sale_not_overpaid,
    assert_settleable,
    assert_shift_cash_valid,
    compute_totals,
    refund_total_minor,
    returned_value_minor,
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

# How money goes back on a return; only cash comes out of a drawer.
_REFUND_METHODS = ("cash", "card", "transfer")


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

    def _has_refunds(self, sale_id: str) -> bool:
        return self._s.scalar(
            select(SaleModel.id)
            .where(SaleModel.refund_of == sale_id, SaleModel.deleted_at.is_(None))
            .limit(1)
        ) is not None

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
            refund_of=sale.refund_of,
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
        # A return is not voided, and a sale with returns is past voiding: its
        # goods and money have moved again since.
        if sale.refund_of is not None:
            raise ConflictError("SALE_NOT_VOIDABLE", status="refund")
        if self._has_refunds(sale.id):
            raise ConflictError("SALE_NOT_VOIDABLE", status="refunded")
        shift = (
            self._s.scalar(
                select(ShiftModel).where(ShiftModel.id == sale.shift_id).with_for_update()
            )
            if sale.shift_id else None
        )
        # A sale whose shift closed keeps its cash in that shift's count: handing it
        # back is a refund (not built yet), not a void. One that took no cash (on
        # credit, by card or transfer) changes nothing in the counted drawer.
        cash_taken = int(self._s.scalar(
            select(func.coalesce(func.sum(PaymentModel.amount_minor), 0)).where(
                PaymentModel.sale_id == sale.id, PaymentModel.method == "cash",
                PaymentModel.deleted_at.is_(None),
            )
        ) or 0)
        if shift is not None and shift.status != "open" and cash_taken > 0:
            raise ConflictError("SALE_SHIFT_CLOSED", shift_id=shift.id)
        charges = self._s.scalars(
            select(CustomerLedgerModel).where(
                CustomerLedgerModel.type == "charge", CustomerLedgerModel.ref_type == "sale",
                CustomerLedgerModel.ref_id == sale.id, CustomerLedgerModel.deleted_at.is_(None),
            )
        ).all()
        # The customers whose debt it takes back: locked before the feed lock (row
        # locks first, docs/sync-protocol.md) and their balances read once.
        owed: dict[str, int] = {}
        for customer_id in sorted({c.customer_id for c in charges}):
            self._s.scalar(
                select(CustomerModel.id).where(CustomerModel.id == customer_id).with_for_update()
            )
            owed[customer_id] = self._customer_balance(customer_id)
        sale.status = "voided"
        record_change(self._s, "sales", sale, op="update", branch_id=sale.branch_id)
        # What the sale took from stock comes back: its own movements, so a product
        # that was not stock-tracked when it sold (it never moved) gets none.
        taken = self._s.scalars(
            select(StockMovementModel).where(
                StockMovementModel.ref_type == "sale", StockMovementModel.ref_id == sale.id,
                StockMovementModel.deleted_at.is_(None),
            )
        ).all()
        for m in taken:
            back = StockMovementModel(
                id=new_id(), product_id=m.product_id, branch_id=m.branch_id,
                qty_delta=-m.qty_delta, reason="returned", ref_type="void", ref_id=sale.id,
                created_by=actor.id,
            )
            self._s.add(back)
            record_change(self._s, "stock_movements", back, op="insert", branch_id=m.branch_id)
        # The debt the sale put on a customer goes too, as far as it is still owed: a
        # write-off already forgave it, and money paid against it is a refund, so a
        # void never leaves the shop owing the customer. The ledger is append-only: a
        # compensating entry per charge.
        reversed_debt = 0
        not_reversed = 0
        for c in charges:
            back_minor = min(c.amount_minor, max(owed[c.customer_id], 0))
            owed[c.customer_id] -= back_minor
            not_reversed += c.amount_minor - back_minor
            if back_minor == 0:
                continue
            undo = CustomerLedgerModel(
                id=new_id(), customer_id=c.customer_id, type="adjustment",
                amount_minor=-back_minor, currency=c.currency, ref_type="void",
                ref_id=sale.id, created_by=actor.id,
            )
            self._s.add(undo)
            record_change(self._s, "customer_ledger", undo, op="insert", branch_id=None)
            reversed_debt += back_minor
        self._audit(
            "sale.voided", actor.id, sale.id,
            {
                "number": sale.number, "status": "voided", "reason": reason.strip(),
                **({"debt_reversed": reversed_debt} if reversed_debt else {}),
                **({"debt_not_reversed": not_reversed} if not_reversed else {}),
            },
            before={"status": "settled"},
        )
        self._s.commit()
        return self._view(sale)

    def refund_sale(
        self, *, actor: User, sale_id: str, lines: list[RefundLineInput], reason: str,
        method: str, shift_id: str | None,
    ) -> SaleView:
        # Locked: two returns of one sale, or a return racing a void, take turns.
        sale = self._s.scalar(select(SaleModel).where(SaleModel.id == sale_id).with_for_update())
        if sale is None or sale.deleted_at is not None:
            raise NotFoundError("SALE_NOT_FOUND", sale_id=sale_id)
        # Money leaves the shop: a manager's call, in the sale's own branch.
        require_permission(_POLICY, actor, Permission.SALE_VOID, sale.branch_id)
        require_active_branch(self._s, sale.branch_id)
        if sale.status != "settled" or sale.refund_of is not None:
            raise ConflictError("SALE_NOT_REFUNDABLE", status=sale.status)
        if method not in _REFUND_METHODS:
            raise ValidationError("REFUND_METHOD_INVALID", method=method)

        # What the sale sold of each product, and what earlier returns took back.
        sold_qty: dict[str, int] = {}
        sold_value: dict[str, int] = {}
        source: dict[str, SaleLineModel] = {}
        for line in self._s.scalars(
            select(SaleLineModel).where(
                SaleLineModel.sale_id == sale.id, SaleLineModel.deleted_at.is_(None)
            )
        ):
            sold_qty[line.product_id] = sold_qty.get(line.product_id, 0) + line.qty_minor
            sold_value[line.product_id] = (
                sold_value.get(line.product_id, 0) + line.line_total_minor
            )
            source.setdefault(line.product_id, line)
        earlier = self._s.scalars(
            select(SaleModel).where(SaleModel.refund_of == sale.id, SaleModel.deleted_at.is_(None))
        ).all()
        earlier_ids = [r.id for r in earlier]
        returned: dict[str, int] = {}
        if earlier_ids:
            for line in self._s.scalars(
                select(SaleLineModel).where(
                    SaleLineModel.sale_id.in_(earlier_ids), SaleLineModel.deleted_at.is_(None)
                )
            ):
                returned[line.product_id] = returned.get(line.product_id, 0) - line.qty_minor
        returnable = {p: q - returned.get(p, 0) for p, q in sold_qty.items()}
        wanted: dict[str, int] = {}
        for item in lines:
            wanted[item.product_id] = wanted.get(item.product_id, 0) + item.qty_minor
        assert_refund_valid(reason=reason, wanted=wanted, returnable=returnable)

        values = {
            p: returned_value_minor(
                line_total_minor=sold_value[p], sold_qty_minor=sold_qty[p], returned_qty_minor=q
            )
            for p, q in wanted.items()
        }
        gross = sum(values.values())
        left_of_total = sale.total_minor + sum(r.total_minor for r in earlier)  # returns are < 0
        if all(returnable[p] == wanted.get(p, 0) for p in returnable):
            # The last return takes what is left, so rounding never strands a coin.
            total = left_of_total
        else:
            total = min(
                refund_total_minor(
                    gross_minor=gross, sale_subtotal_minor=sale.subtotal_minor,
                    sale_discount_minor=sale.discount_minor,
                ),
                left_of_total,
            )

        # Row locks before the feed lock, in the void's order: the sale, the drawer,
        # the customer (docs/sync-protocol.md).
        shift = (
            require_open_shift(
                self._s, shift_id=shift_id, user_id=actor.id, branch_id=sale.branch_id
            )
            if shift_id is not None else None
        )
        # What the customer still owes for this sale comes off first: a return
        # never pays out money the shop has not been paid.
        debt_back = 0
        if sale.customer_id is not None:
            charged = int(self._s.scalar(
                select(func.coalesce(func.sum(CustomerLedgerModel.amount_minor), 0)).where(
                    CustomerLedgerModel.type == "charge", CustomerLedgerModel.ref_type == "sale",
                    CustomerLedgerModel.ref_id == sale.id, CustomerLedgerModel.deleted_at.is_(None),
                )
            ) or 0)
            taken_back = 0
            if earlier_ids:
                taken_back = -int(self._s.scalar(
                    select(func.coalesce(func.sum(CustomerLedgerModel.amount_minor), 0)).where(
                        CustomerLedgerModel.ref_type == "refund",
                        CustomerLedgerModel.ref_id.in_(earlier_ids),
                        CustomerLedgerModel.deleted_at.is_(None),
                    )
                ) or 0)
            if charged > taken_back:
                self._s.scalar(
                    select(CustomerModel.id)
                    .where(CustomerModel.id == sale.customer_id)
                    .with_for_update()
                )
                owed = self._customer_balance(sale.customer_id)
                debt_back = max(0, min(total, charged - taken_back, owed))
        money_back = total - debt_back
        if money_back > 0 and method == "cash" and shift is None:
            # Cash comes out of a drawer: the refunder's own open shift on this till.
            raise ConflictError("SHIFT_NOT_OPEN", shift_id=None)

        refund = SaleModel(
            id=new_id(), number=self._next_number(), branch_id=sale.branch_id,
            shift_id=shift.id if shift is not None else None, customer_id=sale.customer_id,
            status="settled", currency=sale.currency, discount_minor=-(gross - total),
            subtotal_minor=-gross, tax_minor=0, total_minor=-total, paid_minor=-money_back,
            change_minor=0, refund_of=sale.id, created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(refund)
        record_change(self._s, "sales", refund, op="insert", branch_id=sale.branch_id)
        for product_id, qty in wanted.items():
            src = source[product_id]
            line_row = SaleLineModel(
                id=new_id(), sale_id=refund.id, product_id=product_id, name=src.name,
                qty_minor=-qty, decimal_places=src.decimal_places,
                unit_price_minor=src.unit_price_minor, unit_cost_minor=src.unit_cost_minor,
                line_total_minor=-values[product_id], currency=src.currency, created_by=actor.id,
            )
            self._s.add(line_row)
            record_change(self._s, "sale_lines", line_row, op="insert", branch_id=sale.branch_id)
        # Goods come back to stock only if the sale took them from stock.
        moved = set(self._s.scalars(
            select(StockMovementModel.product_id).where(
                StockMovementModel.ref_type == "sale", StockMovementModel.ref_id == sale.id,
                StockMovementModel.deleted_at.is_(None),
            )
        ))
        for product_id, qty in wanted.items():
            if product_id not in moved:
                continue
            back = StockMovementModel(
                id=new_id(), product_id=product_id, branch_id=sale.branch_id, qty_delta=qty,
                reason="returned", ref_type="refund", ref_id=refund.id, created_by=actor.id,
            )
            self._s.add(back)
            record_change(self._s, "stock_movements", back, op="insert", branch_id=sale.branch_id)
        if debt_back > 0 and sale.customer_id is not None:
            undo = CustomerLedgerModel(
                id=new_id(), customer_id=sale.customer_id, type="adjustment",
                amount_minor=-debt_back, currency=sale.currency, ref_type="refund",
                ref_id=refund.id, created_by=actor.id,
            )
            self._s.add(undo)
            record_change(self._s, "customer_ledger", undo, op="insert", branch_id=None)
        if money_back > 0:
            payment = PaymentModel(
                id=new_id(), sale_id=refund.id, method=method, amount_minor=-money_back,
                currency=sale.currency, created_by=actor.id,
            )
            self._s.add(payment)
            record_change(self._s, "payments", payment, op="insert", branch_id=sale.branch_id)
        self._audit(
            "sale.refunded", actor.id, sale.id,
            {
                "refund_id": refund.id, "number": refund.number, "total": total,
                "method": method, "reason": reason.strip(),
                **({"debt_reversed": debt_back} if debt_back else {}),
                **({"money_back": money_back} if money_back else {}),
            },
        )
        self._s.commit()
        return self._view(refund)

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
        # their variance, which is a manager's (sale.void: owner, manager).
        needed = Permission.SALE_CREATE if shift.user_id == actor.id else Permission.SALE_VOID
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
