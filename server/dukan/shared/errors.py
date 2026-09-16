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


class AuthError(AppError):
    """Authentication failed or is required (bad credentials, invalid/expired token)."""

    http_status = 401


class NotFoundError(AppError):
    http_status = 404


class ConflictError(AppError):
    http_status = 409


class PermissionDeniedError(AppError):
    http_status = 403


class RateLimitedError(AppError):
    """Too many attempts; try again later (the sign-in lockout)."""

    http_status = 429


class LicenseError(AppError):
    http_status = 402


class IntegrationError(AppError):
    http_status = 502


class InfrastructureError(AppError):
    http_status = 500
