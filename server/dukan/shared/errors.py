"""Error contract. A code is a promise; the wording is not.

Mirrors packages/dukan_core/lib/shared/errors.dart. Domain code raises only
ValidationError and ConflictError; everything else is an application or
infrastructure concern.
"""

from __future__ import annotations

from typing import Any


class AppError(Exception):
    http_status: int = 500

    def __init__(self, code: str, **context: Any) -> None:
        super().__init__(code)
        self.code = code
        self.context: dict[str, Any] = context


class ValidationError(AppError):
    http_status = 422


class NotFoundError(AppError):
    http_status = 404


class ConflictError(AppError):
    http_status = 409


class PermissionDeniedError(AppError):
    http_status = 403


class LicenseError(AppError):
    http_status = 402


class IntegrationError(AppError):
    http_status = 502


class InfrastructureError(AppError):
    http_status = 500
