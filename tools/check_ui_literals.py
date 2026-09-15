#!/usr/bin/env python3
"""Fail on user-visible text the app builds from an exception or an error code
instead of a translated sentence (docs/localization.md). Each rule names its
replacement.
Run: python3 tools/check_ui_literals.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

APP_LIB = Path(__file__).resolve().parent.parent / "app" / "lib"

RULES = [  # (pattern, why, files where it is the one right place)
    (re.compile(r"""Text\(\s*(['"])\$\{?(e|err|error)\}?\1"""), "an exception's text: show ErrorMessage(e) or appErrorText", set()),
    # An error's or sync issue's code (a barcode's `code` is data and may show).
    (re.compile(r"\$\{(e|err|error|issue|failure)\.code!?\}"), "an error code inside a string: use errorCodeText", set()),
    (re.compile(r"Text\(\s*(e|err|error|issue|failure)\.code!?\s*[,)]"), "an error code as text: use errorCodeText", set()),
    (re.compile(r"'My Shop'|'Unlock DukanPro'"), "an English literal: add an ARB key", set()),
    (re.compile(r"DateFormat[.(]"), "a date on the device's clock or calendar: use formatDate/formatTime",
     {"widgets/dates.dart"}),
    (re.compile(r"TimeOfDay\.fromDateTime\("), "a time on the device's clock: use formatTime", set()),
    (re.compile(r"toStringAsFixed\("), "money or a quantity through a float: use amountText or formatQuantity", set()),
    (re.compile(r"'AFN'"), "a fixed currency: use the sale's or product's, or the branch's (shopCurrencyOf)",
     {"widgets/labels.dart", "widgets/money.dart", "features/auth/session.dart", "infrastructure/iam_api.dart"}),
]


def main() -> int:
    found = []
    for path in sorted(APP_LIB.rglob("*.dart")):
        if "l10n" in path.relative_to(APP_LIB).parts:
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            for pattern, why, home in RULES:
                if str(path.relative_to(APP_LIB)) not in home and pattern.search(line):
                    found.append(f"{path.relative_to(APP_LIB.parent)}:{number}: {why}\n    {line.strip()}")
    for f in found:
        print(f"✗ {f}", file=sys.stderr)
    if found:
        return 1
    print("✓ UI literals: no exception text or raw codes on screen")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
