#!/usr/bin/env bash
#
# Generic Swift app release-readiness checks. Generated child apps may tune
# APP_TARGET, WIDGET_TARGET, SCREENSHOT_DIR, and RUN_ARCHIVE as their launch
# surface grows.

set -euo pipefail

APP_TARGET="${APP_TARGET:-Seed}"
SCHEME="${SCHEME:-$APP_TARGET}"
PROJECT="${PROJECT:-$APP_TARGET.xcodeproj}"
VERSION_FILE="${VERSION_FILE:-}"
WIDGET_TARGET="${WIDGET_TARGET:-${APP_TARGET}Widgets}"
SCREENSHOT_DIR="${SCREENSHOT_DIR:-Marketing/AppStoreScreenshots/final_real_v1}"
DERIVED_DATA="${DERIVED_DATA:-/private/tmp/${APP_TARGET}-release-check-dd}"
ARCHIVE_PATH="${ARCHIVE_PATH:-/private/tmp/${APP_TARGET}-release-check.xcarchive}"
RUN_ARCHIVE="${RUN_ARCHIVE:-0}"

fail() {
  echo "release-check: $*" >&2
  exit 1
}

if [[ -z "$VERSION_FILE" ]]; then
  for candidate in "$APP_TARGET/Version.xcconfig" */Version.xcconfig Version.xcconfig; do
    if [[ -f "$candidate" ]]; then
      VERSION_FILE="$candidate"
      break
    fi
  done
fi

[[ -n "$VERSION_FILE" && -f "$VERSION_FILE" ]] || fail "Version.xcconfig not found"
[[ -d "$PROJECT" ]] || fail "$PROJECT missing; run make generate first"
command -v xcodegen >/dev/null 2>&1 || fail "xcodegen not found"
command -v xcodebuild >/dev/null 2>&1 || fail "xcodebuild not found"

read_xcconfig_value() {
  local key="$1"
  awk -F '= *' -v key="$key" '$1 ~ "^" key "[[:space:]]*$" { gsub(/[[:space:]]/, "", $2); print $2; exit }' "$VERSION_FILE"
}

setting_value() {
  local file="$1"
  local key="$2"
  awk -F ' = ' -v key="$key" '$1 ~ "^[[:space:]]*" key "$" { value = $2 } END { if (value != "") print value }' "$file"
}

require_setting() {
  local file="$1"
  local target="$2"
  local key="$3"
  local expected="$4"
  local actual
  actual="$(setting_value "$file" "$key")"
  if [[ "$actual" != "$expected" ]]; then
    fail "$target $key expected '$expected', got '${actual:-<empty>}'"
  fi
}

expected_version="$(read_xcconfig_value MARKETING_VERSION)"
expected_build="$(read_xcconfig_value CURRENT_PROJECT_VERSION)"
[[ -n "$expected_version" ]] || fail "MARKETING_VERSION missing from $VERSION_FILE"
[[ -n "$expected_build" ]] || fail "CURRENT_PROJECT_VERSION missing from $VERSION_FILE"

echo "==> Regenerating project"
xcodegen generate

for target in "$APP_TARGET" "$WIDGET_TARGET"; do
  if ! xcodebuild -list -project "$PROJECT" | grep -Eq "^[[:space:]]+$target$"; then
    if [[ "$target" == "$WIDGET_TARGET" ]]; then
      echo "warning: widget target $WIDGET_TARGET not present; skipping widget settings"
      continue
    fi
    fail "target $target not present in $PROJECT"
  fi
  settings_file="$(mktemp)"
  xcodebuild -project "$PROJECT" -target "$target" -configuration Release -showBuildSettings >"$settings_file"
  require_setting "$settings_file" "$target" MARKETING_VERSION "$expected_version"
  require_setting "$settings_file" "$target" CURRENT_PROJECT_VERSION "$expected_build"
  require_setting "$settings_file" "$target" DEVELOPMENT_TEAM YOURTEAMID
  require_setting "$settings_file" "$target" CODE_SIGN_STYLE Automatic
done

if [[ -d "$SCREENSHOT_DIR" ]] && command -v sips >/dev/null 2>&1; then
  echo "==> Checking representative screenshot dimensions"
  while IFS='|' read -r size expected_w expected_h; do
    png="$(find "$SCREENSHOT_DIR" -path "*/${size}/*.png" -type f | head -1)"
    [[ -n "$png" ]] || continue
    width="$(sips -g pixelWidth "$png" 2>/dev/null | awk '/pixelWidth/ { print $2 }')"
    height="$(sips -g pixelHeight "$png" 2>/dev/null | awk '/pixelHeight/ { print $2 }')"
    [[ "$width" == "$expected_w" && "$height" == "$expected_h" ]] || fail "$png expected ${expected_w}x${expected_h}, got ${width:-?}x${height:-?}"
  done <<'SIZES'
iphone-6.9|1320|2868
iphone-6.5|1242|2688
ipad-13|2064|2752
ipad-12.9|2048|2732
SIZES
fi

if [[ "$RUN_ARCHIVE" == "1" ]]; then
  echo "==> Archiving generic iOS app"
  rm -rf "$ARCHIVE_PATH"
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DERIVED_DATA" \
    -archivePath "$ARCHIVE_PATH"
  bin/check-bundle-resources.sh "$ARCHIVE_PATH"
fi

echo "release-check passed: $APP_TARGET ${expected_version} (${expected_build})"
