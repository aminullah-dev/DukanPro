"""Tokens — short-lived JWT access + opaque rotating refresh.

The refresh token's raw value is returned to the client once; only its SHA-256
hash is stored server-side (in the sessions table), so a DB leak cannot replay
sessions. Access tokens carry the session id so a revoked session is rejected
once the short access TTL lapses."""

from __future__ import annotations

import hashlib
import secrets
from datetime import UTC, datetime, timedelta

import jwt

from dukan.shared.errors import AuthError

_ALGO = "HS256"


def issue_access(*, secret: str, user_id: str, session_id: str, ttl_minutes: int) -> str:
    now = datetime.now(UTC)
    payload = {
        "sub": user_id,
        "sid": session_id,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=ttl_minutes)).timestamp()),
    }
    return jwt.encode(payload, secret, algorithm=_ALGO)


def decode_access(*, secret: str, token: str) -> dict:
    try:
        return jwt.decode(token, secret, algorithms=[_ALGO])
    except jwt.ExpiredSignatureError as e:
        raise AuthError("TOKEN_EXPIRED") from e
    except jwt.PyJWTError as e:
        raise AuthError("TOKEN_INVALID") from e


def new_refresh_token() -> str:
    return secrets.token_urlsafe(32)


def hash_refresh(raw: str) -> str:
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()
