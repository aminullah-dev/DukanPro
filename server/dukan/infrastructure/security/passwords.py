"""Password hashing — argon2id."""

from __future__ import annotations

from argon2 import PasswordHasher
from argon2.exceptions import Argon2Error, InvalidHashError

_hasher = PasswordHasher()  # argon2id defaults


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(hashed: str, password: str) -> bool:
    try:
        return _hasher.verify(hashed, password)
    except (Argon2Error, InvalidHashError):
        # A wrong password, or a stored hash that is not an argon2 hash at all.
        return False
