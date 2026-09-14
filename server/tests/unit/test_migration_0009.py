"""Migration 0009 gives every branch an owner and the shop's owners every branch:
before it, an owner of the shop's first branch acted in every branch."""

from __future__ import annotations

import importlib.util
from datetime import UTC, datetime, timedelta
from pathlib import Path
from types import ModuleType

from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

from dukan.infrastructure.db.base import Base
from dukan.infrastructure.db.models import BranchAssignmentModel, BranchModel, UserModel

T0 = datetime(2026, 1, 1, tzinfo=UTC)


def _migration() -> ModuleType:
    path = Path(__file__).resolve().parents[2] / "migrations/versions/0009_authz_scope.py"
    spec = importlib.util.spec_from_file_location("migration_0009", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _backfill(
    tmp_path: Path,
    *,
    users: dict[str, str],
    branches: list[tuple[str, str]],
    roles: list[tuple[str, str, str]],
) -> list[tuple[str, str, str]]:
    """users: id -> status; branches: (id, creator), oldest first; roles: (user,
    branch, role). Runs the back-fill twice and returns the live assignments."""
    engine = create_engine(f"sqlite:///{tmp_path / 'm.db'}")
    Base.metadata.create_all(engine)
    with Session(engine) as s:
        for uid, status in users.items():
            s.add(UserModel(
                id=uid, username=uid, display_name=uid, password_hash="x", status=status,
            ))
        for i, (bid, creator) in enumerate(branches):
            s.add(BranchModel(
                id=bid, name=bid, timezone="Asia/Kabul", currency_default="AFN",
                is_active=True, created_by=creator, created_at=T0 + timedelta(days=i),
            ))
        for uid, bid, role in roles:
            s.add(BranchAssignmentModel(
                id=f"{uid}-{bid}", user_id=uid, branch_id=bid, role_name=role,
            ))
        s.commit()
    for _ in range(2):  # a second run changes nothing
        with engine.begin() as conn:
            _migration()._backfill_branch_owners(conn)
    with Session(engine) as s:
        rows = s.scalars(
            select(BranchAssignmentModel).where(BranchAssignmentModel.deleted_at.is_(None))
        )
        return sorted((r.user_id, r.branch_id, r.role_name) for r in rows)


def test_the_first_branchs_owners_own_every_branch(tmp_path: Path) -> None:
    # O opened B2-B4 before 0009, so nobody was given them; O made X owner of B2
    # and was a manager in B3. D, now disabled, opened B4.
    got = _backfill(
        tmp_path,
        users={"O": "active", "X": "active", "D": "disabled"},
        branches=[("B1", "O"), ("B2", "O"), ("B3", "O"), ("B4", "D")],
        roles=[("O", "B1", "owner"), ("X", "B2", "owner"), ("O", "B3", "manager")],
    )
    assert got == [
        ("O", "B1", "owner"), ("O", "B2", "owner"), ("O", "B3", "owner"), ("O", "B4", "owner"),
        ("X", "B2", "owner"),
    ]


def test_without_an_owner_of_the_first_branch_every_owner_owns_all(tmp_path: Path) -> None:
    got = _backfill(
        tmp_path,
        users={"D": "disabled", "X": "active", "C": "active"},
        branches=[("B1", "D"), ("B2", "X")],
        roles=[("D", "B1", "owner"), ("X", "B2", "owner"), ("C", "B1", "cashier")],
    )
    assert got == [
        ("C", "B1", "cashier"), ("D", "B1", "owner"), ("X", "B1", "owner"), ("X", "B2", "owner"),
    ]
