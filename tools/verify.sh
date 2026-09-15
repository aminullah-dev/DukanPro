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
    # dukan_data uses Drift codegen; regenerate so a clean checkout is self-sufficient.
    if [ "$p" = "dukan_data" ]; then dart run build_runner build >/dev/null; fi
    dart analyze
    if [ -d test ]; then dart test; fi )
done

echo "▶ dukan_core must NOT depend on Flutter"
( cd "$ROOT/packages/dukan_core"
  # Look for a dependency named flutter, not the "Flutter SDK" banner that a
  # Flutter-bundled dart always prints. Capture the list first: grep -q closing
  # the pipe early crashes pub, and under pipefail that crash read as a pass.
  deps="$(dart pub deps --style=compact 2>/dev/null)"
  grep -q '^dukan_core ' <<<"$deps" || { echo "  ✗ could not list dukan_core's dependencies"; exit 1; }
  if grep -qE '^- flutter( |$)' <<<"$deps"; then
    echo "  ✗ flutter leaked into dukan_core"; exit 1
  else echo "  ✓ pure Dart"; fi )

echo "▶ Flutter app"
( cd "$ROOT/app"
  flutter pub get >/dev/null
  flutter gen-l10n >/dev/null
  flutter analyze
  flutter test )

echo "▶ l10n parity and UI literals"
python3 "$ROOT/tools/check_l10n_parity.py"
python3 "$ROOT/tools/check_ui_literals.py"

echo "▶ Server"
( cd "$ROOT/server"
  VB=./.venv/bin
  if [ ! -x "$VB/python" ]; then python3.12 -m venv .venv && "$VB/pip" install -e ".[dev]" >/dev/null; fi
  "$VB/ruff" check .
  "$VB/mypy" dukan
  "$VB/lint-imports"
  "$VB/pytest" -q )

echo "✅ ALL GREEN"
