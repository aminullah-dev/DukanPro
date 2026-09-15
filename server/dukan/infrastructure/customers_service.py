"""Concrete CustomerService bound to a SQLAlchemy session."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import TYPE_CHECKING, Any, cast

from sqlalchemy import or_, select, update
from sqlalchemy.orm import Session

from dukan.application.access import require_any_permission, require_permission
from dukan.application.customers import CustomerService, CustomerView
from dukan.domain.customers import (
    CustomerLedgerEntry,
    LedgerEntryType,
    assert_credit_limit_valid,
    assert_debt_payment_valid,
    assert_not_overpaid,
    assert_write_off_valid,
    ledger_balance,
)
from dukan.domain.identity import Permission, PermissionPolicy, User
from dukan.domain.sales import assert_payment_valid
from dukan.infrastructure.change_feed import record_change
from dukan.infrastructure.db.models import AuditEntryModel, CustomerLedgerModel, CustomerModel
from dukan.infrastructure.scope import require_active_branch
from dukan.infrastructure.shift_cash import require_open_shift
from dukan.shared.errors import ConflictError, NotFoundError
from dukan.shared.ids import new_id

if TYPE_CHECKING:
    from sqlalchemy.engine import CursorResult

_POLICY = PermissionPolicy()


class SqlCustomerService(CustomerService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def _audit(
        self, action: str, actor_id: str, entity_id: str, after: dict | None = None,
        before: dict | None = None,
    ) -> None:
        self._s.add(
            AuditEntryModel(
                id=new_id(), action=action, actor_id=actor_id, entity_type="customer",
                entity_id=entity_id, before=before, after=after, origin="api",
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
            currency=c.currency, balance_minor=self._balance(c.id), version=c.version,
            is_active=c.is_active,
        )

    def _get(self, customer_id: str, *, lock: bool = False) -> CustomerModel:
        """lock: FOR UPDATE, so two writes that check the balance (payments,
        write-offs, credit sales) take turns instead of both passing."""
        stmt = select(CustomerModel).where(
            CustomerModel.id == customer_id, CustomerModel.deleted_at.is_(None)
        )
        c = self._s.scalar(stmt.with_for_update() if lock else stmt)
        if c is None:
            raise NotFoundError("CUSTOMER_NOT_FOUND", customer_id=customer_id)
        return c

    def create_customer(
        self, *, actor: User, branch_id: str, name: str, phone: str | None,
        credit_limit_minor: int | None,
    ) -> CustomerView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        require_active_branch(self._s, branch_id)
        assert_credit_limit_valid(credit_limit_minor=credit_limit_minor)
        if credit_limit_minor != 0:
            # Any credit (None means unlimited) is a manager's decision.
            require_permission(_POLICY, actor, Permission.CUSTOMER_CREDIT, branch_id)
        c = CustomerModel(
            id=new_id(), name=name, phone=phone, credit_limit_minor=credit_limit_minor,
            created_by=actor.id, updated_by=actor.id,
        )
        self._s.add(c)
        record_change(self._s, "customers", c, op="insert", branch_id=None)
        self._audit(
            "customer.created", actor.id, c.id,
            {"name": name, "credit_limit_minor": credit_limit_minor},
        )
        self._s.commit()
        return self._view(c)

    def _require_reader(self, actor: User, branch_id: str) -> None:
        # Names, phones and debts: for the till, reports and debt collection.
        require_any_permission(
            _POLICY, actor,
            (Permission.SALE_CREATE, Permission.REPORT_VIEW, Permission.DEBT_WRITE_OFF),
            branch_id,
        )

    def list_customers(
        self, *, actor: User, branch_id: str, search: str | None
    ) -> list[CustomerView]:
        self._require_reader(actor, branch_id)
        stmt = select(CustomerModel).where(CustomerModel.deleted_at.is_(None))
        if search:
            like = f"%{search}%"
            stmt = stmt.where(or_(CustomerModel.name.ilike(like), CustomerModel.phone.ilike(like)))
        return [self._view(c) for c in self._s.scalars(stmt.order_by(CustomerModel.name))]

    def get_customer(self, *, actor: User, branch_id: str, customer_id: str) -> CustomerView:
        self._require_reader(actor, branch_id)
        return self._view(self._get(customer_id))

    def set_credit_limit(
        self, *, actor: User, branch_id: str, customer_id: str, credit_limit_minor: int | None,
        version: int,
    ) -> CustomerView:
        """Credit is a manager's decision; a stale version is a conflict, never an
        overwrite."""
        require_permission(_POLICY, actor, Permission.CUSTOMER_CREDIT, branch_id)
        require_active_branch(self._s, branch_id)
        assert_credit_limit_valid(credit_limit_minor=credit_limit_minor)
        customer = self._get(customer_id)
        before = customer.credit_limit_minor
        self._compare_and_set(
            customer, version=version, actor=actor, credit_limit_minor=credit_limit_minor
        )
        self._audit(
            "customer.credit_limit_changed", actor.id, customer_id,
            {"credit_limit_minor": credit_limit_minor}, before={"credit_limit_minor": before},
        )
        self._s.commit()
        return self._view(customer)

    def record_payment(
        self, *, actor: User, branch_id: str, customer_id: str, amount_minor: int,
        method: str = "cash", shift_id: str | None = None,
    ) -> CustomerView:
        require_permission(_POLICY, actor, Permission.SALE_CREATE, branch_id)
        require_active_branch(self._s, branch_id)
        assert_debt_payment_valid(amount_minor=amount_minor)
        assert_payment_valid(method=method, amount_minor=amount_minor)  # cash, card or transfer
        if shift_id is not None:
            # Cash collected at the till counts in that shift's drawer.
            require_open_shift(self._s, shift_id=shift_id, user_id=actor.id, branch_id=branch_id)
        customer = self._get(customer_id, lock=True)
        assert_not_overpaid(balance_minor=self._balance(customer_id), payment_minor=amount_minor)
        entry = CustomerLedgerModel(
            id=new_id(), customer_id=customer_id, type="payment", amount_minor=amount_minor,
            currency=customer.currency, ref_type="manual", method=method, shift_id=shift_id,
            created_by=actor.id,
        )
        self._s.add(entry)
        record_change(self._s, "customer_ledger", entry, op="insert", branch_id=None)
        self._audit(
            "debt.payment_recorded", actor.id, customer_id,
            {"amount": amount_minor, "method": method},
        )
        self._s.commit()
        return self._view(customer)

    def _compare_and_set(
        self, customer: CustomerModel, *, version: int, actor: User, **values: Any
    ) -> None:
        """Update the customer only at `version`: a stale version is a conflict,
        never an overwrite. Logs the new row to the change feed."""
        current_version = customer.version
        done = cast(
            "CursorResult[Any]",
            self._s.execute(
                update(CustomerModel)
                .where(
                    CustomerModel.id == customer.id,
                    CustomerModel.version == version,
                    CustomerModel.deleted_at.is_(None),
                )
                .values(
                    **values, version=CustomerModel.version + 1, updated_by=actor.id,
                    updated_at=datetime.now(UTC),
                )
                .execution_options(synchronize_session=False)
            ),
        )
        if done.rowcount != 1:
            self._s.rollback()
            raise ConflictError(
                "CUSTOMER_VERSION_CONFLICT", base_version=version, current_version=current_version
            )
        self._s.refresh(customer)  # the compare-and-set wrote around the loaded row
        record_change(self._s, "customers", customer, op="update", branch_id=None)

    def set_active(
        self, *, actor: User, branch_id: str, customer_id: str, is_active: bool, version: int
    ) -> CustomerView:
        """Close a customer's account to credit, or reopen it: a manager's decision,
        like credit itself."""
        require_permission(_POLICY, actor, Permission.CUSTOMER_CREDIT, branch_id)
        require_active_branch(self._s, branch_id)
        customer = self._get(customer_id)
        self._compare_and_set(customer, version=version, actor=actor, is_active=is_active)
        self._audit(
            "customer.reactivated" if is_active else "customer.deactivated", actor.id,
            customer_id, {"is_active": is_active},
        )
        self._s.commit()
        return self._view(customer)

    def write_off(
        self, *, actor: User, branch_id: str, customer_id: str, amount_minor: int
    ) -> CustomerView:
        """Forgive part or all of what a customer owes: a negative adjustment on
        the append-only ledger, never more than the balance."""
        require_permission(_POLICY, actor, Permission.DEBT_WRITE_OFF, branch_id)
        require_active_branch(self._s, branch_id)
        customer = self._get(customer_id, lock=True)
        balance = self._balance(customer_id)
        assert_write_off_valid(amount_minor=amount_minor, balance_minor=balance)
        entry = CustomerLedgerModel(
            id=new_id(), customer_id=customer_id, type="adjustment", amount_minor=-amount_minor,
            currency=customer.currency, ref_type="write_off", created_by=actor.id,
        )
        self._s.add(entry)
        record_change(self._s, "customer_ledger", entry, op="insert", branch_id=None)
        self._audit(
            "debt.written_off", actor.id, customer_id, {"amount": amount_minor, "balance": balance}
        )
        self._s.commit()
        return self._view(customer)
