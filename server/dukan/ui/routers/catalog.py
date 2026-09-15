"""Catalog + inventory endpoints. Depend on the CatalogService port only."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel

from dukan.application.catalog import CatalogService
from dukan.domain.identity import User
from dukan.ui.deps import active_branch, get_catalog_service, get_current_actor
from dukan.ui.fields import Currency, Id, Int32, Money, Str64, Str200
from dukan.ui.serializers import product_view_dict

router = APIRouter(tags=["catalog"])

Actor = Annotated[User, Depends(get_current_actor)]
Catalog = Annotated[CatalogService, Depends(get_catalog_service)]
BranchHeader = Annotated[str | None, Header()]


class CreateProductRequest(BaseModel):
    sku: Str64
    name: Str200
    unit_id: Id
    sell_price_minor: Money
    currency: Currency = "AFN"
    category_id: Id | None = None
    track_stock: bool = True
    barcodes: list[Str64] = []


class UpdateProductRequest(BaseModel):
    sku: Str64 | None = None  # a mistyped SKU is corrected (unique among live products)
    name: Str200 | None = None
    sell_price_minor: Money | None = None
    is_active: bool | None = None
    track_stock: bool | None = None
    version: Int32 | None = None  # the version edited; a newer one is a conflict


class AddBarcodeRequest(BaseModel):
    code: Str64


class AdjustStockRequest(BaseModel):
    product_id: Id
    qty_delta: Money


@router.get("/units")
def list_units(actor: Actor, svc: Catalog) -> list[dict]:
    return svc.list_units()


@router.get("/products")
def list_products(
    actor: Actor, svc: Catalog, search: str | None = None, x_branch_id: BranchHeader = None
) -> list[dict]:
    branch = active_branch(actor, x_branch_id)
    views = svc.list_products(actor=actor, branch_id=branch, search=search)
    return [product_view_dict(v) for v in views]


@router.post("/products")
def create_product(
    body: CreateProductRequest, actor: Actor, svc: Catalog, x_branch_id: BranchHeader = None
) -> dict:
    return product_view_dict(
        svc.create_product(
            actor=actor,
            branch_id=active_branch(actor, x_branch_id),
            sku=body.sku,
            name=body.name,
            unit_id=body.unit_id,
            sell_price_minor=body.sell_price_minor,
            currency=body.currency,
            category_id=body.category_id,
            track_stock=body.track_stock,
            barcodes=body.barcodes,
        )
    )


@router.get("/products/{product_id}")
def get_product(
    product_id: str, actor: Actor, svc: Catalog, x_branch_id: BranchHeader = None
) -> dict:
    return product_view_dict(
        svc.get_product(
            actor=actor, branch_id=active_branch(actor, x_branch_id), product_id=product_id
        )
    )


@router.patch("/products/{product_id}")
def update_product(
    product_id: str,
    body: UpdateProductRequest,
    actor: Actor,
    svc: Catalog,
    x_branch_id: BranchHeader = None,
) -> dict:
    return product_view_dict(
        svc.update_product(
            actor=actor,
            branch_id=active_branch(actor, x_branch_id),
            product_id=product_id,
            name=body.name,
            sell_price_minor=body.sell_price_minor,
            is_active=body.is_active,
            version=body.version,
            track_stock=body.track_stock,
            sku=body.sku,
        )
    )


@router.post("/products/{product_id}/barcodes")
def add_barcode(
    product_id: str,
    body: AddBarcodeRequest,
    actor: Actor,
    svc: Catalog,
    x_branch_id: BranchHeader = None,
) -> dict:
    return product_view_dict(
        svc.add_barcode(
            actor=actor,
            branch_id=active_branch(actor, x_branch_id),
            product_id=product_id,
            code=body.code,
        )
    )


@router.delete("/products/{product_id}/barcodes/{code}")
def remove_barcode(
    product_id: str, code: str, actor: Actor, svc: Catalog, x_branch_id: BranchHeader = None
) -> dict:
    return product_view_dict(
        svc.remove_barcode(
            actor=actor, branch_id=active_branch(actor, x_branch_id), product_id=product_id,
            code=code,
        )
    )


@router.post("/stock/adjust")
def adjust_stock(
    body: AdjustStockRequest, actor: Actor, svc: Catalog, x_branch_id: BranchHeader = None
) -> dict:
    return product_view_dict(
        svc.adjust_stock(
            actor=actor,
            branch_id=active_branch(actor, x_branch_id),
            product_id=body.product_id,
            qty_delta=body.qty_delta,
        )
    )
