"""Request-field bounds shared by the REST DTOs (review R1-104): string lengths
match their DB columns and integers fit theirs (32-bit counters, 64-bit money and
quantities), so oversize input is a 422 REQUEST_INVALID instead of a database
error 500."""

from __future__ import annotations

from typing import Annotated

from pydantic import Field, StringConstraints

from dukan.shared.limits import INT32_MAX, INT32_MIN, MONEY_MAX

Int32 = Annotated[int, Field(ge=INT32_MIN, le=INT32_MAX)]
Money = Annotated[int, Field(ge=-MONEY_MAX, le=MONEY_MAX)]  # minor units or a quantity
Id = Annotated[str, Field(max_length=36)]
Currency = Annotated[str, Field(min_length=3, max_length=3)]
Str8 = Annotated[str, Field(max_length=8)]
Str32 = Annotated[str, Field(max_length=32)]
Str48 = Annotated[str, Field(max_length=48)]
Str64 = Annotated[str, Field(max_length=64)]
Str128 = Annotated[str, Field(max_length=128)]
# A name that must be given (a shop's name heads its receipts): blank is refused.
Name128 = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=128)]
Str200 = Annotated[str, Field(max_length=200)]
Secret = Annotated[str, Field(max_length=256)]  # passwords, refresh tokens
