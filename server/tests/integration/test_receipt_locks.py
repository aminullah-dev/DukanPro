"""Receipts lock their products in id order before the feed's lock, so two
receipts of the same goods, or a receipt and a sync edit of one of its products,
take turns instead of deadlocking (docs/sync-protocol.md). Only PostgreSQL has
the row and advisory locks involved, so this runs there (the CI job)."""

from __future__ import annotations

import os
import uuid
from collections.abc import Callable
from threading import Thread

import pytest
from fastapi.testclient import TestClient

pytestmark = pytest.mark.skipif(
    not os.environ.get("DUKAN_TEST_DATABASE_URL"),
    reason="row and advisory locks: PostgreSQL only",
)

PW = "pw12345678"
PIECE = "00000000-0000-7000-8000-000000000001"
ROUNDS = 10


def _together(*jobs: Callable[[], None]) -> None:
    threads = [Thread(target=job) for job in jobs]
    for t in threads:
        t.start()
    for t in threads:
        t.join(timeout=120)
    assert not any(t.is_alive() for t in threads), "a writer never finished"


class Shop:
    def __init__(self, client: TestClient) -> None:
        boot = client.post("/auth/bootstrap", json={
            "setup_token": "test-setup-token", "username": "owner", "password": PW,
            "display_name": "Owner", "shop_name": "Dukan",
        }).json()
        self.client = client
        self.owner = {"Authorization": f"Bearer {boot['tokens']['access_token']}"}

    def product(self) -> str:
        r = self.client.post("/products", headers=self.owner, json={
            "sku": "S" + str(uuid.uuid4())[:8], "name": "Soap", "unit_id": PIECE,
            "sell_price_minor": 5000, "track_stock": True,
        })
        assert r.status_code == 200, r.text
        return str(r.json()["id"])

    def on_hand(self, pid: str) -> int:
        return int(self.client.get(f"/products/{pid}", headers=self.owner).json()["on_hand"])


def test_two_receipts_of_the_same_goods_take_turns(client: TestClient) -> None:
    shop = Shop(client)
    soap, rice = shop.product(), shop.product()
    failures: list[str] = []

    def receive(order: list[str]) -> None:
        c = TestClient(client.app)
        for _ in range(ROUNDS):
            r = c.post("/goods-receipts", headers=shop.owner, json={
                "lines": [{"product_id": p, "qty_minor": 1, "unit_cost_minor": 100} for p in order],
            })
            if r.status_code != 200:
                failures.append(r.text)

    _together(lambda: receive([soap, rice]), lambda: receive([rice, soap]))
    assert failures == []
    assert (shop.on_hand(soap), shop.on_hand(rice)) == (2 * ROUNDS, 2 * ROUNDS)


def test_a_receipt_and_a_sync_edit_of_its_product_take_turns(client: TestClient) -> None:
    shop = Shop(client)
    soap = shop.product()
    failures: list[str] = []

    def receive() -> None:
        c = TestClient(client.app)
        for _ in range(ROUNDS):
            r = c.post("/goods-receipts", headers=shop.owner, json={
                "lines": [{"product_id": soap, "qty_minor": 1, "unit_cost_minor": 100}],
            })
            if r.status_code != 200:
                failures.append(r.text)

    def rename() -> None:
        c = TestClient(client.app)
        for i in range(ROUNDS):
            version = int(c.get(f"/products/{soap}", headers=shop.owner).json()["version"])
            r = c.post("/sync/push", headers=shop.owner, json={"device_id": "dev-1", "ops": [{
                "op_id": str(uuid.uuid4()), "table": "products", "row_id": soap, "op": "update",
                "data": {"name": f"Soap {i}"}, "base_version": version,
            }]})
            if r.status_code != 200:  # a conflict is an answer; an error is not
                failures.append(r.text)

    _together(receive, rename)
    assert failures == []
    assert shop.on_hand(soap) == ROUNDS
