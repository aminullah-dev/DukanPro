"""Theme 9b on the server: "today" is the branch's business day with an end,
a new branch's zone and currency are checked, and the profile tells the device
each branch's zone and currency."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest
from fastapi.testclient import TestClient

from dukan.infrastructure import reports_service

_SETUP = {
    "setup_token": "test-setup-token", "username": "owner", "password": "pw12345678",
    "display_name": "Owner", "shop_name": "Dukan",
}


def _owner(client: TestClient) -> tuple[dict, dict]:
    boot = client.post("/auth/bootstrap", json=_SETUP).json()
    return {"Authorization": f"Bearer {boot['tokens']['access_token']}"}, boot["user"]


def _sell_one(client: TestClient, h: dict) -> None:
    units = {u["name"]: u["id"] for u in client.get("/units", headers=h).json()}
    pid = client.post(
        "/products", headers=h,
        json={"sku": "P1", "name": "Soap", "unit_id": units["piece"], "sell_price_minor": 52000},
    ).json()["id"]
    client.post("/goods-receipts", headers=h, json={"lines": [{"product_id": pid, "qty_minor": 5, "unit_cost_minor": 40000}]})
    sold = client.post(
        "/sales", headers=h,
        json={"lines": [{"product_id": pid, "qty_minor": 1}],
              "payments": [{"method": "cash", "amount_minor": 52000, "tendered_minor": 52000}]},
    )
    assert sold.status_code < 300, sold.text


def test_today_is_the_branchs_business_day(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    h, _ = _owner(client)
    _sell_one(client, h)
    sold_at = datetime.now(UTC)

    def today() -> int:
        return int(client.get("/reports/dashboard", headers=h).json()["sales_today_minor"])

    assert today() == 52000
    monkeypatch.setattr(reports_service, "_now", lambda: sold_at + timedelta(days=1))
    assert today() == 0  # the next day in Kabul holds none of today's sales
    monkeypatch.setattr(reports_service, "_now", lambda: sold_at - timedelta(days=1))
    assert today() == 0  # and a day has an end: yesterday does not count today's


def test_a_new_branch_needs_a_supported_zone_and_currency(client: TestClient) -> None:
    h, _ = _owner(client)
    zone = client.post("/branches", headers=h, json={"name": "B2", "timezone": "Mars/Olympus"})
    assert zone.status_code == 422, zone.text
    assert zone.json()["error"]["code"] == "BRANCH_TIMEZONE_INVALID"
    money = client.post("/branches", headers=h, json={"name": "B2", "currency_default": "ZZZ"})
    assert money.json()["error"]["code"] == "BRANCH_CURRENCY_INVALID"
    usd = client.post("/branches", headers=h, json={"name": "B3", "currency_default": "USD"})
    assert usd.json()["error"]["code"] == "BRANCH_CURRENCY_INVALID"  # AFN only, for now
    ok = client.post("/branches", headers=h, json={"name": "B4", "timezone": "Asia/Karachi", "currency_default": "AFN"})
    assert ok.status_code < 300, ok.text


def test_the_profile_gives_each_branch_its_zone_and_currency(client: TestClient) -> None:
    _, user = _owner(client)
    branch = user["branches"][0]
    assert (branch["timezone"], branch["currency"]) == ("Asia/Kabul", "AFN")
