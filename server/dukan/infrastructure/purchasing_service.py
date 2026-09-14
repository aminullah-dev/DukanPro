"""Concrete PurchasingService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.application.access import require_any_permission, require_permission
from dukan.application.purchasing import (
    GoodsReceiptView,
    PurchasingService,
    ReceiptLineInput,
    SupplierView,
)
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.purchasing import (
    ReceiptLine,
    SupplierEntryType,
    SupplierLedgerEntry,
    assert_receivable,
    supplier_balance,
)
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    GoodsReceiptLineModel,
    GoodsReceiptModel,
    ProductModel,
    StockMovementModel,
    SupplierLedgerModel,
    SupplierModel,
    UnitModel,
)
from dukan.infrastructure.scope import require_active_branch
from dukan.shared.errors import ConflictError, NotFoundError, ValidationError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()


class SqlPurchasingService(PurchasingService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def _supplier_balance(self, supplier_id: str) -> int:
        rows = self._s.scalars(
            select(SupplierLedgerModel).where(
                SupplierLedgerModel.supplier_id == supplier_id,
                SupplierLedgerModel.deleted_at.is_(None),
            )
        ).all()
        entries = [
            SupplierLedgerEntry(
                id=r.id, supplier_id=r.supplier_id, type=SupplierEntryType(r.type),
                amount_minor=r.amount_minor, currency=r.currency, occurred_at=r.occurred_at,
            )
            for r in rows
        ]
        return supplier_balance(entries)

    def _view(self, s: SupplierModel) -> SupplierView:
        return SupplierView(
            id=s.id, name=s.name, phone=s.phone, currency=s.currency,
            balance_minor=self._supplier_balance(s.id),
        )

    def create_supplier(
        self, *, actor: User, branch_id: str, name: str, phone: str | None
    ) -> SupplierView:
        require_permission(_POLICY, actor, Permission.PRODUCT_MANAGE, branch_id)
        require_active_branch(self._s, branch_id)
        s = SupplierModel(
            id=new_id(), name=name, phone=phone, created_by=actor.id, updated_by=actor.id
        )
        self._s.add(s)
        self._s.commit()
        return self._view(s)

    def list_suppliers(self, *, actor: User, branch_id: str) -> list[SupplierView]:
        require_any_permission(
            _POLICY, actor,
            (Permission.STOCK_ADJUST, Permission.PRODUCT_MANAGE, Permission.REPORT_VIEW),
            branch_id,
        )
        stmt = (
            select(SupplierModel)
            .where(SupplierModel.deleted_at.is_(None))
            .order_by(SupplierModel.name)
        )
        return [self._view(s) for s in self._s.scalars(stmt)]

    def _next_number(self) -> str:
        year = datetime.now(UTC).year
        count = self._s.scalar(select(func.count()).select_from(GoodsReceiptModel)) or 0
        return f"GRN-{year}-{count + 1:05d}"

    def _decimal_places(self, unit_id: str) -> int:
        unit = self._s.get(UnitModel, unit_id)
        if unit is None or unit.deleted_at is not None:
            raise ValidationError("UNIT_NOT_FOUND", unit_id=unit_id)
        return unit.decimal_places

    def receive_goods(
        self, *, actor: User, branch_id: str, supplier_id: str | None, lines: list[ReceiptLineInput]
    ) -> GoodsReceiptView:
        require_permission(_POLICY, actor, Permission.STOCK_ADJUST, branch_id)
        require_active_branch(self._s, branch_id)
        if not lines:
            raise ValidationError("GRN_EMPTY")
        if supplier_id is not None or any(l.unit_cost_minor > 0 for l in lines):
            # A supplier bill is a debt and a cost sets every later margin: both need
            # purchase.cost. Without it a receipt only moves stock.
            require_permission(_POLICY, actor, Permission.PURCHASE_COST, branch_id)
        supplier: SupplierModel | None = None
        if supplier_id is not None:
            supplier = self._s.scalar(
                select(SupplierModel).where(
                    SupplierModel.id == supplier_id, SupplierModel.deleted_at.is_(None)
                )
            )
            if supplier is None:
                raise NotFoundError("SUPPLIER_NOT_FOUND", supplier_id=supplier_id)
        # Each line in its product's unit: a quantity of 10^dp minor units at a cost
        # per whole unit, so 2.500 kg at 40.00 bills 100.00.
        products: dict[str, ProductModel] = {}
        receipt_lines: list[ReceiptLine] = []
        for l in lines:
            product = self._s.scalar(
                select(ProductModel).where(
                    ProductModel.id == l.product_id, ProductModel.deleted_at.is_(None)
                )
            )
            if product is None:
                raise NotFoundError("PRODUCT_NOT_FOUND", product_id=l.product_id)
            line = ReceiptLine(
                product_id=product.id, qty_minor=l.qty_minor, unit_cost_minor=l.unit_cost_minor,
                decimal_places=self._decimal_places(product.unit_id),
            )
            assert_receivable(line)
            if (
                line.unit_cost_minor > 0
                and supplier is not None
                and product.sell_currency != supplier.currency
            ):
                # The bill is in the supplier's currency; no implicit conversion.
                raise ConflictError(
                    "PURCHASE_CURRENCY_MISMATCH",
                    expected=supplier.currency, got=product.sell_currency,
                )
            products[product.id] = product
            receipt_lines.append(line)
        total = sum(line.line_cost for line in receipt_lines)
        receipt = GoodsReceiptModel(
            id=new_id(), number=self._next_number(), supplier_id=supplier_id, branch_id=branch_id,
            total_cost_minor=total, created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(receipt)
        for line in receipt_lines:
            product = products[line.product_id]
            self._s.add(
                GoodsReceiptLineModel(
                    id=new_id(), receipt_id=receipt.id, product_id=line.product_id,
                    qty_minor=line.qty_minor, unit_cost_minor=line.unit_cost_minor,
                    created_by=actor.id,
                )
            )
            self._s.add(
                StockMovementModel(
                    id=new_id(), product_id=line.product_id, branch_id=branch_id,
                    qty_delta=line.qty_minor, reason="purchase", ref_type="goods_receipt",
                    ref_id=receipt.id, created_by=actor.id,
                )
            )
            # A quantity-only receipt leaves the last cost alone.
            if line.unit_cost_minor > 0 and line.unit_cost_minor != product.cost_minor:
                self._s.add(
                    AuditEntryModel(
                        id=new_id(), action="cost.valuation_changed", actor_id=actor.id,
                        entity_type="product", entity_id=product.id,
                        before={"cost_minor": product.cost_minor},
                        after={"cost_minor": line.unit_cost_minor, "receipt_id": receipt.id},
                        origin="api",
                    )
                )
                product.cost_minor = line.unit_cost_minor
                product.cost_currency = product.sell_currency
        if supplier is not None and total > 0:  # a zero bill owes nothing
            self._s.add(
                SupplierLedgerModel(
                    id=new_id(), supplier_id=supplier.id, type="bill", amount_minor=total,
                    currency=supplier.currency, ref_type="goods_receipt", ref_id=receipt.id,
                    created_by=actor.id,
                )
            )
        self._s.add(
            AuditEntryModel(
                id=new_id(), action="purchase.received", actor_id=actor.id,
                entity_type="goods_receipt", entity_id=receipt.id,
                after={"number": receipt.number, "total": total}, origin="api",
            )
        )
        self._s.commit()
        return GoodsReceiptView(
            id=receipt.id, number=receipt.number, supplier_id=supplier_id, total_cost_minor=total
        )
