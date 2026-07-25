#!/usr/bin/env bash
#
# Validates the actual app/archive/IPA payload rather than trusting project
# source shape. Extension bundles do not inherit host localization resources.

set -euo pipefail
shopt -s nullglob

artifact_path="${1:-}"
development_language="${DEVELOPMENT_LANGUAGE:-en}"
localization_exempt_extensions="${LOCALIZATION_EXEMPT_EXTENSIONS:-}"

fail() {
  echo "bundle-resources: $*" >&2
  exit 1
}

[[ -n "$artifact_path" ]] || fail "usage: $0 <App.app|App.xcarchive|Payload-directory>"

if [[ "$artifact_path" == *.xcarchive ]]; then
  app_candidates=("$artifact_path"/Products/Applications/*.app)
elif [[ "$artifact_path" == *.app ]]; then
  app_candidates=("$artifact_path")
elif [[ -d "$artifact_path/Payload" ]]; then
  app_candidates=("$artifact_path"/Payload/*.app)
elif [[ -d "$artifact_path" ]]; then
  app_candidates=("$artifact_path"/*.app)
else
  fail "artifact not found: $artifact_path"
fi

[[ ${#app_candidates[@]} -eq 1 && -d "${app_candidates[0]}" ]] || \
  fail "expected exactly one host app under $artifact_path"
app_path="${app_candidates[0]}"

locales_for_table() {
  local bundle_path="$1"
  local table_name="$2"
  local table_path
  local paths=("$bundle_path"/*.lproj/"$table_name.strings")

  for table_path in "${paths[@]}"; do
    [[ -f "$table_path" ]] || continue
    basename "$(dirname "$table_path")" .lproj
  done | LC_ALL=C sort
}

extension_is_exempt() {
  local extension_name="$1"
  local exempt_name
  for exempt_name in $localization_exempt_extensions; do
    [[ "$extension_name" == "$exempt_name" ]] && return 0
  done
  return 1
}

check_metadata_keys() {
  local bundle_path="$1"
  local metadata_path="$bundle_path/Metadata.appintents/extract.actionsdata"
  [[ -f "$metadata_path" ]] || return 0

  local semantic_keys
  semantic_keys="$({
    grep -Eo '"key"[[:space:]]*:[[:space:]]*"[a-z][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+"' "$metadata_path" || true
  } | sed -E 's/^"key"[[:space:]]*:[[:space:]]*"//; s/"$//' | LC_ALL=C sort -u)"

  local key
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    local key_path="${key//./\\.}"
    local resolved=0
    local table_path
    local table_paths=("$bundle_path/$development_language.lproj"/*.strings)

    for table_path in "${table_paths[@]}"; do
      [[ -f "$table_path" ]] || continue
      local value
      if value="$(plutil -extract "$key_path" raw -o - "$table_path" 2>/dev/null)"; then
        if [[ -n "$value" && "$value" != "$key" ]]; then
          resolved=1
          break
        fi
      fi
    done

    [[ "$resolved" == "1" ]] || \
      fail "$(basename "$bundle_path") App Intents metadata key is unresolved: $key"
  done <<< "$semantic_keys"
}

host_locales="$(locales_for_table "$app_path" Localizable)"
[[ -n "$host_locales" ]] || fail "host app has no compiled Localizable.strings tables"
check_metadata_keys "$app_path"

extension_paths=("$app_path"/PlugIns/*.appex)
for extension_path in "${extension_paths[@]}"; do
  [[ -d "$extension_path" ]] || continue
  extension_name="$(basename "$extension_path")"

  [[ -f "$extension_path/PrivacyInfo.xcprivacy" ]] || \
    fail "$extension_name is missing its own PrivacyInfo.xcprivacy"

  if ! extension_is_exempt "$extension_name"; then
    extension_locales="$(locales_for_table "$extension_path" Localizable)"
    [[ -n "$extension_locales" ]] || \
      fail "$extension_name has no compiled Localizable.strings tables; add its own catalog or declare an explicit exemption"
    [[ "$extension_locales" == "$host_locales" ]] || \
      fail "$extension_name Localizable.strings locale set does not match the host app"
  fi

  check_metadata_keys "$extension_path"
done

echo "bundle-resources: localization tables, App Intents metadata, and extension privacy manifests passed"
