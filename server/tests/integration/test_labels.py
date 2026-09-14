"""Theme 9a on the server: the audit trail names its actors for the app to
show, and first-run setup no longer invents an English shop name."""

from __future__ import annotations

from fastapi.testclient import TestClient

_SETUP = {
    "setup_token": "test-setup-token", "username": "owner", "password": "pw12345678",
    "display_name": "Owner Ahmad",
}


def test_first_run_setup_needs_a_shop_name(client: TestClient) -> None:
    for body in (_SETUP, {**_SETUP, "shop_name": "   "}):
        refused = client.post("/auth/bootstrap", json=body)
        assert refused.status_code == 422, refused.text
    done = client.post("/auth/bootstrap", json={**_SETUP, "shop_name": "دکان احمد"})
    assert done.status_code < 300, done.text
    assert done.json()["user"]["branches"][0]["branch_name"] == "دکان احمد"


def test_audit_entries_name_their_actor(client: TestClient) -> None:
    boot = client.post("/auth/bootstrap", json={**_SETUP, "shop_name": "Dukan"})
    headers = {"Authorization": f"Bearer {boot.json()['tokens']['access_token']}"}
    entries = client.get("/audit", headers=headers).json()["entries"]
    by_someone = [e for e in entries if e["actor_id"]]
    assert by_someone and all(e["actor_name"] == "Owner Ahmad" for e in by_someone)
