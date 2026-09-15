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
from dataclasses import replace
from datetime import UTC, datetime
from typing import Any, cast

from sqlalchemy import func, select, update
from sqlalchemy.engine import CursorResult
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.orm import Session

from dukan.application.sync import ChangeItem, OpInput, OpResult, PullResult, SyncService
from dukan.application.sync_policy import (
    MASTER_TABLES,
    READ_FIELDS,
    CustomerRef,
    ProductRef,
    PullScope,
    RowSnapshot,
    SaleRef,
    ShiftRef,
    SupplierRef,
    SyncConflict,
    check_envelope,
    clamp_pull_limit,
    is_cacheable,
    is_uuid,
    plan_op,
    role_label,
    scope_fingerprint,
)
from dukan.domain.customers import CustomerLedgerEntry, LedgerEntryType, ledger_balance
from dukan.domain.identity import User
from dukan.infrastructure.change_feed import change_token, post_image, record_change
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
    ShiftModel,
    StockMovementModel,
    SupplierLedgerModel,
    SupplierModel,
    UnitModel,
)
from dukan.infrastructure.shift_cash import expected_cash
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
    "shifts": ShiftModel,
}


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
        unit = self._s.get(UnitModel, p.unit_id)
        return ProductRef(
            id=p.id, deleted=p.deleted_at is not None, track_stock=p.track_stock,
            sell_price_minor=p.sell_price_minor, cost_minor=p.cost_minor,
            decimal_places=unit.decimal_places if unit is not None else None,
        )

    def barcode_taken(self, code: str) -> bool:
        return self._s.scalar(
            select(BarcodeModel.id)
            .where(BarcodeModel.code == code, BarcodeModel.deleted_at.is_(None))
            .limit(1)
        ) is not None

    def sku_taken(self, sku: str) -> bool:
        return self._s.scalar(
            select(ProductModel.id)
            .where(ProductModel.sku == sku, ProductModel.deleted_at.is_(None))
            .limit(1)
        ) is not None

    def supplier_balance(self, supplier_id: str) -> int:
        # As dukan.domain.purchasing.supplier_balance: bills add, payments subtract.
        rows = self._s.execute(
            select(SupplierLedgerModel.type, SupplierLedgerModel.amount_minor).where(
                SupplierLedgerModel.supplier_id == supplier_id,
                SupplierLedgerModel.deleted_at.is_(None),
            )
        ).tuples()
        return sum(-amount if kind == "payment" else amount for kind, amount in rows)

    def shift(self, shift_id: str) -> ShiftRef | None:
        s = self._s.get(ShiftModel, shift_id)
        if s is None or s.deleted_at is not None:
            return None
        return ShiftRef(id=s.id, branch_id=s.branch_id, user_id=s.user_id, status=s.status)

    def open_shifts(self, user_id: str, branch_id: str) -> list[str]:
        return list(self._s.scalars(
            select(ShiftModel.id).where(
                ShiftModel.user_id == user_id, ShiftModel.branch_id == branch_id,
                ShiftModel.status == "open", ShiftModel.deleted_at.is_(None),
            )
        ).all())

    def shift_expected_cash(self, shift_id: str) -> int:
        return expected_cash(self._s, shift_id)

    def shop_currencies(self) -> frozenset[str]:
        return frozenset(
            self._s.scalars(
                select(BranchModel.currency_default).where(BranchModel.deleted_at.is_(None))
            )
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
            credit_limit_minor=c.credit_limit_minor, is_active=c.is_active,
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
            paid_minor=s.paid_minor, occurred_at=_aware(s.occurred_at),
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

    def sale_number_taken(self, branch_id: str, number: str) -> bool:
        return self._s.scalar(
            select(SaleModel.id).where(
                SaleModel.branch_id == branch_id, SaleModel.number == number,
                SaleModel.deleted_at.is_(None),
            ).limit(1)
        ) is not None

    def recent_sell_prices(self, product_id: str, since: datetime) -> frozenset[int]:
        """The price now and both sides of every price change since `since`, from
        the audit trail (REST records `price_minor`, sync `sell_price_minor`)."""
        p = self._s.get(ProductModel, product_id)
        prices: set[int] = {p.sell_price_minor} if p is not None else set()
        changes = self._s.execute(
            select(AuditEntryModel.before, AuditEntryModel.after).where(
                AuditEntryModel.action == "product.price_changed",
                AuditEntryModel.entity_id == product_id,
                AuditEntryModel.occurred_at >= since,
            )
        ).tuples()
        for image in (image for pair in changes for image in pair):
            for key in ("sell_price_minor", "price_minor"):
                value = (image or {}).get(key)
                if type(value) is int:
                    prices.add(value)
        return frozenset(prices)


def _aware(at: datetime) -> datetime:
    """SQLite hands back naive UTC datetimes."""
    return at if at.tzinfo is not None else at.replace(tzinfo=UTC)


def _breaks_chain(op: OpInput, result: OpResult) -> bool:
    """Whether later ops on the row were made on top of one the server did not take.
    Two cases break the chain: an edit that lost its compare-and-set (the device's
    local versions now collide with the server's, so a later edit's base_version can
    match by accident), and an insert refused for good (the row never existed).
    Other refusals leave the server's version where the device's next edit will
    conflict on its own."""
    if result.outcome == "conflict":
        return op.op == "update" and (result.code or "").endswith("_VERSION_CONFLICT")
    return result.outcome == "rejected" and op.op == "insert"


class SqlSyncService(SyncService):
    def __init__(self, session: Session) -> None:
        self._s = session
        self._reader = _SqlSyncReader(session)

    # ---- push -------------------------------------------------------------
    def push(
        self, *, actor: User, device_id: str, branch_id: str | None, ops: list[OpInput]
    ) -> list[OpResult]:
        results: list[OpResult] = []
        # Rows where an earlier op in this push broke the device's chain (see
        # _breaks_chain). A later op on such a row was made on top of it: it takes the
        # same verdict, or it would overwrite the server's row without review. The
        # device does the same across pushes.
        failed: dict[tuple[str, str], OpResult] = {}
        for op in ops:
            row = (op.table, op.row_id)
            earlier = failed.get(row)
            fresh = is_uuid(op.op_id) and self._s.get(ProcessedOpModel, op.op_id) is None
            if earlier is not None and earlier.code is not None and fresh:
                result = self._settle(op, actor, device_id, earlier.outcome, earlier.code)
                if result.outcome == "conflict":
                    result = replace(result, current=self._current(actor, op))
            else:
                result = self._push_one(actor, device_id, branch_id, op)
            if result.code and is_cacheable(result.code) and _breaks_chain(op, result):
                failed[row] = result
            results.append(result)
        return results

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
                return self._replay(prior, actor, op)
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
                seq, version = self._apply(actor, device_id, branch_id, op)
                self._s.add(
                    ProcessedOpModel(
                        op_id=op.op_id, result="applied", server_seq=seq, version=version,
                        actor_id=actor.id, device_id=device_id,
                    )
                )
                self._s.commit()
                return OpResult(
                    op_id=op.op_id, outcome="applied", server_seq=seq, version=version
                )
            except SyncConflict as e:
                self._s.rollback()
                settled = self._settle(op, actor, device_id, "conflict", e.code)
                return replace(settled, current=self._current(actor, op))
            except AppError as e:
                self._s.rollback()
                return self._settle(op, actor, device_id, "rejected", e.code)
            except IntegrityError:
                # A concurrent push of the same op_id or row_id won the race: replay
                # its recorded result, or re-plan once against the committed row.
                self._s.rollback()
                prior = self._s.get(ProcessedOpModel, op.op_id)
                if prior is not None:
                    return self._replay(prior, actor, op)
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

    def _replay(self, prior: ProcessedOpModel, actor: User, op: OpInput) -> OpResult:
        result = OpResult(
            op_id=prior.op_id, outcome=prior.result, server_seq=prior.server_seq, code=prior.code,
            version=prior.version,
        )
        if prior.result == "conflict":
            return replace(result, current=self._current(actor, op))
        return result

    def _current(self, actor: User, op: OpInput) -> dict[str, Any] | None:
        """The server's row for a conflicted master op, as this user may read it: the
        device replaces its losing local copy with it."""
        if op.table not in MASTER_TABLES:
            return None
        row = self._s.get(_MODELS[op.table], op.row_id)
        if row is None or row.deleted_at is not None:
            return None
        return PullScope.for_actor(actor).view(op.table, None, post_image(op.table, row))

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
                    return self._replay(prior, actor, op)
            except OperationalError as e:
                self._s.rollback()
                raise InfrastructureError("SYNC_UNAVAILABLE") from e
        return OpResult(op_id=op.op_id, outcome=outcome, code=code)

    def _apply(
        self, actor: User, device_id: str, branch_id: str | None, op: OpInput
    ) -> tuple[int | None, int | None]:
        """Writes the op; returns its change_log seq and, for a master row, its new
        version. An op whose intent already holds writes nothing and has no seq."""
        check_envelope(op, actor)
        model = _MODELS[op.table]
        now = datetime.now(UTC)
        plan = plan_op(
            op, actor=actor, active_branch=branch_id,
            existing=_snapshot(op.table, self._s.get(model, op.row_id)),
            reader=self._reader, now=now,
        )
        if plan.noop:
            done = self._s.get(model, op.row_id)
            return None, (done.version if done is not None else None)
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
        seq = record_change(self._s, op.table, row, op=op.op, branch_id=plan.row_branch_id)
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
        return seq, (row.version if op.table in MASTER_TABLES else None)

    # ---- pull -------------------------------------------------------------
    def pull(
        self, *, actor: User, since: int, limit: int, since_token: str | None = None
    ) -> PullResult:
        scope = PullScope.for_actor(actor)
        if scope.is_empty:
            raise PermissionDeniedError("ACCESS_DENIED", actor_id=actor.id, scope="sync.pull")
        fingerprint = scope_fingerprint(actor)
        max_seq = int(self._s.scalar(select(func.max(ChangeLogModel.seq))) or 0)
        if since > 0 and since_token is not None:
            at = self._s.get(ChangeLogModel, since)
            if at is None or change_token(at) != since_token:
                # The feed no longer holds the change this device read last: the
                # server was restored from a backup. The device reads it again.
                return PullResult(
                    changes=[], watermark=0, max_seq=max_seq, scope=fingerprint, reset=True
                )
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
        last = rows[-1] if rows else (self._s.get(ChangeLogModel, since) if since > 0 else None)
        return PullResult(
            changes=changes, watermark=rows[-1].seq if rows else since, max_seq=max_seq,
            watermark_token=change_token(last) if last is not None else None, scope=fingerprint,
        )
