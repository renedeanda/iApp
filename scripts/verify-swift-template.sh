#!/usr/bin/env bash
#
# verify-swift-template.sh
#
# End-to-end check that templates/swift/ produces a working app. The
# Swift counterpart to verify-rn-template.sh. Used by the manual
# `verify-swift-template` CI job and locally before flipping a phase
# box in DECISIONS/005-launch-readiness.md.
#
# Steps:
#   1. Copy templates/swift/ to a scratch directory.
#   2. Rename Seed -> VerifyApp via bin/rename-template.sh.
#   3. xcodegen generate.
#   4. xcodebuild build — iOS Simulator.
#   5. xcodebuild build — macOS.
#   6. xcodebuild test  — iOS Simulator (the 8 housekeeping tests +
#      any feature tests).
#
# Requires macOS + Xcode + xcodegen. On a non-macOS host (Linux CI,
# sandboxes) it exits 0 with a SKIPPED note — the static-shape checks
# that CAN run on Linux live in the `verify-recipes` job and in
# validate-template's Kindling-specific checks; the compile/test
# loop genuinely needs a Mac.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/templates/swift"
SCRATCH="${VERIFY_DIR:-/tmp/iboot-swift-verify}"
APP_NAME="${APP_NAME:-VerifyApp}"
BUNDLE_ID="${BUNDLE_ID:-com.example.verifyapp}"
IOS_DEST="${IOS_DEST:-platform=iOS Simulator,name=iPhone 17 Pro}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "[verify-swift] templates/swift/ not found at $SOURCE_DIR" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "[verify-swift] xcodebuild not found — this script requires macOS + Xcode."
  echo "[verify-swift] SKIPPED (run on a macOS host or the macOS CI runner)."
  exit 0
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "[verify-swift] xcodegen not found — install via 'brew install xcodegen'." >&2
  exit 1
fi

echo "[verify-swift] preparing $SCRATCH"
rm -rf "$SCRATCH"
mkdir -p "$SCRATCH"
cp -R "$SOURCE_DIR/." "$SCRATCH/"
rm -rf "$SCRATCH/DerivedData" "$SCRATCH"/*.xcodeproj

cd "$SCRATCH"

echo "[verify-swift] renaming Seed -> $APP_NAME ($BUNDLE_ID)"
./bin/rename-template.sh "$APP_NAME" "$BUNDLE_ID"

echo "[verify-swift] xcodegen generate"
xcodegen generate

# -derivedDataPath keeps every run hermetic: the global
# ~/Library/Developer/Xcode/DerivedData is shared across projects and
# survives between runs, so a failed build there can poison the module
# cache for the next run. A scratch-local DerivedData is wiped with the
# scratch dir above.
DERIVED_DATA="$SCRATCH/DerivedData"

# CODE_SIGNING_ALLOWED=NO: the scaffold has no DEVELOPMENT_TEAM (the
# wizard injects it at /new-app --commit). Simulator builds don't need
# signing; macOS builds otherwise fail asking for a team. Matches the
# template's own .github/workflows/ci.yml.
echo "[verify-swift] xcodebuild build — iOS Simulator"
xcodebuild build -scheme "$APP_NAME" -destination "$IOS_DEST" \
  -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO -quiet

echo "[verify-swift] xcodebuild build — macOS"
xcodebuild build -scheme "$APP_NAME" -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO -quiet

echo "[verify-swift] xcodebuild test — iOS Simulator (8 housekeeping + feature tests)"
xcodebuild test -scheme "$APP_NAME" -destination "$IOS_DEST" \
  -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO -quiet

echo "[verify-swift] validating archive bundle-resource guard"
APP_PRODUCT="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/$APP_NAME.app"
FIXTURE_EXTENSION="$APP_PRODUCT/PlugIns/LocalizationFixture.appex"
mkdir -p "$FIXTURE_EXTENSION/en.lproj"
cp "$APP_PRODUCT/en.lproj/Localizable.strings" "$FIXTURE_EXTENSION/en.lproj/Localizable.strings"
cp "$APP_NAME/PrivacyInfo.xcprivacy" "$FIXTURE_EXTENSION/PrivacyInfo.xcprivacy"
./bin/check-bundle-resources.sh "$APP_PRODUCT"
rm "$FIXTURE_EXTENSION/en.lproj/Localizable.strings"
if ./bin/check-bundle-resources.sh "$APP_PRODUCT" >/dev/null 2>&1; then
  echo "[verify-swift] bundle-resource guard accepted an extension without localization" >&2
  exit 1
fi

echo "[verify-swift] GREEN — both platforms build, all tests pass."
