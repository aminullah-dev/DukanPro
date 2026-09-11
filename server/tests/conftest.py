"""Test fixtures. Sets required env before importing the app, then builds an
isolated app bound to a temporary SQLite database per test."""

from __future__ import annotations

import os

# Required settings must exist before `dukan.composition` is imported (it builds
# a module-level app). Tests use their own per-test DB via the `client` fixture.
os.environ.setdefault("DUKAN_SECRET_KEY", "test-secret-key-at-least-32-bytes-long-00")
os.environ.setdefault("DUKAN_DATABASE_URL", "sqlite:///./.pytest_import.db")

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from dukan.composition import create_app  # noqa: E402
from dukan.config import Settings  # noqa: E402
from dukan.infrastructure.db.base import Base  # noqa: E402


@pytest.fixture
def client(tmp_path) -> TestClient:
    settings = Settings(
        secret_key="test-secret-key-at-least-32-bytes-long-00",
        database_url=f"sqlite:///{tmp_path / 't.db'}",
    )
    app = create_app(settings)
    Base.metadata.create_all(app.state.engine)
    return TestClient(app)
