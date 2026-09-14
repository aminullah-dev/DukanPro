"""Authorization on the right scope (review theme 2): IAM acts in the target's
branches, every branch keeps an owner, money actions need a manager, an inactive
branch takes no writes, and reads stay in the actor's branches."""

from __future__ import annotations

import uuid
from typing import Any

from fastapi.testclient import TestClient
from httpx import Response

PW = "pw12345678"


def _h(token: str, branch: str | None = None) -> dict[str, str]:
    headers = {"Authorization": f"Bearer {token}"}
    if branch:
        headers["X-Branch-Id"] = branch
    return headers


def _code(r: Response) -> str:
    return r.json()["error"]["code"]


class Shop:
    def __init__(self, client: TestClient) -> None:
        self.c = client
        boot = client.post("/auth/bootstrap", json={
            "username": "owner", "password": PW, "display_name": "Owner", "shop_name": "B1",
            "setup_token": "test-setup-token",
        }).json()
        self.owner_id: str = boot["user"]["id"]
        self.owner_token: str = boot["tokens"]["access_token"]
        self.owner = _h(self.owner_token)
        self.b1: str = boot["user"]["default_branch_id"]
        units = {u["name"]: u["id"] for u in client.get("/units", headers=self.owner).json()}
        self.pid: str = client.post("/products", headers=self.owner, json={
            "sku": "P1", "name": "Soap", "unit_id": units["piece"], "sell_price_minor": 5000,
        }).json()["id"]

    def branch(self, name: str) -> str:
        r = self.c.post("/branches", headers=self.owner, json={"name": name})
        assert r.status_code == 200, r.text
        return r.json()["id"]

    def user(self, username: str, role: str, branch: str | None = None) -> tuple[str, str]:
        """(access token, user id) of a new employee."""
        body = {"username": username, "password": PW, "display_name": username, "role_name": role}
        if branch:
            body["branch_id"] = branch
        r = self.c.post("/users", headers=self.owner, json=body)
        assert r.status_code == 200, r.text
        login = self.c.post("/auth/login", json={"username": username, "password": PW}).json()
        return login["tokens"]["access_token"], r.json()["id"]

    def sell(self, token: str, branch: str | None = None, **extra: Any) -> Response:
        return self.c.post("/sales", headers=_h(token, branch), json={
            "lines": [{"product_id": self.pid, "qty_minor": 1}],
            "payments": [{"method": "cash", "amount_minor": 5000}],
            **extra,
        })


# ── IAM acts in the target's scope (F010, F011, F077, F176) ──────────────────


def test_a_branch_owner_cannot_take_over_other_branches(client: TestClient) -> None:
    shop = Shop(client)
    b2 = shop.branch("B2")
    bo_token, bo_id = shop.user("bo", "owner", branch=b2)
    _, c1_id = shop.user("c1", "cashier")  # works in B1 only
    bo = _h(bo_token, b2)
    attempts = [
        client.post(f"/users/{bo_id}/roles", headers=bo,
                    json={"branch_id": shop.b1, "role_name": "owner"}),
        client.post(f"/users/{shop.owner_id}/password", headers=bo,
                    json={"new_password": "hacked1234"}),
        client.patch(f"/users/{shop.owner_id}/status", headers=bo, json={"active": False}),
        client.patch(f"/users/{c1_id}/status", headers=bo, json={"active": False}),
        client.patch(f"/branches/{shop.b1}", headers=bo, json={"name": "Mine"}),
        client.patch(f"/branches/{shop.b1}", headers=bo, json={"active": False}),
        client.post("/branches", headers=bo, json={"name": "B3"}),
        client.get("/audit", headers=bo),
    ]
    assert [(r.status_code, _code(r)) for r in attempts] == [(403, "ACCESS_DENIED")] * 8
    # They manage B2's people and see only B2 (the shop owner also owns B2).
    users = {u["username"] for u in client.get("/users", headers=bo).json()["users"]}
    assert users == {"owner", "bo"}
    assert [b["id"] for b in client.get("/branches", headers=bo).json()["branches"]] == [b2]
    assert client.post("/auth/login", json={"username": "owner", "password": PW}).status_code == 200


def test_every_branch_keeps_an_active_owner(client: TestClient) -> None:
    shop = Shop(client)
    me = shop.owner_id
    demote = client.post(f"/users/{me}/roles", headers=shop.owner,
                         json={"branch_id": shop.b1, "role_name": "cashier"})
    revoke = client.delete(f"/users/{me}/roles/{shop.b1}", headers=shop.owner)
    assert (demote.status_code, _code(demote)) == (409, "USER_LAST_OWNER")
    assert (revoke.status_code, _code(revoke)) == (409, "USER_LAST_OWNER")
    # With a second owner in the branch, the first may step down.
    shop.user("o2", "owner")
    ok = client.post(f"/users/{me}/roles", headers=shop.owner,
                     json={"branch_id": shop.b1, "role_name": "manager"})
    assert ok.status_code == 200, ok.text


def test_revoking_keeps_an_assignment_and_a_live_default(client: TestClient) -> None:
    shop = Shop(client)
    b2 = shop.branch("B2")
    _, cid = shop.user("c1", "cashier")  # default branch B1
    added = client.post(f"/users/{cid}/roles", headers=shop.owner,
                        json={"branch_id": b2, "role_name": "cashier"})
    assert added.status_code == 200, added.text
    assert client.delete(f"/users/{cid}/roles/{shop.b1}", headers=shop.owner).status_code == 200
    token = client.post("/auth/login", json={"username": "c1", "password": PW}).json()
    me = client.get("/auth/me", headers=_h(token["tokens"]["access_token"])).json()
    assert me["default_branch_id"] == b2
    last = client.delete(f"/users/{cid}/roles/{b2}", headers=shop.owner)
    assert (last.status_code, _code(last)) == (409, "USER_LAST_ASSIGNMENT")


def test_only_builtin_roles_can_be_granted(client: TestClient) -> None:
    shop = Shop(client)
    r = client.post("/users", headers=shop.owner, json={
        "username": "x", "password": PW, "display_name": "X", "role_name": "admin",
    })
    assert (r.status_code, _code(r)) == (422, "ROLE_UNKNOWN")
    _, cid = shop.user("c1", "cashier")
    r = client.post(f"/users/{cid}/roles", headers=shop.owner,
                    json={"branch_id": shop.b1, "role_name": "superuser"})
    assert (r.status_code, _code(r)) == (422, "ROLE_UNKNOWN")


def test_a_new_branch_is_owned_by_its_creator(client: TestClient) -> None:
    shop = Shop(client)
    b2 = shop.branch("B2")
    assert client.get("/reports/dashboard", headers=_h(shop.owner_token, b2)).status_code == 200
    token, _ = shop.user("m2", "manager", branch=b2)
    assert client.get("/auth/me", headers=_h(token)).json()["default_branch_id"] == b2


# ── branch activity (F078) ────────────────────────────────────────────────────


def test_an_inactive_branch_takes_no_writes(client: TestClient) -> None:
    shop = Shop(client)
    b2 = shop.branch("B2")
    cashier, _ = shop.user("c2", "cashier", branch=b2)
    assert client.patch(f"/branches/{b2}", headers=shop.owner, json={"active": False}).status_code == 200
    sale = shop.sell(cashier)
    assert (sale.status_code, _code(sale)) == (409, "BRANCH_INACTIVE")
    hire = client.post("/users", headers=shop.owner, json={
        "username": "late", "password": PW, "display_name": "L", "role_name": "cashier",
        "branch_id": b2,
    })
    assert (hire.status_code, _code(hire)) == (409, "BRANCH_INACTIVE")
    assert client.get("/products", headers=_h(cashier)).status_code == 200  # history stays
    # An op recorded offline waits (the rejection is not recorded) until it reopens.
    move = {
        "op_id": str(uuid.uuid4()), "table": "stock_movements", "row_id": str(uuid.uuid4()),
        "op": "insert",
        "data": {"product_id": shop.pid, "branch_id": b2, "qty_delta": 5, "reason": "adjustment"},
    }

    def push() -> str | None:
        r = client.post("/sync/push", headers=shop.owner, json={"device_id": "d", "ops": [move]})
        return r.json()["results"][0]["code"]

    assert push() == "BRANCH_INACTIVE"
    assert client.patch(f"/branches/{b2}", headers=shop.owner, json={"active": True}).status_code == 200
    assert push() is None


# ── money actions need a manager (F012, F085, F088, F089, F186) ─────────────


def test_voids_need_a_manager_the_sales_branch_and_a_reason(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.user("c1", "cashier")
    sale = shop.sell(cashier).json()
    b2 = shop.branch("B2")
    b2_manager, _ = shop.user("m2", "manager", branch=b2)
    url = f"/sales/{sale['id']}/void"
    by_cashier = client.post(url, headers=_h(cashier), json={"reason": "oops"})
    by_other_branch = client.post(url, headers=_h(b2_manager), json={"reason": "oops"})
    assert [r.status_code for r in (by_cashier, by_other_branch)] == [403, 403]
    assert client.post(url, headers=shop.owner, json={}).status_code == 422
    blank = client.post(url, headers=shop.owner, json={"reason": "   "})
    assert (blank.status_code, _code(blank)) == (422, "SALE_VOID_REASON_REQUIRED")
    ok = client.post(url, headers=shop.owner, json={"reason": "Customer returned it"})
    assert ok.status_code == 200 and ok.json()["status"] == "voided"
    entries = client.get("/audit?action=sale.voided", headers=shop.owner).json()["entries"]
    assert entries[0]["after"]["reason"] == "Customer returned it"
    # A sale whose shift was already counted cannot be voided.
    shift = client.post("/shifts", headers=_h(cashier), json={"opening_float_minor": 0}).json()
    counted = shop.sell(cashier, shift_id=shift["id"]).json()
    client.post(f"/shifts/{shift['id']}/close", headers=_h(cashier),
                json={"counted_cash_minor": 5000})
    late = client.post(f"/sales/{counted['id']}/void", headers=shop.owner, json={"reason": "late"})
    assert (late.status_code, _code(late)) == (409, "SALE_SHIFT_CLOSED")


def test_discounts_need_a_manager_and_stay_within_the_subtotal(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.user("c1", "cashier")
    r = shop.sell(cashier, discount_minor=1000)
    assert (r.status_code, _code(r)) == (403, "ACCESS_DENIED")
    for bad in (-1000, 6000):
        r = shop.sell(shop.owner_token, discount_minor=bad)
        assert (r.status_code, _code(r)) == (422, "SALE_DISCOUNT_INVALID"), bad
    ok = shop.sell(shop.owner_token, discount_minor=1000)
    assert ok.status_code == 200 and ok.json()["total_minor"] == 4000
    assert client.get("/audit?action=discount.applied", headers=shop.owner).json()["entries"]


def test_credit_is_granted_by_a_manager(client: TestClient) -> None:
    shop = Shop(client)
    cashier, _ = shop.user("c1", "cashier")
    c = _h(cashier)
    for limit in (50000, None):  # None is unlimited credit
        r = client.post("/customers", headers=c, json={"name": "K", "credit_limit_minor": limit})
        assert (r.status_code, _code(r)) == (403, "ACCESS_DENIED"), limit
    assert client.post("/customers", headers=c,
                       json={"name": "K", "credit_limit_minor": 0}).status_code == 200
    bad = client.post("/customers", headers=shop.owner,
                      json={"name": "N", "credit_limit_minor": -1})
    assert (bad.status_code, _code(bad)) == (422, "CUSTOMER_CREDIT_LIMIT_INVALID")
    # Offline, the cashier's customer still syncs, but with no credit.
    cid = str(uuid.uuid4())
    op = {
        "op_id": str(uuid.uuid4()), "table": "customers", "row_id": cid, "op": "insert",
        "data": {"name": "Offline", "credit_limit_minor": 90000},
    }
    r = client.post("/sync/push", headers=c, json={"device_id": "d", "ops": [op]})
    assert r.json()["results"][0]["outcome"] == "applied"
    assert client.get(f"/customers/{cid}", headers=shop.owner).json()["credit_limit_minor"] == 0


def test_a_stock_keeper_receives_quantities_only(client: TestClient) -> None:
    shop = Shop(client)
    keeper, _ = shop.user("k1", "stock_keeper")
    sid = client.post("/suppliers", headers=shop.owner, json={"name": "Sup"}).json()["id"]
    k = _h(keeper)
    line = {"product_id": shop.pid, "qty_minor": 4, "unit_cost_minor": 0}
    costed = client.post("/goods-receipts", headers=k,
                         json={"lines": [{**line, "unit_cost_minor": 999}]})
    billed = client.post("/goods-receipts", headers=k, json={"supplier_id": sid, "lines": [line]})
    assert [r.status_code for r in (costed, billed)] == [403, 403]
    assert client.post("/goods-receipts", headers=k, json={"lines": [line]}).status_code == 200
    assert client.get(f"/products/{shop.pid}", headers=shop.owner).json()["on_hand"] == 4
    ghost = client.post("/goods-receipts", headers=shop.owner,
                        json={"supplier_id": str(uuid.uuid4()), "lines": [line]})
    assert (ghost.status_code, _code(ghost)) == (404, "SUPPLIER_NOT_FOUND")


# ── reads and shifts (F089, F090) ─────────────────────────────────────────────


def test_reads_stay_in_the_actors_branches(client: TestClient) -> None:
    shop = Shop(client)
    keeper, _ = shop.user("k1", "stock_keeper")
    assert client.get("/customers", headers=_h(keeper)).status_code == 403
    sale = shop.sell(shop.owner_token).json()
    b2 = shop.branch("B2")
    b2_cashier, _ = shop.user("c2", "cashier", branch=b2)
    assert client.get(f"/sales/{sale['id']}", headers=_h(b2_cashier)).status_code == 403
    assert client.get(f"/sales/{sale['id']}", headers=shop.owner).status_code == 200
    assert client.get("/products", headers=_h(b2_cashier, shop.b1)).status_code == 403
    assert client.get("/products", headers=_h(b2_cashier)).status_code == 200


def test_a_shift_closes_once_by_its_cashier_or_a_manager(client: TestClient) -> None:
    shop = Shop(client)
    c1, _ = shop.user("c1", "cashier")
    c2, _ = shop.user("c2", "cashier")
    shift = client.post("/shifts", headers=_h(c1), json={"opening_float_minor": 0}).json()
    url = f"/shifts/{shift['id']}/close"
    assert client.post(url, headers=_h(c2), json={"counted_cash_minor": 0}).status_code == 403
    assert client.post(url, headers=_h(c1), json={"counted_cash_minor": 0}).status_code == 200
    again = client.post(url, headers=shop.owner, json={"counted_cash_minor": 999})
    assert (again.status_code, _code(again)) == (409, "SHIFT_ALREADY_CLOSED")
