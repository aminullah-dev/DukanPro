"""Engine + session factory. SQLite for dev/tests, PostgreSQL in production
(both via sync SQLAlchemy 2.0)."""

from __future__ import annotations

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session, sessionmaker


def make_engine(url: str) -> Engine:
    if url.startswith("sqlite"):
        return create_engine(url, connect_args={"check_same_thread": False}, future=True)
    # A request holds one connection at a time (authentication hands its own back
    # before the endpoint runs), so the pool covers the 40 request threads; a
    # connection the database dropped is replaced instead of failing a request.
    return create_engine(
        url, future=True, pool_pre_ping=True, pool_size=10, max_overflow=30, pool_timeout=10
    )


def make_session_factory(engine: Engine) -> sessionmaker[Session]:
    return sessionmaker(bind=engine, class_=Session, expire_on_commit=False)
