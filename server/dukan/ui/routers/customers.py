"""Customers + debt endpoints."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel

from dukan.application.customers import CustomerService
from dukan.domain.identity import User
from dukan.ui.deps import active_branch, get_current_actor, get_customer_service
from dukan.ui.fields import Int32, Str32, Str128
from dukan.ui.serializers import customer_view_dict

router = APIRouter(tags=["customers"])

Actor = Annotated[User, Depends(get_current_actor)]
Customers = Annotated[CustomerService, Depends(get_customer_service)]
BranchHeader = Annotated[str | None, Header()]


class CreateCustomerRequest(BaseModel):
    name: Str128
    phone: Str32 | None = None
    credit_limit_minor: Int32 | None = None


class PaymentRequest(BaseModel):
    amount_minor: Int32


@router.get("/customers")
def list_customers(
    actor: Actor, svc: Customers, search: str | None = None, x_branch_id: BranchHeader = None
) -> list[dict]:
    views = svc.list_customers(
        actor=actor, branch_id=active_branch(actor, x_branch_id), search=search
    )
    return [customer_view_dict(v) for v in views]


@router.post("/customers")
def create_customer(
    body: CreateCustomerRequest, actor: Actor, svc: Customers, x_branch_id: BranchHeader = None
) -> dict:
    return customer_view_dict(
        svc.create_customer(
            actor=actor, branch_id=active_branch(actor, x_branch_id),
            name=body.name, phone=body.phone, credit_limit_minor=body.credit_limit_minor,
        )
    )


@router.get("/customers/{customer_id}")
def get_customer(
    customer_id: str, actor: Actor, svc: Customers, x_branch_id: BranchHeader = None
) -> dict:
    return customer_view_dict(
        svc.get_customer(
            actor=actor, branch_id=active_branch(actor, x_branch_id), customer_id=customer_id
        )
    )


@router.post("/customers/{customer_id}/payments")
def record_payment(
    customer_id: str,
    body: PaymentRequest,
    actor: Actor,
    svc: Customers,
    x_branch_id: BranchHeader = None,
) -> dict:
    return customer_view_dict(
        svc.record_payment(
            actor=actor, branch_id=active_branch(actor, x_branch_id),
            customer_id=customer_id, amount_minor=body.amount_minor,
        )
    )
