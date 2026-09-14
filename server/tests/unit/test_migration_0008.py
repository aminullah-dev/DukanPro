"""Migration 0008 back-fills change_log.branch_id for feed rows logged before it,
because pull hides a branch row whose branch it cannot tell."""

from __future__ import annotations

import importlib.util
from pathlib import Path
from types import ModuleType

from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

from dukan.infrastructure.db.base import Base
from dukan.infrastructure.db.models import ChangeLogModel, SaleModel

B1, B2 = "0190f0e0-0000-7000-8000-0000000000b1", "0190f0e0-0000-7000-8000-0000000000b2"
SALE = "0190f0e0-0000-7000-8000-0000000000a1"


def _migration() -> ModuleType:
    path = Path(__file__).resolve().parents[2] / "migrations/versions/0008_sync_hardening.py"
    spec = importlib.util.spec_from_file_location("migration_0008", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_backfill_gives_old_feed_rows_their_branch(tmp_path: Path) -> None:
    engine = create_engine(f"sqlite:///{tmp_path / 'm.db'}")
    Base.metadata.create_all(engine)
    with Session(engine) as s:
        s.add(SaleModel(
            id=SALE, number="INV-1", branch_id=B2, shift_id=None, customer_id=None,
            status="settled", currency="AFN", discount_minor=0, subtotal_minor=0, tax_minor=0,
            total_minor=0, paid_minor=0, change_minor=0,
        ))
        old_rows = {
            "sales": {"branch_id": B2},
            "stock_movements": {"branch_id": B1},
            "sale_lines": {"sale_id": SALE},
            "payments": {"sale_id": SALE},
            "products": {"sku": "A"},
        }
        for table, data in old_rows.items():
            s.add(ChangeLogModel(table_name=table, row_id=table, op="insert", data=data))
        s.add(ChangeLogModel(table_name="payments", row_id="orphan", op="insert",
                             data={"sale_id": "gone"}))
        s.commit()

    with engine.begin() as conn:
        _migration()._backfill_branch_ids(conn)

    with Session(engine) as s:
        got = {r.row_id: r.branch_id for r in s.scalars(select(ChangeLogModel))}
    assert got == {
        "sales": B2, "stock_movements": B1, "sale_lines": B2, "payments": B2,
        "products": None, "orphan": None,
    }
