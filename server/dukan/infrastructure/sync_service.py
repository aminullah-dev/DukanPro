"""Concrete SyncService bound to a SQLAlchemy session.

Generic row-level apply over a table→model map. Append-only tables insert
if-absent (never conflict); master tables upsert with an optimistic version.
The server does not re-run domain side-effects on push — the client already
applied them optimistically — so nothing double-counts.
"""

from __future__ import annotations

from datetime import datetime
from typing import Any

from sqlalchemy import DateTime, select
from sqlalchemy.orm import Session

from dukan.application.sync import ChangeItem, OpInput, OpResult, PullResult, SyncService
from dukan.domain.identity import User
from dukan.infrastructure.db.models import (
    BarcodeModel,
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
from dukan.shared.errors import AppError

_MASTER = {"products", "barcodes", "customers", "suppliers", "units", "categories"}

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

_SKIP = object()


class SqlSyncService(SyncService):
    def __init__(self, session: Session) -> None:
        self._s = session

    def push(self, *, actor: User, device_id: str, ops: list[OpInput]) -> list[OpResult]:
        results: list[OpResult] = []
        for op in ops:
            prior = self._s.get(ProcessedOpModel, op.op_id)
            if prior is not None:
                results.append(OpResult(op_id=op.op_id, outcome=prior.result))
                continue
            try:
                outcome, seq, code = self._apply(op, actor)
            except AppError as e:
                self._s.rollback()
                outcome, seq, code = "rejected", None, e.code
            except Exception:  # noqa: BLE001 - a bad row must not 500 the batch
                self._s.rollback()
                outcome, seq, code = "rejected", None, "ROW_INVALID"
            self._s.add(ProcessedOpModel(op_id=op.op_id, result=outcome))
            self._s.commit()
            results.append(OpResult(op_id=op.op_id, outcome=outcome, server_seq=seq, code=code))
        return results

    def pull(self, *, since: int, limit: int) -> PullResult:
        rows = self._s.scalars(
            select(ChangeLogModel)
            .where(ChangeLogModel.seq > since)
            .order_by(ChangeLogModel.seq)
            .limit(limit)
        ).all()
        changes = [
            ChangeItem(seq=r.seq, table=r.table_name, row_id=r.row_id, op=r.op, data=dict(r.data))
            for r in rows
        ]
        return PullResult(changes=changes, watermark=changes[-1].seq if changes else since)

    # ---- apply ------------------------------------------------------------
    def _apply(self, op: OpInput, actor: User) -> tuple[str, int | None, str | None]:
        model = _MODELS.get(op.table)
        if model is None:
            return ("rejected", None, "UNKNOWN_TABLE")
        existing = self._s.get(model, op.row_id)
        if op.table not in _MASTER:  # append-only
            if existing is None:
                self._insert(model, op, actor)
                return ("applied", self._log(op), None)
            return ("applied", None, None)  # idempotent no-op
        # master
        if existing is None:
            self._insert(model, op, actor, version=1)
            return ("applied", self._log(op), None)
        if (
            op.op == "update"
            and op.base_version is not None
            and existing.version != op.base_version
        ):
            return ("conflict", None, f"{op.table.upper()}_VERSION_CONFLICT")
        self._merge(existing, model, op, actor)
        return ("applied", self._log(op), None)

    def _coerce(self, model: type[Any], key: str, value: Any) -> Any:
        col = model.__table__.columns.get(key)
        if col is None:
            return _SKIP
        if isinstance(col.type, DateTime) and isinstance(value, str):
            return datetime.fromisoformat(value)
        return value

    def _row_kwargs(self, model: type[Any], data: dict[str, Any]) -> dict[str, Any]:
        out: dict[str, Any] = {}
        for k, v in data.items():
            cv = self._coerce(model, k, v)
            if cv is not _SKIP:
                out[k] = cv
        return out

    def _insert(
        self, model: type[Any], op: OpInput, actor: User, version: int | None = None
    ) -> None:
        kwargs = self._row_kwargs(model, op.data)
        kwargs["id"] = op.row_id
        kwargs.setdefault("created_by", actor.id)
        kwargs.setdefault("updated_by", actor.id)
        if version is not None:
            kwargs["version"] = version
        self._s.add(model(**kwargs))

    def _merge(self, existing: Any, model: type[Any], op: OpInput, actor: User) -> None:
        for k, v in self._row_kwargs(model, op.data).items():
            setattr(existing, k, v)
        existing.updated_by = actor.id
        existing.version = existing.version + 1

    def _log(self, op: OpInput) -> int:
        entry = ChangeLogModel(table_name=op.table, row_id=op.row_id, op=op.op, data=op.data)
        self._s.add(entry)
        self._s.flush()
        return entry.seq
