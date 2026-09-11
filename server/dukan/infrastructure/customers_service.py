"""Concrete CustomerService bound to a SQLAlchemy session."""

from __future__ import annotations

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from dukan.application.access import require_permission
from dukan.application.customers import CustomerService, CustomerView
from dukan.domain.customers import (
    CustomerLedgerEntry,
    LedgerEntryType,
    assert_not_overpaid,
    ledger_balance,
)
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.infrastructure.db.models import AuditEntryModel, CustomerLedgerModel, CustomerModel
from dukan.shared.errors import NotFoundError
from dukan.shared.ids import new_id

_POLICY = PermissionPolicy()


class SqlCustomerService(CustomerService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def _audit(self, action: str, actor_id: str, entity_id: str, after: dict | None = None) -> None:
        self._s.add(
            AuditEntryModel(
                id=new_id(), action=action, actor_id=actor_id, entity_type="customer",
                entity_id=entity_id, after=after, origin="api",
            )
        )

    def _balance(self, customer_id: str) -> int:
        rows = self._s.scalars(
            select(CustomerLedgerModel).where(
                CustomerLedgerModel.customer_id == customer_id,
                CustomerLedgerModel.deleted_at.is_(None),
            )
        ).all()
        entries = [
            CustomerLedgerEntry(
                id=r.id, customer_id=r.customer_id, type=LedgerEntryType(r.type),
                amount_minor=r.amount_minor, currency=r.currency, occurred_at=r.occurred_at,
            )
            for r in rows
        ]
        return ledger_balance(entries)

    def _view(self, c: CustomerModel) -> CustomerView:
        return CustomerView(
            id=c.id, name=c.name, phone=c.phone, credit_limit_minor=c.credit_limit_minor,
            currency=c.currency, balance_minor=self._balance(c.id),
        )

    def _get(self, customer_id: str) -> CustomerModel:
        c = self._s.scalar(
            select(CustomerModel).where(
                CustomerModel.id == customer_id, CustomerModel.deleted_at.is_(None)
            )
        )
        if c is None:
            raise NotFoundError("CUSTOMER_NOT_FOUND", customer_id=customer_id)
        return c

    def create_customer(
        self, *, actor: User, branch_id: str, name: str, phone: str | None,
        credit_limit_minor: int | None,
    ) -> CustomerView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        c = CustomerModel(
            id=new_id(), name=name, phone=phone, credit_limit_minor=credit_limit_minor,
            created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(c)
        self._audit("customer.created", actor.id, c.id, {"name": name})
        self._s.commit()
        return self._view(c)

    def list_customers(self, *, search: str | None) -> list[CustomerView]:
        stmt = select(CustomerModel).where(CustomerModel.deleted_at.is_(None))
        if search:
            like = f"%{search}%"
            stmt = stmt.where(or_(CustomerModel.name.ilike(like), CustomerModel.phone.ilike(like)))
        return [self._view(c) for c in self._s.scalars(stmt.order_by(CustomerModel.name))]

    def get_customer(self, *, customer_id: str) -> CustomerView:
        return self._view(self._get(customer_id))

    def record_payment(
        self, *, actor: User, branch_id: str, customer_id: str, amount_minor: int
    ) -> CustomerView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        customer = self._get(customer_id)
        assert_not_overpaid(balance_minor=self._balance(customer_id), payment_minor=amount_minor)
        self._s.add(
            CustomerLedgerModel(
                id=new_id(), customer_id=customer_id, type="payment", amount_minor=amount_minor,
                currency=customer.currency, ref_type="manual", created_by=actor.id,
            )
        )
        self._audit("debt.payment_recorded", actor.id, customer_id, {"amount": amount_minor})
        self._s.commit()
        return self._view(customer)
