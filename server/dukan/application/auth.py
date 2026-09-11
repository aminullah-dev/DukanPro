"""AuthService port — the interface the UI layer depends on. The concrete
implementation lives in infrastructure (bound to a DB session + security). The
UI never imports infrastructure; it depends on this Protocol."""

from __future__ import annotations

from typing import Protocol

from dukan.application.dto import AuthenticatedUser, AuthResult, AuthTokens
from dukan.domain.identity import User


class AuthService(Protocol):
    def bootstrap_owner(
        self,
        *,
        username: str,
        password: str,
        display_name: str,
        shop_name: str,
        device_id: str,
    ) -> AuthResult: ...

    def authenticate(self, *, username: str, password: str, device_id: str) -> AuthResult: ...

    def refresh(self, *, refresh_token: str) -> AuthTokens: ...

    def logout(self, *, refresh_token: str) -> None: ...

    def authenticated_user(self, *, access_token: str) -> User: ...

    def profile(self, user: User) -> AuthenticatedUser: ...

    def create_user(
        self,
        *,
        actor: User,
        branch_id: str,
        username: str,
        password: str,
        display_name: str,
        role_name: str,
    ) -> AuthenticatedUser: ...
