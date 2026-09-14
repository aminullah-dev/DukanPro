"""Concrete SyncService bound to a SQLAlchemy session.

Each op is its own transaction: the application SyncPolicy validates and
authorizes it (dukan.application.sync_policy), then this service writes the row,
its change_log post-image, one audit entry and the processed_ops record, and
commits. Master rows are updated with an atomic compare-and-set on `version`.
The server does not re-run domain side effects on push (the client already
applied them), so nothing double-counts.
"""

from __future__ import annotations

import logging
from datetime import UTC, datetime
from typing import Any, cast

from sqlalchemy import func, select, update
from sqlalchemy.engine import CursorResult
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.orm import Session

from dukan.application.sync import ChangeItem, OpInput, OpResult, PullResult, SyncService
from dukan.application.sync_policy import (
    READ_FIELDS,
    CustomerRef,
    ProductRef,
    PullScope,
    RowSnapshot,
    SaleRef,
    SupplierRef,
    SyncConflict,
    check_envelope,
    clamp_pull_limit,
    is_cacheable,
    is_uuid,
    plan_op,
    role_label,
)
from dukan.domain.customers import CustomerLedgerEntry, LedgerEntryType, ledger_balance
from dukan.domain.identity import User
from dukan.infrastructure.db.models import (
    AuditEntryModel,
    BarcodeModel,
    BranchModel,
    CategoryModel,
    ChangeLogModel,
    CustomerLedgerModel,
    CustomerModel,
    PaymentModel,
    ProcessedOpModel,
    ProductModel,
    SaleLineModel,
    SaleModel,
    StockMovementModel,
    SupplierLedgerModel,
    SupplierModel,
    UnitModel,
)
from dukan.shared.errors import AppError, InfrastructureError, PermissionDeniedError
from dukan.shared.ids import new_id

_log = logging.getLogger(__name__)

_MODELS: dict[str, type[Any]] = {
    "products": ProductModel,
    "barcodes": BarcodeModel,
    "customers": CustomerModel,
    "suppliers": SupplierModel,
    "units": UnitModel,
    "categories": CategoryModel,
    "stock_movements": StockMovementModel,
    "sale_lines": SaleLineModel,
    "payments": PaymentModel,
    "sales": SaleModel,
    "customer_ledger": CustomerLedgerModel,
    "supplier_ledger": SupplierLedgerModel,
}


def _jsonable(value: Any) -> Any:
    return value.isoformat() if isinstance(value, datetime) else value


def _snapshot(table: str, row: Any) -> RowSnapshot | None:
    if row is None:
        return None
    return RowSnapshot(
        version=row.version,
        deleted=row.deleted_at is not None,
        values={k: getattr(row, k) for k in READ_FIELDS[table] if k != "version"},
    )


class _SqlSyncReader:
    """SyncReader over the op's own session. Earlier ops of the same batch are
    already committed, so a sale header pushed before its lines is visible."""

    def __init__(self, session: Session) -> None:
        self._s = session

    def _sum(self, column: Any, *where: Any) -> int:
        return int(self._s.scalar(select(func.coalesce(func.sum(column), 0)).where(*where)) or 0)

    def product(self, product_id: str) -> ProductRef | None:
        p = self._s.get(ProductModel, product_id)
        if p is None:
            return None
        return ProductRef(
            id=p.id, deleted=p.deleted_at is not None, track_stock=p.track_stock,
            sell_price_minor=p.sell_price_minor, cost_minor=p.cost_minor,
        )

    def unit_exists(self, unit_id: str) -> bool:
        u = self._s.get(UnitModel, unit_id)
        return u is not None and u.deleted_at is None

    def customer(self, customer_id: str) -> CustomerRef | None:
        c = self._s.get(CustomerModel, customer_id)
        if c is None:
            return None
        return CustomerRef(
            id=c.id, deleted=c.deleted_at is not None, currency=c.currency,
            credit_limit_minor=c.credit_limit_minor,
        )

    def customer_balance(self, customer_id: str) -> int:
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

    def supplier(self, supplier_id: str) -> SupplierRef | None:
        s = self._s.get(SupplierModel, supplier_id)
        if s is None:
            return None
        return SupplierRef(id=s.id, deleted=s.deleted_at is not None, currency=s.currency)

    def sale(self, sale_id: str) -> SaleRef | None:
        # FOR UPDATE (PostgreSQL) serializes children of one sale, so the running
        # totals below cannot be raced; SQLite serializes writers anyway.
        s = self._s.scalar(
            select(SaleModel)
            .where(SaleModel.id == sale_id, SaleModel.deleted_at.is_(None))
            .with_for_update()
        )
        if s is None:
            return None
        return SaleRef(
            id=s.id, branch_id=s.branch_id, created_by=s.created_by, customer_id=s.customer_id,
            currency=s.currency, subtotal_minor=s.subtotal_minor, total_minor=s.total_minor,
            paid_minor=s.paid_minor,
        )

    def sale_lines_total(self, sale_id: str) -> int:
        return self._sum(
            SaleLineModel.line_total_minor,
            SaleLineModel.sale_id == sale_id, SaleLineModel.deleted_at.is_(None),
        )

    def sale_line_qty(self, sale_id: str, product_id: str) -> int:
        return self._sum(
            SaleLineModel.qty_minor,
            SaleLineModel.sale_id == sale_id, SaleLineModel.product_id == product_id,
            SaleLineModel.deleted_at.is_(None),
        )

    def sale_stock_out_qty(self, sale_id: str, product_id: str) -> int:
        return -self._sum(
            StockMovementModel.qty_delta,
            StockMovementModel.reason == "sale", StockMovementModel.ref_type == "sale",
            StockMovementModel.ref_id == sale_id, StockMovementModel.product_id == product_id,
            StockMovementModel.deleted_at.is_(None),
        )

    def sale_payments_total(self, sale_id: str) -> int:
        return self._sum(
            PaymentModel.amount_minor,
            PaymentModel.sale_id == sale_id, PaymentModel.deleted_at.is_(None),
        )

    def sale_charges_total(self, sale_id: str) -> int:
        return self._sum(
            CustomerLedgerModel.amount_minor,
            CustomerLedgerModel.type == "charge", CustomerLedgerModel.ref_type == "sale",
            CustomerLedgerModel.ref_id == sale_id, CustomerLedgerModel.deleted_at.is_(None),
        )

    def branch_active(self, branch_id: str) -> bool:
        b = self._s.get(BranchModel, branch_id)
        return b is not None and b.deleted_at is None and b.is_active


class SqlSyncService(SyncService):
    def __init__(self, session: Session) -> None:
        self._s = session
        self._reader = _SqlSyncReader(session)

    # ---- push -------------------------------------------------------------
    def push(
        self, *, actor: User, device_id: str, branch_id: str | None, ops: list[OpInput]
    ) -> list[OpResult]:
        return [self._push_one(actor, device_id, branch_id, op) for op in ops]

    def _push_one(
        self, actor: User, device_id: str, branch_id: str | None, op: OpInput
    ) -> OpResult:
        if not is_uuid(op.op_id):
            # Cannot be recorded (processed_ops.op_id is the idempotency key); reject
            # this op alone and keep going.
            return OpResult(op_id=op.op_id, outcome="rejected", code="SYNC_OP_INVALID")
        prior = self._s.get(ProcessedOpModel, op.op_id)
        if prior is not None:
            if prior.actor_id in (None, actor.id):
                return self._replay(prior)
            if prior.result == "applied":
                # The op_id is spent on another user's write: this op can never apply.
                return OpResult(op_id=op.op_id, outcome="rejected", code="SYNC_OP_ID_TAKEN")
            # Another user's failed attempt under this op_id wrote nothing and must not
            # decide this user's op: forget it and decide the op on its own merits.
            _log.warning(
                "sync op %s: discarding %s's recorded %s", op.op_id, prior.actor_id, prior.result
            )
            try:
                self._s.delete(prior)
                self._s.commit()
            except OperationalError as e:
                self._s.rollback()
                raise InfrastructureError("SYNC_UNAVAILABLE") from e
        for attempt in (1, 2):
            try:
                seq = self._apply(actor, device_id, branch_id, op)
                self._s.add(
                    ProcessedOpModel(
                        op_id=op.op_id, result="applied", server_seq=seq, actor_id=actor.id,
                        device_id=device_id,
                    )
                )
                self._s.commit()
                return OpResult(op_id=op.op_id, outcome="applied", server_seq=seq)
            except SyncConflict as e:
                self._s.rollback()
                return self._settle(op, actor, device_id, "conflict", e.code)
            except AppError as e:
                self._s.rollback()
                return self._settle(op, actor, device_id, "rejected", e.code)
            except IntegrityError:
                # A concurrent push of the same op_id or row_id won the race: replay
                # its recorded result, or re-plan once against the committed row.
                self._s.rollback()
                prior = self._s.get(ProcessedOpModel, op.op_id)
                if prior is not None:
                    return self._replay(prior)
                if attempt == 2:
                    break
            except OperationalError as e:
                self._s.rollback()
                raise InfrastructureError("SYNC_UNAVAILABLE") from e
            except Exception:  # noqa: BLE001 - a bad row must not 500 the batch
                self._s.rollback()
                _log.exception("sync op %s on %s failed unexpectedly", op.op_id, op.table)
                break
        return OpResult(op_id=op.op_id, outcome="rejected", code="ROW_INVALID")

    def _replay(self, prior: ProcessedOpModel) -> OpResult:
        return OpResult(
            op_id=prior.op_id, outcome=prior.result, server_seq=prior.server_seq, code=prior.code
        )

    def _settle(
        self, op: OpInput, actor: User, device_id: str, outcome: str, code: str
    ) -> OpResult:
        _log.info("sync op %s (%s/%s) %s: %s", op.op_id, op.table, op.op, outcome, code)
        if is_cacheable(code):
            self._s.add(
                ProcessedOpModel(
                    op_id=op.op_id, result=outcome, code=code, actor_id=actor.id,
                    device_id=device_id,
                )
            )
            try:
                self._s.commit()
            except IntegrityError:
                self._s.rollback()
                prior = self._s.get(ProcessedOpModel, op.op_id)
                if prior is not None:
                    return self._replay(prior)
            except OperationalError as e:
                self._s.rollback()
                raise InfrastructureError("SYNC_UNAVAILABLE") from e
        return OpResult(op_id=op.op_id, outcome=outcome, code=code)

    def _apply(self, actor: User, device_id: str, branch_id: str | None, op: OpInput) -> int:
        check_envelope(op, actor)
        model = _MODELS[op.table]
        now = datetime.now(UTC)
        plan = plan_op(
            op, actor=actor, active_branch=branch_id,
            existing=_snapshot(op.table, self._s.get(model, op.row_id)),
            reader=self._reader, now=now,
        )
        if op.op == "insert":
            row = model(id=op.row_id, created_by=actor.id, updated_by=actor.id, **plan.values)
            self._s.add(row)
            self._s.flush()
        else:
            # Atomic compare-and-set: the write happens only if nobody moved the
            # version since the client read it (and since plan_op checked it).
            result = cast(
                "CursorResult[Any]",
                self._s.execute(
                    update(model)
                    .where(
                        model.id == op.row_id,
                        model.version == op.base_version,
                        model.deleted_at.is_(None),
                    )
                    .values(
                        **plan.values, version=model.version + 1, updated_by=actor.id,
                        updated_at=now,
                    )
                    .execution_options(synchronize_session=False)
                ),
            )
            if result.rowcount != 1:
                raise SyncConflict(
                    f"{op.table.upper()}_VERSION_CONFLICT", base_version=op.base_version
                )
            row = self._s.get(model, op.row_id, populate_existing=True)
        image = {k: _jsonable(getattr(row, k)) for k in READ_FIELDS[op.table]}
        entry = ChangeLogModel(
            table_name=op.table, row_id=op.row_id, op=op.op, data=image,
            branch_id=plan.row_branch_id,
        )
        self._s.add(entry)
        self._s.flush()
        self._s.add(
            AuditEntryModel(
                id=new_id(),
                actor_id=actor.id,
                actor_role=role_label(actor, plan.auth_branch_id),
                action=plan.audit.action,
                entity_type=plan.audit.entity_type,
                entity_id=op.row_id,
                before=plan.audit.before,
                after={
                    **plan.audit.after,
                    "_sync": {
                        "op_id": op.op_id,
                        "device_id": device_id,
                        "branch_id": plan.auth_branch_id,
                        "recorded_by": op.actor_id,
                        "recorded_at": op.created_at,
                    },
                },
                origin="sync",
            )
        )
        return entry.seq

    # ---- pull -------------------------------------------------------------
    def pull(self, *, actor: User, since: int, limit: int) -> PullResult:
        scope = PullScope.for_actor(actor)
        if scope.is_empty:
            raise PermissionDeniedError("ACCESS_DENIED", actor_id=actor.id, scope="sync.pull")
        rows = self._s.scalars(
            select(ChangeLogModel)
            .where(ChangeLogModel.seq > max(since, 0))
            .order_by(ChangeLogModel.seq)
            .limit(clamp_pull_limit(limit))
        ).all()
        changes: list[ChangeItem] = []
        for r in rows:
            data = scope.view(r.table_name, r.branch_id, dict(r.data))
            if data is not None:
                changes.append(
                    ChangeItem(seq=r.seq, table=r.table_name, row_id=r.row_id, op=r.op, data=data)
                )
        # The watermark advances past rows this actor may not see, so paging stays
        # monotonic and a scoped reader never re-scans them.
        return PullResult(changes=changes, watermark=rows[-1].seq if rows else since)
