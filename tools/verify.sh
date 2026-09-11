#!/usr/bin/env bash
# Canonical, dependency-free Phase 0 verification. Runs every check.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="/opt/homebrew/bin:$PATH"

echo "▶ Dart packages"
for p in dukan_core dukan_data dukan_sync dukan_hardware; do
  echo "  • $p"
  ( cd "$ROOT/packages/$p"
    dart pub get >/dev/null
    dart analyze
    if [ -d test ]; then dart test; fi )
done

echo "▶ dukan_core must NOT depend on Flutter"
( cd "$ROOT/packages/dukan_core"
  if dart pub deps --style=compact 2>/dev/null | grep -qiE '(^| )flutter( |$)'; then
    echo "  ✗ flutter leaked into dukan_core"; exit 1
  else echo "  ✓ pure Dart"; fi )

echo "▶ Flutter app"
( cd "$ROOT/app"
  flutter pub get >/dev/null
  flutter gen-l10n >/dev/null
  flutter analyze
  flutter test )

echo "▶ l10n parity"
python3 "$ROOT/tools/check_l10n_parity.py"

echo "▶ Server"
( cd "$ROOT/server"
  VB=./.venv/bin
  if [ ! -x "$VB/python" ]; then python3.12 -m venv .venv && "$VB/pip" install -e ".[dev]" >/dev/null; fi
  "$VB/ruff" check .
  "$VB/mypy" dukan
  "$VB/lint-imports"
  "$VB/pytest" -q )

echo "✅ ALL GREEN"
