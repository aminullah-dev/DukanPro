"""Identifier generation. UUIDv7: time-ordered, safe across offline installs.

Mirrors packages/dukan_core/lib/shared/ids.dart. Generated in the application
layer, never by the database.
"""

from __future__ import annotations

import os
import time
import uuid


def new_id() -> str:
    """UUIDv7 as a 36-character string."""
    ms = int(time.time() * 1000)
    rand = os.urandom(10)
    b = bytearray(16)
    b[0:6] = ms.to_bytes(6, "big")
    b[6:16] = rand
    b[6] = (b[6] & 0x0F) | 0x70  # version 7
    b[8] = (b[8] & 0x3F) | 0x80  # variant
    return str(uuid.UUID(bytes=bytes(b)))
