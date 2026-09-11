"""Composition root for the FastAPI server.

Translates external requests into use-case calls and results into JSON. Maps the
AppError contract onto HTTP responses: the client resolves `code` to a
translated message; the wording never crosses the wire.
"""

from __future__ import annotations

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from dukan.shared.errors import AppError
from dukan.ui.routers import health


def create_app() -> FastAPI:
    app = FastAPI(title="DukanPro API", version="0.1.0")
    app.include_router(health.router)

    @app.exception_handler(AppError)
    async def _app_error_handler(_request: Request, exc: AppError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.http_status,
            content={"error": {"code": exc.code, "context": exc.context}},
        )

    return app


app = create_app()
