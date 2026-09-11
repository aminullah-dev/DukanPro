"""Data transfer objects returned by the application layer to the UI."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class BranchRole:
    branch_id: str
    branch_name: str
    role_name: str


@dataclass(frozen=True, slots=True)
class AuthenticatedUser:
    id: str
    username: str
    display_name: str
    default_branch_id: str | None
    branches: tuple[BranchRole, ...]


@dataclass(frozen=True, slots=True)
class AuthTokens:
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


@dataclass(frozen=True, slots=True)
class AuthResult:
    user: AuthenticatedUser
    tokens: AuthTokens
