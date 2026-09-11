#!/usr/bin/env python3
"""Fail if the app's ARB locale files do not share an identical key set.

A key present in one locale and missing in another is a build failure here —
never a silent English fallback. Metadata keys (`@@locale`, `@foo`) are ignored.
Run: python3 tools/check_l10n_parity.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

L10N_DIR = Path(__file__).resolve().parent.parent / "app" / "lib" / "l10n"


def keys_of(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k for k in data if not k.startswith("@")}


def main() -> int:
    arbs = sorted(L10N_DIR.glob("app_*.arb"))
    if not arbs:
        print(f"no ARB files found in {L10N_DIR}", file=sys.stderr)
        return 1

    per_file = {p.name: keys_of(p) for p in arbs}
    union: set[str] = set().union(*per_file.values())

    ok = True
    for name, ks in per_file.items():
        missing = union - ks
        if missing:
            ok = False
            print(f"✗ {name} is missing keys: {sorted(missing)}", file=sys.stderr)

    if ok:
        print(f"✓ l10n parity: {len(arbs)} locales share {len(union)} keys")
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
