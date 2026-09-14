"""Concrete CatalogService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from dukan.application.access import require_any_permission, require_permission
from dukan.application.catalog import CatalogService, ProductView
from dukan.domain.catalog import assert_unique_barcode, assert_unique_sku
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.inventory import adjust_stock
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BarcodeModel,
    ProductModel,
    StockMovementModel,
    UnitModel,
)
from dukan.infrastructure.scope import require_active_branch
from dukan.shared.errors import NotFoundError, ValidationError
from dukan.shared.ids import new_id
from dukan.shared.money import Money

_POLICY = PermissionPolicy()
_DEFAULT_UNITS = [("piece", 0), ("kg", 3), ("litre", 3), ("dozen", 0), ("meter", 2)]


class SqlCatalogService(CatalogService):
    def __init__(self, session: Session) -> None:
        self._s = session

    # ---- helpers ----------------------------------------------------------
    def _audit(
        self,
        action: str,
        actor_id: str,
        entity_id: str,
        after: dict | None = None,
        before: dict | None = None,
    ) -> None:
        self._s.add(
            AuditEntryModel(
                id=new_id(), action=action, actor_id=actor_id, entity_type="product",
                entity_id=entity_id, before=before, after=after, origin="api",
            )
        )

    def _on_hand(self, product_id: str, branch_id: str) -> int:
        total = self._s.scalar(
            select(func.coalesce(func.sum(StockMovementModel.qty_delta), 0)).where(
                StockMovementModel.product_id == product_id,
                StockMovementModel.branch_id == branch_id,
                StockMovementModel.deleted_at.is_(None),
            )
        )
        return int(total or 0)

    def _view(self, p: ProductModel, branch_id: str) -> ProductView:
        codes = self._s.scalars(
            select(BarcodeModel.code).where(
                BarcodeModel.product_id == p.id, BarcodeModel.deleted_at.is_(None)
            )
        ).all()
        return ProductView(
            id=p.id, sku=p.sku, name=p.name, unit_id=p.unit_id,
            sell_price_minor=p.sell_price_minor, sell_currency=p.sell_currency,
            category_id=p.category_id, track_stock=p.track_stock, is_active=p.is_active,
            on_hand=self._on_hand(p.id, branch_id), barcodes=tuple(codes),
        )

    def _get(self, product_id: str) -> ProductModel:
        p = self._s.scalar(
            select(ProductModel).where(
                ProductModel.id == product_id, ProductModel.deleted_at.is_(None)
            )
        )
        if p is None:
            raise NotFoundError("PRODUCT_NOT_FOUND", product_id=product_id)
        return p

    # ---- CatalogService ---------------------------------------------------
    def list_units(self) -> list[dict]:
        rows = self._s.scalars(select(UnitModel).where(UnitModel.deleted_at.is_(None))).all()
        if not rows:
            for name, dp in _DEFAULT_UNITS:
                self._s.add(UnitModel(id=new_id(), name=name, decimal_places=dp))
            self._s.commit()
            rows = self._s.scalars(select(UnitModel).where(UnitModel.deleted_at.is_(None))).all()
        return [{"id": u.id, "name": u.name, "decimal_places": u.decimal_places} for u in rows]

    def create_product(
        self,
        *,
        actor: User,
        branch_id: str,
        sku: str,
        name: str,
        unit_id: str,
        sell_price_minor: int,
        currency: str,
        category_id: str | None,
        track_stock: bool,
        barcodes: list[str],
    ) -> ProductView:
        require_permission(_POLICY, actor, Permission.PRODUCT_MANAGE, branch_id)
        require_active_branch(self._s, branch_id)
        Money(sell_price_minor, currency).validated()
        if self._s.scalar(
            select(UnitModel).where(UnitModel.id == unit_id, UnitModel.deleted_at.is_(None))
        ) is None:
            raise ValidationError("UNIT_NOT_FOUND", unit_id=unit_id)
        sku_taken = self._s.scalar(
            select(ProductModel).where(
                ProductModel.sku == sku, ProductModel.deleted_at.is_(None)
            )
        ) is not None
        assert_unique_sku(sku=sku, taken=sku_taken)

        product = ProductModel(
            id=new_id(), sku=sku, name=name, unit_id=unit_id, category_id=category_id,
            sell_price_minor=sell_price_minor, sell_currency=currency, track_stock=track_stock,
            created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(product)
        for code in barcodes:
            taken = self._s.scalar(
                select(BarcodeModel).where(
                    BarcodeModel.code == code, BarcodeModel.deleted_at.is_(None)
                )
            ) is not None
            assert_unique_barcode(code=code, taken=taken)
            self._s.add(
                BarcodeModel(id=new_id(), product_id=product.id, code=code, created_by=actor.id)
            )
        self._audit("product.created", actor.id, product.id, {"sku": sku, "name": name})
        self._s.commit()
        return self._view(product, branch_id)

    def update_product(
        self,
        *,
        actor: User,
        branch_id: str,
        product_id: str,
        name: str | None,
        sell_price_minor: int | None,
        is_active: bool | None,
    ) -> ProductView:
        require_permission(_POLICY, actor, Permission.PRODUCT_MANAGE, branch_id)
        require_active_branch(self._s, branch_id)
        product = self._get(product_id)
        if name is not None:
            product.name = name
        if is_active is not None:
            product.is_active = is_active
        if sell_price_minor is not None and sell_price_minor != product.sell_price_minor:
            # A price change is money — needs price.change and is audited.
            require_permission(_POLICY, actor, Permission.PRICE_CHANGE, branch_id)
            before = product.sell_price_minor
            product.sell_price_minor = sell_price_minor
            self._audit(
                "product.price_changed", actor.id, product.id,
                after={"price_minor": sell_price_minor}, before={"price_minor": before},
            )
        product.updated_by = actor.id
        self._s.commit()
        return self._view(product, branch_id)

    def add_barcode(
        self, *, actor: User, branch_id: str, product_id: str, code: str
    ) -> ProductView:
        require_permission(_POLICY, actor, Permission.PRODUCT_MANAGE, branch_id)
        require_active_branch(self._s, branch_id)
        product = self._get(product_id)
        taken = self._s.scalar(
            select(BarcodeModel).where(
                BarcodeModel.code == code, BarcodeModel.deleted_at.is_(None)
            )
        ) is not None
        assert_unique_barcode(code=code, taken=taken)
        self._s.add(
            BarcodeModel(id=new_id(), product_id=product.id, code=code, created_by=actor.id)
        )
        self._audit("barcode.added", actor.id, product.id, {"code": code})
        self._s.commit()
        return self._view(product, branch_id)

    def _require_member(self, actor: User, branch_id: str) -> None:
        # On-hand is per branch: only someone who works there reads it.
        require_any_permission(_POLICY, actor, tuple(Permission), branch_id)

    def list_products(
        self, *, actor: User, branch_id: str, search: str | None
    ) -> list[ProductView]:
        self._require_member(actor, branch_id)
        stmt = select(ProductModel).where(ProductModel.deleted_at.is_(None))
        if search:
            like = f"%{search}%"
            stmt = stmt.where(or_(ProductModel.name.ilike(like), ProductModel.sku.ilike(like)))
        stmt = stmt.order_by(ProductModel.name)
        return [self._view(p, branch_id) for p in self._s.scalars(stmt)]

    def get_product(self, *, actor: User, branch_id: str, product_id: str) -> ProductView:
        self._require_member(actor, branch_id)
        return self._view(self._get(product_id), branch_id)

    def adjust_stock(
        self, *, actor: User, branch_id: str, product_id: str, qty_delta: int
    ) -> ProductView:
        require_permission(_POLICY, actor, Permission.STOCK_ADJUST, branch_id)
        require_active_branch(self._s, branch_id)
        product = self._get(product_id)
        if not product.track_stock:
            raise ValidationError("PRODUCT_NOT_STOCK_TRACKED", product_id=product_id)
        movement = adjust_stock(
            id=new_id(), product_id=product.id, branch_id=branch_id,
            qty_delta=qty_delta, at=datetime.now(UTC),
        )
        self._s.add(
            StockMovementModel(
                id=movement.id, product_id=movement.product_id, branch_id=movement.branch_id,
                qty_delta=movement.qty_delta, reason=movement.reason.value,
                occurred_at=movement.occurred_at, created_by=actor.id,
            )
        )
        self._audit("stock.adjusted", actor.id, product.id, {"qty_delta": qty_delta})
        self._s.commit()
        return self._view(product, branch_id)
