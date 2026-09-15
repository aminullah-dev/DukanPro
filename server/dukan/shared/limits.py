"""Numeric limits shared by every layer.

Money (minor units) and quantities are 64-bit in the database. MONEY_MAX keeps
them exact as JSON numbers, with room to add many of them. Versions and other
counters stay 32-bit (PostgreSQL INTEGER)."""

from __future__ import annotations

INT32_MIN = -(2**31)
INT32_MAX = 2**31 - 1
MONEY_MAX = 2**53 - 1
