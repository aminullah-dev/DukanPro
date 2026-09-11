"""Configuration. Three sources in ascending precedence: defaults -> .env ->
environment variables (prefix DUKAN_). A missing required secret fails at
startup with a named error, not at first use (platform-core rule)."""

from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="DUKAN_", env_file=".env", extra="ignore")

    secret_key: str  # required — no default; absence fails at startup
    database_url: str = "sqlite:///./dukan_dev.db"
    access_ttl_minutes: int = 15
    refresh_ttl_days: int = 30


@lru_cache
def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]  # values come from env/.env
