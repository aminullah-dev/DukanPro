#!/usr/bin/env bash
# Builds DukanPro's Android release for a shop: APKs to install straight onto its
# phones and tablets (one per processor type) and an app bundle for Google Play.
# Both talk to the shop's server and carry a version code that grows by itself,
# because Android refuses to update an app to a lower one.
#
#   tools/build_android_release.sh
#
# DUKAN_API (default https://api.linumic.com) is the server the build talks to; a
# shop set up without a server never calls it. Signing needs app/android/key.properties
# and the upload keystore it names (docs/release-android.md).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="/opt/homebrew/bin:$PATH"
API="${DUKAN_API:-https://api.linumic.com}"
# Minutes since 1970: higher every minute, and far below Android's 2100000000 limit
# (iOS's date-shaped build number would be a hundred times over it).
BUILD_NUMBER="${BUILD_NUMBER:-$(( $(date -u +%s) / 60 ))}"

if [ ! -f "$ROOT/app/android/key.properties" ]; then
  echo "app/android/key.properties is missing: create the upload key first (docs/release-android.md)." >&2
  exit 1
fi

cd "$ROOT/app"
# What ships is what was tested: the committed dependency versions, or nothing.
flutter pub get --enforce-lockfile
flutter build apk --release --split-per-abi --dart-define=DUKAN_API="$API" --build-number="$BUILD_NUMBER"
flutter build appbundle --release --dart-define=DUKAN_API="$API" --build-number="$BUILD_NUMBER"
echo "Build $BUILD_NUMBER for $API:"
echo "  APKs to install directly: app/build/app/outputs/flutter-apk/app-*-release.apk"
echo "  App bundle for Google Play: app/build/app/outputs/bundle/release/app-release.aab"
