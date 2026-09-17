#!/usr/bin/env bash
# Builds DukanPro for TestFlight: a release build that talks to the shop's
# server, with a build number that grows by itself (App Store Connect refuses a
# number it has seen).
#
#   tools/build_ios_testflight.sh                 archive, sign, export an .ipa
#   tools/build_ios_testflight.sh --upload        ...and upload it to App Store Connect
#   tools/build_ios_testflight.sh --no-codesign   check the release build compiles; sign nothing
#
# DUKAN_API (default https://api.linumic.com) is the server the build talks to.
# Signing is automatic for team 27RXPRW77S: Xcode must be signed in to that team,
# or ASC_KEY_PATH, ASC_KEY_ID and ASC_ISSUER_ID must name an App Store Connect API key.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="/opt/homebrew/bin:$PATH"
API="${DUKAN_API:-https://api.linumic.com}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date -u +%Y%m%d%H%M)}"
MODE="${1:-}"
cd "$ROOT/app"
# What ships is what was tested: the committed dependency versions, or nothing.
flutter pub get --enforce-lockfile

if [ "$MODE" = "--no-codesign" ]; then
  flutter build ipa --release --no-codesign --dart-define=DUKAN_API="$API" --build-number="$BUILD_NUMBER"
  exit 0
fi

auth=()
if [ -n "${ASC_KEY_ID:-}" ]; then
  auth=(-authenticationKeyPath "${ASC_KEY_PATH:?set ASC_KEY_PATH}" -authenticationKeyID "$ASC_KEY_ID"
        -authenticationKeyIssuerID "${ASC_ISSUER_ID:?set ASC_ISSUER_ID}")
fi
destination=export
[ "$MODE" = "--upload" ] && destination=upload
options="$(mktemp -t dukan-export).plist"
cat > "$options" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>teamID</key><string>27RXPRW77S</string>
  <key>signingStyle</key><string>automatic</string>
  <key>destination</key><string>$destination</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST

# Flutter writes the build settings (server address, build number); Xcode archives and signs.
flutter build ios --release --config-only --dart-define=DUKAN_API="$API" --build-number="$BUILD_NUMBER"
archive="$ROOT/app/build/ios/archive/Runner.xcarchive"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$archive" archive \
  -allowProvisioningUpdates ${auth[@]+"${auth[@]}"}
xcodebuild -exportArchive -archivePath "$archive" -exportOptionsPlist "$options" \
  -exportPath "$ROOT/app/build/ios/ipa" -allowProvisioningUpdates ${auth[@]+"${auth[@]}"}
echo "Build $BUILD_NUMBER for $API: $( [ "$destination" = upload ] && echo uploaded to App Store Connect || echo "exported to app/build/ios/ipa" )"
