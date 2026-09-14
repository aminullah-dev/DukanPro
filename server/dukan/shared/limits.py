"""Numeric limits shared by every layer. PostgreSQL INTEGER is 32-bit signed, so
every persisted int (money minor units, quantities, versions) must fit in it."""

from __future__ import annotations

INT32_MIN = -(2**31)
INT32_MAX = 2**31 - 1
