"""Sales / POS endpoints. Depend on the SalesService port only."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel

from dukan.application.sales import PaymentInput, SaleLineInput, SalesService
from dukan.domain.identity import User
from dukan.ui.deps import active_branch, get_current_actor, get_sales_service
from dukan.ui.serializers import sale_view_dict, shift_view_dict

router = APIRouter(tags=["sales"])

Actor = Annotated[User, Depends(get_current_actor)]
Sales = Annotated[SalesService, Depends(get_sales_service)]
BranchHeader = Annotated[str | None, Header()]


class LineReq(BaseModel):
    product_id: str
    qty_minor: int


class PayReq(BaseModel):
    method: str = "cash"
    amount_minor: int
    tendered_minor: int | None = None


class SettleSaleRequest(BaseModel):
    lines: list[LineReq]
    discount_minor: int = 0
    payments: list[PayReq]
    shift_id: str | None = None
    customer_id: str | None = None


class OpenShiftRequest(BaseModel):
    opening_float_minor: int = 0


class CloseShiftRequest(BaseModel):
    counted_cash_minor: int


@router.post("/sales")
def settle_sale(
    body: SettleSaleRequest, actor: Actor, svc: Sales, x_branch_id: BranchHeader = None
) -> dict:
    return sale_view_dict(
        svc.settle_sale(
            actor=actor,
            branch_id=active_branch(actor, x_branch_id),
            lines=[
                SaleLineInput(product_id=l.product_id, qty_minor=l.qty_minor) for l in body.lines
            ],
            discount_minor=body.discount_minor,
            payments=[
                PaymentInput(
                    method=p.method, amount_minor=p.amount_minor, tendered_minor=p.tendered_minor
                )
                for p in body.payments
            ],
            shift_id=body.shift_id,
            customer_id=body.customer_id,
        )
    )


@router.get("/sales/{sale_id}")
def get_sale(sale_id: str, actor: Actor, svc: Sales) -> dict:
    return sale_view_dict(svc.get_sale(sale_id=sale_id))


@router.post("/sales/{sale_id}/void")
def void_sale(sale_id: str, actor: Actor, svc: Sales, x_branch_id: BranchHeader = None) -> dict:
    return sale_view_dict(
        svc.void_sale(actor=actor, branch_id=active_branch(actor, x_branch_id), sale_id=sale_id)
    )


@router.post("/shifts")
def open_shift(
    body: OpenShiftRequest, actor: Actor, svc: Sales, x_branch_id: BranchHeader = None
) -> dict:
    return shift_view_dict(
        svc.open_shift(
            actor=actor, branch_id=active_branch(actor, x_branch_id),
            opening_float_minor=body.opening_float_minor,
        )
    )


@router.post("/shifts/{shift_id}/close")
def close_shift(shift_id: str, body: CloseShiftRequest, actor: Actor, svc: Sales) -> dict:
    return shift_view_dict(
        svc.close_shift(actor=actor, shift_id=shift_id, counted_cash_minor=body.counted_cash_minor)
    )
