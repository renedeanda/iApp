#!/usr/bin/env bash
#
# One-command iOS archive for Swift/XcodeGen apps.
#
# Defaults match the generated template. Existing portfolio apps can override
# app-specific details without editing this file:
#
#   SCHEME=MyApp PROJECT=MyApp.xcodeproj \
#   ARCHIVE_PRE_CMD="../native-lib/build-ios.sh release" make archive
#
# Useful env:
#   APP_TARGET, SCHEME, PROJECT, WORKSPACE, CONFIGURATION, DESTINATION
#   ARCHIVE_PATH, DERIVED_DATA, ARCHIVE_PRE_CMD, ARCHIVE_POST_CMD
#   RUN_XCODEGEN=0, RUN_RELEASE_CHECK=0, OPEN_ARCHIVE=0
#   DEVELOPMENT_TEAM, EXPORT_FOR_APP_STORE=0, EXPORT_PATH,
#   EXPORT_OPTIONS_PLIST, VERIFY_EXPORT_PROFILES=0,
#   LOCALIZATION_EXEMPT_EXTENSIONS="NonVisualExtension.appex"

set -euo pipefail
cd "$(dirname "$0")/.."

APP_TARGET="${APP_TARGET:-Sprout}"
SCHEME="${SCHEME:-$APP_TARGET}"
PROJECT="${PROJECT:-$APP_TARGET.xcodeproj}"
WORKSPACE="${WORKSPACE:-}"
CONFIGURATION="${CONFIGURATION:-Release}"
DESTINATION="${DESTINATION:-generic/platform=iOS}"
DERIVED_DATA="${DERIVED_DATA:-/private/tmp/${APP_TARGET}-archive-dd}"
ARCHIVE_PATH="${ARCHIVE_PATH:-build/${APP_TARGET}.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-build/export/${APP_TARGET}}"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-}"
ARCHIVE_PRE_CMD="${ARCHIVE_PRE_CMD:-}"
ARCHIVE_POST_CMD="${ARCHIVE_POST_CMD:-}"
RUN_XCODEGEN="${RUN_XCODEGEN:-1}"
RUN_RELEASE_CHECK="${RUN_RELEASE_CHECK:-1}"
OPEN_ARCHIVE="${OPEN_ARCHIVE:-1}"
ALLOW_PROVISIONING_UPDATES="${ALLOW_PROVISIONING_UPDATES:-1}"
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-YOURTEAMID}"
EXPORT_FOR_APP_STORE="${EXPORT_FOR_APP_STORE:-1}"
VERIFY_EXPORT_PROFILES="${VERIFY_EXPORT_PROFILES:-1}"

fail() {
  echo "archive-ios: $*" >&2
  exit 1
}

run_hook() {
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
  bin/check-bundle-resources.sh "$unpack_dir/Payload"
  verify_profiles_under "$unpack_dir/Payload" "exported IPA"
  rm -rf "$unpack_dir"

  echo "archive-ios: exported $ipa_path"
}

command -v xcodebuild >/dev/null 2>&1 || fail "xcodebuild not found"

if [[ "$RUN_XCODEGEN" == "1" && -f project.yml ]]; then
  command -v xcodegen >/dev/null 2>&1 || fail "xcodegen not found; install it or set RUN_XCODEGEN=0"
  echo "==> Regenerating Xcode project"
  xcodegen generate
fi

run_hook "Running pre-archive hook" "$ARCHIVE_PRE_CMD"

if [[ "$RUN_RELEASE_CHECK" == "1" && -x bin/release-check.sh ]]; then
  echo "==> Running release preflight"
  RUN_ARCHIVE=0 APP_TARGET="$APP_TARGET" SCHEME="$SCHEME" PROJECT="$PROJECT" bin/release-check.sh
fi

build_ref=()
if [[ -n "$WORKSPACE" ]]; then
  [[ -d "$WORKSPACE" ]] || fail "workspace not found: $WORKSPACE"
  build_ref=(-workspace "$WORKSPACE")
else
  [[ -d "$PROJECT" ]] || fail "project not found: $PROJECT"
  build_ref=(-project "$PROJECT")
fi

mkdir -p "$(dirname "$ARCHIVE_PATH")"
rm -rf "$ARCHIVE_PATH"

provisioning_args=()
if [[ "$ALLOW_PROVISIONING_UPDATES" == "1" ]]; then
  provisioning_args=(-allowProvisioningUpdates)
fi

echo "==> Archiving $SCHEME ($CONFIGURATION)"
xcodebuild archive \
  "${build_ref[@]}" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -archivePath "$ARCHIVE_PATH" \
  "${provisioning_args[@]}"

echo "==> Verifying archive bundle resources"
bin/check-bundle-resources.sh "$ARCHIVE_PATH"

export_archive_for_app_store
run_hook "Running post-archive hook" "$ARCHIVE_POST_CMD"

echo "archive-ios: created $ARCHIVE_PATH"
if [[ "$OPEN_ARCHIVE" == "1" ]]; then
  open "$ARCHIVE_PATH"
fi
