"""A shift's drawer: which shift a sale or a debt collection may go into, and
what the drawer should hold at the close."""

from __future__ import annotations

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from dukan.infrastructure.db.models import (
    CustomerLedgerModel,
    PaymentModel,
    SaleModel,
    ShiftModel,
    SupplierLedgerModel,
)
from dukan.shared.errors import ConflictError, NotFoundError


def require_open_shift(
    session: Session, *, shift_id: str, user_id: str, branch_id: str
) -> ShiftModel:
    """The seller's own open shift in this branch, locked so a close waits for
    the sale or collection going into it. Any other shift's cash would be in no
    drawer's count. Raises NotFoundError SHIFT_NOT_FOUND or ConflictError
    SHIFT_NOT_OPEN."""
    shift = session.scalar(select(ShiftModel).where(ShiftModel.id == shift_id).with_for_update())
    if shift is None or shift.deleted_at is not None:
        raise NotFoundError("SHIFT_NOT_FOUND", shift_id=shift_id)
    if shift.status != "open" or shift.branch_id != branch_id or shift.user_id != user_id:
        raise ConflictError("SHIFT_NOT_OPEN", shift_id=shift_id)
    return shift


def expected_cash(session: Session, shift_id: str) -> int:
    """What the drawer should hold: the opening float, the cash taken by the
    shift's settled sales and the debts collected in it in cash, less the cash
    paid out of it to suppliers. A voided sale's cash went back; card and
    transfer money never reaches the drawer."""
    shift = session.get(ShiftModel, shift_id)
    opening = shift.opening_float_minor if shift is not None else 0
    sales = session.scalar(
        select(func.coalesce(func.sum(PaymentModel.amount_minor), 0))
        .select_from(PaymentModel)
        .join(SaleModel, SaleModel.id == PaymentModel.sale_id)
        .where(
            SaleModel.shift_id == shift_id, SaleModel.status == "settled",
            PaymentModel.method == "cash", PaymentModel.deleted_at.is_(None),
        )
    ) or 0
    collected = session.scalar(
        select(func.coalesce(func.sum(CustomerLedgerModel.amount_minor), 0)).where(
            CustomerLedgerModel.shift_id == shift_id, CustomerLedgerModel.type == "payment",
            CustomerLedgerModel.method == "cash", CustomerLedgerModel.deleted_at.is_(None),
        )
    ) or 0
    paid_out = session.scalar(
        select(func.coalesce(func.sum(SupplierLedgerModel.amount_minor), 0)).where(
            SupplierLedgerModel.shift_id == shift_id, SupplierLedgerModel.type == "payment",
            SupplierLedgerModel.method == "cash", SupplierLedgerModel.deleted_at.is_(None),
        )
    ) or 0
    return int(opening) + int(sales) + int(collected) - int(paid_out)
