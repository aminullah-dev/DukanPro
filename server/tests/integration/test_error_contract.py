"""Every failure answers in the error contract ({error: {code, context}}), so the
app never mistakes a server error for being offline; and authenticating hands
its database connection back before the endpoint runs."""

from __future__ import annotations

from fastapi.testclient import TestClient
from sqlalchemy import update
from sqlalchemy.orm import Session

from dukan.infrastructure.auth_service import SqlAuthService
from dukan.infrastructure.db.models import UserModel

PW = "pw12345678"


def _bootstrap(client: TestClient) -> str:
    r = client.post("/auth/bootstrap", json={
        "setup_token": "test-setup-token", "username": "owner", "password": PW,
        "display_name": "Owner", "shop_name": "Dukan",
    })
    assert r.status_code == 200, r.text
    return str(r.json()["tokens"]["access_token"])


def test_an_unexpected_error_answers_in_the_contract(client: TestClient) -> None:
    def boom() -> None:
        raise RuntimeError("internal detail")

    app = client.app
    app.add_api_route("/boom", boom)  # type: ignore[attr-defined]
    r = TestClient(app, raise_server_exceptions=False).get("/boom")
    assert r.status_code == 500
    assert r.json() == {"error": {"code": "INTERNAL", "context": {}}}
    assert "internal detail" not in r.text


def test_a_malformed_request_names_its_fields(client: TestClient) -> None:
    r = client.post("/auth/login", json={"username": "owner"})
    assert r.status_code == 422
    assert r.json()["error"]["code"] == "REQUEST_INVALID"
    assert "body.password" in r.json()["error"]["context"]["fields"]


def test_a_corrupt_password_hash_is_a_failed_login_not_a_crash(client: TestClient) -> None:
    _bootstrap(client)
    with Session(client.app.state.engine) as s:  # type: ignore[attr-defined]
        s.execute(update(UserModel).values(password_hash="not-an-argon2-hash"))
        s.commit()
    r = client.post("/auth/login", json={"username": "owner", "password": PW})
    assert (r.status_code, r.json()["error"]["code"]) == (401, "INVALID_CREDENTIALS")


def test_authenticating_hands_its_connection_back(client: TestClient) -> None:
    token = _bootstrap(client)
    state = client.app.state  # type: ignore[attr-defined]
    with state.session_factory() as session:
        svc = SqlAuthService(session, state.settings, setup_token="unused-setup-code")
        assert svc.authenticated_user(access_token=token).username == "owner"
        assert state.engine.pool.checkedout() == 0
