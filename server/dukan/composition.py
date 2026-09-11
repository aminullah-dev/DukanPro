"""Composition root. The ONE place concrete classes meet interfaces: it builds
the FastAPI app, wires the DB-backed AuthService into the UI's dependency, and
maps the AppError contract onto HTTP responses. This module may import every
layer; the UI and infrastructure layers never import each other.

uvicorn entrypoint: `dukan.composition:app`.
"""

from __future__ import annotations

from collections.abc import Iterator

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from dukan.application.auth import AuthService
from dukan.application.catalog import CatalogService
from dukan.application.customers import CustomerService
from dukan.application.iam import IamService
from dukan.application.insights import InsightService
from dukan.application.purchasing import PurchasingService
from dukan.application.reports import ReportsService
from dukan.application.sales import SalesService
from dukan.application.sync import SyncService
from dukan.config import Settings, get_settings
from dukan.infrastructure.auth_service import SqlAuthService
from dukan.infrastructure.catalog_service import SqlCatalogService
from dukan.infrastructure.customers_service import SqlCustomerService
from dukan.infrastructure.db.session import make_engine, make_session_factory
from dukan.infrastructure.iam_service import SqlIamService
from dukan.infrastructure.insight_service import SqlInsightService
from dukan.infrastructure.purchasing_service import SqlPurchasingService
from dukan.infrastructure.reports_service import SqlReportsService
from dukan.infrastructure.sales_service import SqlSalesService
from dukan.infrastructure.sync_service import SqlSyncService
from dukan.shared.errors import AppError
from dukan.ui.deps import (
    get_auth_service,
    get_catalog_service,
    get_customer_service,
    get_iam_service,
    get_insight_service,
    get_purchasing_service,
    get_reports_service,
    get_sales_service,
    get_sync_service,
)
from dukan.ui.routers import (
    auth,
    branches,
    catalog,
    customers,
    health,
    insights,
    purchasing,
    reports,
    sales,
    sync,
    users,
)


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or get_settings()
    engine = make_engine(settings.database_url)
    session_factory = make_session_factory(engine)

    app = FastAPI(title="DukanPro API", version="0.1.0")
    app.state.settings = settings
    app.state.engine = engine
    app.state.session_factory = session_factory

    app.include_router(health.router)
    app.include_router(auth.router)
    app.include_router(users.router)
    app.include_router(branches.router)
    app.include_router(catalog.router)
    app.include_router(sales.router)
    app.include_router(customers.router)
    app.include_router(purchasing.router)
    app.include_router(reports.router)
    app.include_router(sync.router)
    app.include_router(insights.router)

    def provide_auth_service() -> Iterator[AuthService]:
        session = session_factory()
        try:
            yield SqlAuthService(session, settings)
        finally:
            session.close()

    def provide_catalog_service() -> Iterator[CatalogService]:
        session = session_factory()
        try:
            yield SqlCatalogService(session)
        finally:
            session.close()

    def provide_sales_service() -> Iterator[SalesService]:
        session = session_factory()
        try:
            yield SqlSalesService(session)
        finally:
            session.close()

    def provide_customer_service() -> Iterator[CustomerService]:
        session = session_factory()
        try:
            yield SqlCustomerService(session)
        finally:
            session.close()

    def provide_purchasing_service() -> Iterator[PurchasingService]:
        session = session_factory()
        try:
            yield SqlPurchasingService(session)
        finally:
            session.close()

    def provide_reports_service() -> Iterator[ReportsService]:
        session = session_factory()
        try:
            yield SqlReportsService(session)
        finally:
            session.close()

    def provide_sync_service() -> Iterator[SyncService]:
        session = session_factory()
        try:
            yield SqlSyncService(session)
        finally:
            session.close()

    def provide_iam_service() -> Iterator[IamService]:
        session = session_factory()
        try:
            yield SqlIamService(session)
        finally:
            session.close()

    def provide_insight_service() -> Iterator[InsightService]:
        session = session_factory()
        try:
            yield SqlInsightService(session)
        finally:
            session.close()

    app.dependency_overrides[get_auth_service] = provide_auth_service
    app.dependency_overrides[get_catalog_service] = provide_catalog_service
    app.dependency_overrides[get_sales_service] = provide_sales_service
    app.dependency_overrides[get_customer_service] = provide_customer_service
    app.dependency_overrides[get_purchasing_service] = provide_purchasing_service
    app.dependency_overrides[get_reports_service] = provide_reports_service
    app.dependency_overrides[get_sync_service] = provide_sync_service
    app.dependency_overrides[get_iam_service] = provide_iam_service
    app.dependency_overrides[get_insight_service] = provide_insight_service

    @app.exception_handler(AppError)
    async def _app_error_handler(_request: Request, exc: AppError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.http_status,
            content={"error": {"code": exc.code, "context": exc.context}},
        )

    return app


app = create_app()
