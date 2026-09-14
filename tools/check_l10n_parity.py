#!/usr/bin/env python3
"""Check the app's ARB files against each other and against the template.

- Every locale has the same keys: a missing key is a build failure here, never
  a silent English fallback.
- Every placeholder the template (app_en.arb) declares appears in each
  translation, and no translation uses one the template does not declare.
- No translation is still the English text.
- app_fa.arb is the copy of app_fa_AF.arb for a device set to Persian, so the
  two stay identical.
- @@locale matches the file name.
- No digit is typed into a message: numbers come from placeholders, formatted
  in the locale's digits, so one sentence never mixes two digit systems. The
  two input examples ("such as 250") are exempt.

Metadata keys (`@@locale`, `@foo`) are not messages.
Run: python3 tools/check_l10n_parity.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

L10N_DIR = Path(__file__).resolve().parent.parent / "app" / "lib" / "l10n"
TEMPLATE = "app_en.arb"
DIGITS_ALLOWED = {"errAmountInvalid", "errQtyInvalid"}

# `{name}` or `{name, plural, ...}`; not a plural branch such as `other{items}`.
_PLACEHOLDER = re.compile(r"(?<![\w=])\{\s*(\w+)\s*[,}]")
_DIGIT = re.compile(r"[0-9٠-٩۰-۹]")
_EXACT_BRANCH = re.compile(r"=\d+\{")
_ANY_PLACEHOLDER = re.compile(r"\{[^{}]*\}")
_LETTER = re.compile(r"[^\W\d_]")


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def messages(data: dict) -> dict[str, str]:
    return {k: v for k, v in data.items() if not k.startswith("@")}


def placeholders_of(text: str) -> set[str]:
    return set(_PLACEHOLDER.findall(text))


def main() -> int:
    arbs = {p.name: load(p) for p in sorted(L10N_DIR.glob("app_*.arb"))}
    if TEMPLATE not in arbs:
        print(f"no {TEMPLATE} in {L10N_DIR}", file=sys.stderr)
        return 1
    msgs = {name: messages(data) for name, data in arbs.items()}
    errors: list[str] = []

    union: set[str] = set().union(*(m.keys() for m in msgs.values()))
    for name, m in msgs.items():
        missing = union - m.keys()
        if missing:
            errors.append(f"{name} is missing keys: {sorted(missing)}")
        locale = arbs[name].get("@@locale")
        if locale != name[len("app_") : -len(".arb")]:
            errors.append(f"{name}: @@locale is {locale!r}")

    en = msgs[TEMPLATE]
    declared = {
        k: set((arbs[TEMPLATE].get(f"@{k}") or {}).get("placeholders", {})) | placeholders_of(v)
        for k, v in en.items()
    }
    for name, m in msgs.items():
        for key, text in m.items():
            if key not in en:
                continue
            used = placeholders_of(text)
            if declared[key] - used:
                errors.append(f"{name} {key}: missing placeholder(s) {sorted(declared[key] - used)}")
            if used - declared[key]:
                errors.append(f"{name} {key}: unknown placeholder(s) {sorted(used - declared[key])}")
            if key not in DIGITS_ALLOWED and _DIGIT.search(_EXACT_BRANCH.sub("{", text)):
                errors.append(f"{name} {key}: a digit typed into the text; use a number placeholder")
            words = _ANY_PLACEHOLDER.sub("", text)
            if name != TEMPLATE and text == en[key] and _LETTER.search(words):
                errors.append(f"{name} {key}: still the English text")

    fa, fa_af = msgs.get("app_fa.arb"), msgs.get("app_fa_AF.arb")
    if fa is not None and fa_af is not None:
        drift = sorted(k for k in fa_af if fa.get(k) != fa_af[k])
        if drift:
            errors.append(f"app_fa.arb must copy app_fa_AF.arb; they differ at {drift}")

    for e in errors:
        print(f"✗ {e}", file=sys.stderr)
    if errors:
        return 1
    print(f"✓ l10n: {len(arbs)} locales share {len(union)} keys, placeholders and digits checked, fa = fa_AF")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
