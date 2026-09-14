"""Pure sync policy rules (no DB): field cleaning, envelope, caching, pull scope."""

from __future__ import annotations

from collections.abc import Callable

import pytest

from dukan.application.sync import OpInput
from dukan.application.sync_policy import (
    _HANDLERS,
    _INSERT,
    _UPDATE,
    PullScope,
    check_envelope,
    clamp_pull_limit,
    clean_fields,
    is_cacheable,
    role_label,
)
from dukan.domain.identity import BranchAssignment, User, UserStatus
from dukan.shared.errors import AppError

U = "0190f0e0-0000-7000-8000-000000000000"
B1, B2 = "0190f0e0-0000-7000-8000-0000000000b1", "0190f0e0-0000-7000-8000-0000000000b2"


def _user(*assignments: tuple[str, str], active: bool = True) -> User:
    return User(
        id="u1", username="u", display_name="U",
        status=UserStatus.ACTIVE if active else UserStatus.DISABLED,
        assignments=tuple(BranchAssignment(b, r) for b, r in assignments),
        default_branch_id=assignments[0][0] if assignments else None,
    )


def _code(fn: Callable[[], object]) -> str:
    with pytest.raises(AppError) as e:
        fn()
    return e.value.code


def _movement(**over: object) -> dict[str, object]:
    return {"product_id": U, "branch_id": U, "qty_delta": 1, "reason": "purchase", **over}


@pytest.mark.parametrize("value", [True, 1.0, "1", None, 2**31, -(2**31) - 1])
def test_int_fields_are_strict(value: object) -> None:
    code = _code(lambda: clean_fields("stock_movements", "insert", _movement(qty_delta=value)))
    assert code == "SYNC_FIELD_INVALID"


@pytest.mark.parametrize("value", [2**31 - 1, -(2**31)])
def test_int_bounds_are_inclusive(value: int) -> None:
    assert clean_fields("stock_movements", "insert", _movement(qty_delta=value))["qty_delta"] == value


@pytest.mark.parametrize("value", [U + "\n", U.upper(), "{" + U + "}", U[:-1], 7])
def test_uuids_must_be_canonical(value: object) -> None:
    code = _code(lambda: clean_fields("stock_movements", "insert", _movement(product_id=value)))
    assert code == "SYNC_FIELD_INVALID"


def test_bools_are_strict_and_currency_is_iso() -> None:
    base = {"sku": "A", "name": "Tea", "unit_id": U}
    assert _code(lambda: clean_fields("products", "insert", {**base, "is_active": 1})) == (
        "SYNC_FIELD_INVALID"
    )
    for bad in ("afn", "AF", "AFNX", "123"):
        code = _code(lambda bad=bad: clean_fields("products", "insert", {**base, "sell_currency": bad}))
        assert code == "MONEY_CURRENCY_INVALID"


def test_server_owned_keys_are_named_as_such() -> None:
    with pytest.raises(AppError) as e:
        clean_fields("products", "update", {"version": 3})
    assert e.value.code == "SYNC_FIELD_NOT_ALLOWED" and e.value.context["reason"] == "server_owned"


def test_every_allow_listed_op_has_exactly_one_handler() -> None:
    specs = {(t, "insert") for t in _INSERT} | {(t, "update") for t in _UPDATE}
    assert set(_HANDLERS) == specs


def _op(**over: object) -> OpInput:
    base: dict[str, object] = {
        "op_id": U, "table": "products", "row_id": U, "op": "update", "data": {"name": "x"},
        "base_version": 1,
    }
    base.update(over)
    return OpInput(**base)  # type: ignore[arg-type]


def test_envelope_rules() -> None:
    actor = _user((B1, "owner"))
    check_envelope(_op(), actor)
    check_envelope(_op(actor_id="u1", created_at="2026-09-12T08:00:00.123456Z"), actor)
    assert _code(lambda: check_envelope(_op(base_version=None), actor)) == (
        "SYNC_BASE_VERSION_REQUIRED"
    )
    assert _code(lambda: check_envelope(_op(base_version=-1), actor)) == "SYNC_OP_INVALID"
    check_envelope(_op(base_version=0), actor)  # a stale read, decided as a conflict
    assert _code(lambda: check_envelope(_op(op="delete"), actor)) == "SYNC_OP_INVALID"
    assert _code(lambda: check_envelope(_op(table="users"), actor)) == "UNKNOWN_TABLE"
    assert _code(lambda: check_envelope(_op(table="sales"), actor)) == "SYNC_OP_UNSUPPORTED"
    assert _code(lambda: check_envelope(_op(actor_id="other"), actor)) == "SYNC_ACTOR_MISMATCH"
    naive = _op(created_at="2026-09-12T08:00:00")
    assert _code(lambda: check_envelope(naive, actor)) == "SYNC_OP_INVALID"


def test_only_state_independent_outcomes_are_cached() -> None:
    for code in ("SYNC_FIELD_INVALID", "PRODUCTS_VERSION_CONFLICT", "SYNC_ROW_EXISTS",
                 "STOCK_INVALID_QTY", "SYNC_REF_MISMATCH"):
        assert is_cacheable(code), code
    for code in ("ACCESS_DENIED", "SYNC_ACTOR_MISMATCH", "BRANCH_REQUIRED", "SALE_NOT_FOUND",
                 "UNIT_NOT_FOUND", "ROW_INVALID"):
        assert not is_cacheable(code), code


def test_pull_scope_by_permission_branch_and_cost() -> None:
    cashier = PullScope.for_actor(_user((B1, "cashier")))
    product = {"sku": "A", "cost_minor": 700, "cost_currency": "AFN", "version": 2, "junk": 1}
    # Hidden cost keys are omitted (not nulled), so a shared device keeps its local cost.
    assert cashier.view("products", None, product) == {"sku": "A", "version": 2}
    assert cashier.view("supplier_ledger", None, {"amount_minor": 1}) is None
    assert cashier.view("sales", B1, {"number": "1"}) == {"number": "1"}
    assert cashier.view("sales", B2, {"number": "1"}) is None
    # Rows logged before change_log.branch_id existed fall back to data.branch_id.
    assert cashier.view("sales", None, {"branch_id": B2}) is None
    line = {"unit_cost_minor": 700}
    assert cashier.view("sale_lines", B1, line) == {}
    manager = PullScope.for_actor(_user((B1, "manager")))
    assert manager.view("sale_lines", B1, line) == line
    assert manager.view("products", None, product)["cost_minor"] == 700  # type: ignore[index]
    keeper = PullScope.for_actor(_user((B1, "stock_keeper")))
    assert keeper.view("sales", B1, {}) is None and keeper.view("stock_movements", B1, {}) == {}
    assert PullScope.for_actor(_user((B1, "owner"), active=False)).is_empty
    assert PullScope.for_actor(_user()).is_empty


def test_role_label_and_clamp() -> None:
    actor = _user((B1, "stock_keeper"), (B1, "cashier"), (B2, "owner"))
    assert role_label(actor, B1) == "cashier,stock_keeper"
    assert role_label(actor, "elsewhere") is None
    assert [clamp_pull_limit(n) for n in (-5, 0, 1, 500, 5000)] == [1, 1, 1, 500, 1000]
