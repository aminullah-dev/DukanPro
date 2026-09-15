"""A fresh server's setup code comes from its secret key: every worker and every
restart shows the same one (docs/domain/identity-access.md)."""

from __future__ import annotations

import secrets
from pathlib import Path

from fastapi.testclient import TestClient

from dukan.composition import create_app, first_run_code
from dukan.config import Settings
from dukan.infrastructure.db.base import Base


def test_one_secret_gives_one_code_and_another_secret_another() -> None:
    key = secrets.token_urlsafe(48)
    assert first_run_code(key) == first_run_code(key)
    assert first_run_code(key) != first_run_code(secrets.token_urlsafe(48))
    assert len(first_run_code(key)) == 16


def test_every_worker_takes_the_code_the_log_shows(tmp_path: Path) -> None:
    key = secrets.token_urlsafe(48)
    settings = Settings(
        secret_key=key, database_url=f"sqlite:///{tmp_path}/workers.db", bootstrap_token=None
    )
    logged, other = create_app(settings), create_app(settings)  # two workers, one database
    Base.metadata.create_all(logged.state.engine)
    r = TestClient(other).post("/auth/bootstrap", json={
        "setup_token": first_run_code(key), "username": "owner", "password": "pw12345678",
        "display_name": "Owner", "shop_name": "Dukan",
    })
    assert r.status_code == 200, r.text
    logged.state.engine.dispose()
    other.state.engine.dispose()
