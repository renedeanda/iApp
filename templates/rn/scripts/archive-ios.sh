#!/usr/bin/env bash
#
# One-command iOS archive for Expo/React Native apps.
#
# Defaults mirror the portfolio production path:
#   1. expo prebuild --clean for iOS
#   2. pod install
#   3. xcodebuild archive with Automatic signing
#   4. xcodebuild -exportArchive for App Store Connect signing
#   5. verify exported app/extension profiles are upload-safe
#   6. open the archive in Xcode Organizer
#
# Useful env:
#   APP_NAME, IOS_DIR, SCHEME, WORKSPACE, ARCHIVE_PATH, DERIVED_DATA
#   EXPO_PREBUILD_CMD, POD_INSTALL_CMD, ARCHIVE_PRE_CMD, ARCHIVE_POST_CMD
#   RUN_PREBUILD=0, RUN_PODS=0, OPEN_ARCHIVE=0
#   DEVELOPMENT_TEAM, EXPORT_FOR_APP_STORE=0, EXPORT_PATH,
#   EXPORT_OPTIONS_PLIST, VERIFY_EXPORT_PROFILES=0

set -euo pipefail
cd "$(dirname "$0")/.."

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export EXPO_NO_TELEMETRY="${EXPO_NO_TELEMETRY:-1}"

APP_NAME="${APP_NAME:-Seed}"
IOS_DIR="${IOS_DIR:-ios}"
SCHEME="${SCHEME:-$APP_NAME}"
WORKSPACE="${WORKSPACE:-$IOS_DIR/${APP_NAME}.xcworkspace}"
CONFIGURATION="${CONFIGURATION:-Release}"
DESTINATION="${DESTINATION:-generic/platform=iOS}"
DERIVED_DATA="${DERIVED_DATA:-/private/tmp/${APP_NAME}-archive-dd}"
ARCHIVE_PATH="${ARCHIVE_PATH:-build/${APP_NAME}.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-build/export/${APP_NAME}}"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-}"
EXPO_PREBUILD_CMD="${EXPO_PREBUILD_CMD:-npx expo prebuild --platform ios --clean}"
POD_INSTALL_CMD="${POD_INSTALL_CMD:-pod install --project-directory=$IOS_DIR}"
ARCHIVE_PRE_CMD="${ARCHIVE_PRE_CMD:-}"
ARCHIVE_POST_CMD="${ARCHIVE_POST_CMD:-}"
RUN_PREBUILD="${RUN_PREBUILD:-1}"
RUN_PODS="${RUN_PODS:-1}"
OPEN_ARCHIVE="${OPEN_ARCHIVE:-1}"
ALLOW_PROVISIONING_UPDATES="${ALLOW_PROVISIONING_UPDATES:-1}"
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-YOURTEAMID}"
EXPORT_FOR_APP_STORE="${EXPORT_FOR_APP_STORE:-1}"
VERIFY_EXPORT_PROFILES="${VERIFY_EXPORT_PROFILES:-1}"

fail() {
  echo "archive-ios: $*" >&2
  exit 1
}

run_cmd() {
  local label="$1"
  local command="$2"
  [[ -z "$command" ]] && return 0
  echo "==> $label"
  "${SHELL:-/bin/bash}" -lc "$command"
}

write_export_options_plist() {
  local plist="$1"
  cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>destination</key>
  <string>export</string>
  <key>manageAppVersionAndBuildNumber</key>
  <false/>
  <key>method</key>
  <string>app-store-connect</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>teamID</key>
  <string>$DEVELOPMENT_TEAM</string>
  <key>uploadSymbols</key>
  <true/>
</dict>
</plist>
PLIST
}

verify_profiles_under() {
  local search_root="$1"
  local label="$2"
  [[ "$VERIFY_EXPORT_PROFILES" == "1" ]] || return 0
  [[ -d "$search_root" ]] || fail "$label profile root not found: $search_root"

  local profiles=()
  while IFS= read -r profile; do
    profiles+=("$profile")
  done < <(find "$search_root" -name embedded.mobileprovision -print)

  [[ "${#profiles[@]}" -gt 0 ]] || fail "$label has no embedded.mobileprovision files to verify"

  local temp_dir
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/export-profiles.XXXXXX")"
  local failures=0
  local index=0

  for profile in "${profiles[@]}"; do
    index=$((index + 1))
    local plist="$temp_dir/profile-$index.plist"
    local bundle_path="${profile#$search_root/}"
    bundle_path="${bundle_path%/embedded.mobileprovision}"

    if ! security cms -D -i "$profile" > "$plist" 2>/dev/null; then
      rm -rf "$temp_dir"
      fail "could not decode provisioning profile: $profile"
    fi

    local profile_name app_identifier
    profile_name="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$plist" 2>/dev/null || true)"
    app_identifier="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$plist" 2>/dev/null || true)"

    if /usr/libexec/PlistBuddy -c 'Print :ProvisionedDevices' "$plist" >/dev/null 2>&1; then
      echo "archive-ios: ERROR $label $bundle_path uses a device/development profile: $profile_name ($app_identifier)" >&2
      failures=$((failures + 1))
    else
      echo "archive-ios: OK $label $bundle_path uses distribution-style profile: $profile_name"
    fi
  done

  rm -rf "$temp_dir"
  [[ "$failures" -eq 0 ]] || fail "$label contains non-App-Store provisioning profiles"
}

verify_bundles_have_executables() {
  local search_root="$1"
  local label="$2"
  [[ -d "$search_root" ]] || fail "$label executable root not found: $search_root"

  local failures=0
  while IFS= read -r bundle; do
    local info_plist="$bundle/Info.plist"
    [[ -f "$info_plist" ]] || continue

    local executable bundle_id relative_path
    executable="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$info_plist" 2>/dev/null || true)"
    bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$info_plist" 2>/dev/null || true)"
    relative_path="${bundle#$search_root/}"

    if [[ -z "$executable" || ! -f "$bundle/$executable" ]]; then
      echo "archive-ios: ERROR $label $relative_path ($bundle_id) has no executable named '$executable'" >&2
      echo "archive-ios:        For widgets/extensions, this usually means the generated target has an empty Sources phase." >&2
      failures=$((failures + 1))
    fi
  done < <(find "$search_root" \( -name '*.app' -o -name '*.appex' \) -type d -print)

  [[ "$failures" -eq 0 ]] || fail "$label contains bundles without executables"
}

export_archive_for_app_store() {
  [[ "$EXPORT_FOR_APP_STORE" == "1" ]] || return 0

  local options_plist="$EXPORT_OPTIONS_PLIST"
  local remove_options=0
  if [[ -z "$options_plist" ]]; then
    options_plist="$(mktemp "${TMPDIR:-/tmp}/export-options.XXXXXX.plist")"
    remove_options=1
    write_export_options_plist "$options_plist"
  fi

  rm -rf "$EXPORT_PATH"
  mkdir -p "$EXPORT_PATH"

  echo "==> Exporting App Store Connect IPA"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$options_plist" \
    "${provisioning_args[@]}"

  if [[ "$remove_options" == "1" ]]; then
    rm -f "$options_plist"
  fi

  local ipa_path
  ipa_path="$(find "$EXPORT_PATH" -maxdepth 1 -name '*.ipa' -print -quit)"
  [[ -n "$ipa_path" ]] || fail "export did not produce an .ipa in $EXPORT_PATH"

  local unpack_dir
  unpack_dir="$(mktemp -d "${TMPDIR:-/tmp}/exported-ipa.XXXXXX")"
  /usr/bin/unzip -q "$ipa_path" -d "$unpack_dir"
  verify_bundles_have_executables "$unpack_dir/Payload" "exported IPA"
  verify_profiles_under "$unpack_dir/Payload" "exported IPA"
  rm -rf "$unpack_dir"

  echo "archive-ios: exported $ipa_path"
}

command -v xcodebuild >/dev/null 2>&1 || fail "xcodebuild not found"

if [[ "$RUN_PREBUILD" == "1" ]]; then
  run_cmd "Expo prebuild" "$EXPO_PREBUILD_CMD"
fi

if [[ "$RUN_PODS" == "1" ]]; then
  command -v pod >/dev/null 2>&1 || fail "pod not found; install CocoaPods or set RUN_PODS=0"
  run_cmd "CocoaPods install" "$POD_INSTALL_CMD"
fi

run_cmd "Running pre-archive hook" "$ARCHIVE_PRE_CMD"

[[ -d "$WORKSPACE" ]] || fail "workspace not found: $WORKSPACE"
mkdir -p "$(dirname "$ARCHIVE_PATH")"
rm -rf "$ARCHIVE_PATH"

provisioning_args=()
if [[ "$ALLOW_PROVISIONING_UPDATES" == "1" ]]; then
  provisioning_args=(-allowProvisioningUpdates)
fi

echo "==> Archiving $SCHEME ($CONFIGURATION)"
xcodebuild archive \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -archivePath "$ARCHIVE_PATH" \
  "${provisioning_args[@]}" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  CODE_SIGN_STYLE=Automatic

export_archive_for_app_store
run_cmd "Running post-archive hook" "$ARCHIVE_POST_CMD"

echo "archive-ios: created $ARCHIVE_PATH"
if [[ "$OPEN_ARCHIVE" == "1" ]]; then
  open "$ARCHIVE_PATH"
fi
