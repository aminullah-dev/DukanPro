"""Configuration. Three sources in ascending precedence: defaults -> .env ->
environment variables (prefix DUKAN_). A missing required secret fails at
startup with a named error, not at first use (platform-core rule)."""

from __future__ import annotations

from functools import lru_cache

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="DUKAN_", env_file=".env", extra="ignore")

    secret_key: str  # required — no default; absence fails at startup
    database_url: str = "sqlite:///./dukan_dev.db"
    access_ttl_minutes: int = 15
    refresh_ttl_days: int = 30
    # First-run owner setup code. Unset: the server makes one at startup and logs
    # it; it is only needed until the owner account exists.
    bootstrap_token: str | None = None

    @field_validator("secret_key")
    @classmethod
    def _strong_secret(cls, value: str) -> str:
        # HS256 tokens are only as strong as this key.
        if len(value) < 32 or len(set(value)) < 8:
            raise ValueError("DUKAN_SECRET_KEY must be at least 32 random characters")
        return value

    @field_validator("bootstrap_token")
    @classmethod
    def _strong_setup_code(cls, value: str | None) -> str | None:
        if value is not None and len(value) < 12:
            raise ValueError("DUKAN_BOOTSTRAP_TOKEN must be at least 12 characters")
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]  # values come from env/.env
