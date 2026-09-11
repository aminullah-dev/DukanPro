"""Purchasing endpoints (suppliers + goods receipts)."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel

from dukan.application.purchasing import PurchasingService, ReceiptLineInput
from dukan.domain.identity import User
from dukan.ui.deps import active_branch, get_current_actor, get_purchasing_service
from dukan.ui.serializers import goods_receipt_view_dict, supplier_view_dict

router = APIRouter(tags=["purchasing"])

Actor = Annotated[User, Depends(get_current_actor)]
Purchasing = Annotated[PurchasingService, Depends(get_purchasing_service)]
BranchHeader = Annotated[str | None, Header()]


class CreateSupplierRequest(BaseModel):
    name: str
    phone: str | None = None


class ReceiptLineReq(BaseModel):
    product_id: str
    qty_minor: int
    unit_cost_minor: int


class ReceiveGoodsRequest(BaseModel):
    supplier_id: str | None = None
    lines: list[ReceiptLineReq]


@router.get("/suppliers")
def list_suppliers(actor: Actor, svc: Purchasing) -> list[dict]:
    return [supplier_view_dict(v) for v in svc.list_suppliers()]


@router.post("/suppliers")
def create_supplier(
    body: CreateSupplierRequest,
    actor: Actor,
    svc: Purchasing,
    x_branch_id: BranchHeader = None,
) -> dict:
    return supplier_view_dict(
        svc.create_supplier(
            actor=actor, branch_id=active_branch(actor, x_branch_id),
            name=body.name, phone=body.phone,
        )
    )


@router.post("/goods-receipts")
def receive_goods(
    body: ReceiveGoodsRequest, actor: Actor, svc: Purchasing, x_branch_id: BranchHeader = None
) -> dict:
    return goods_receipt_view_dict(
        svc.receive_goods(
            actor=actor, branch_id=active_branch(actor, x_branch_id), supplier_id=body.supplier_id,
            lines=[
                ReceiptLineInput(
                    product_id=l.product_id,
                    qty_minor=l.qty_minor,
                    unit_cost_minor=l.unit_cost_minor,
                )
                for l in body.lines
            ],
        )
    )
