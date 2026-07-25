#!/usr/bin/env bash
#
# bump-version.sh
#
# Bump MARKETING_VERSION (+ CURRENT_PROJECT_VERSION) in Version.xcconfig,
# create a commit, and tag the new version. Called by `make bump-patch`,
# `make bump-minor`, `make bump-major`.

set -euo pipefail

TYPE="${1:-patch}"

# Locate Version.xcconfig — the template's pre-rename path is
# Sprout/Version.xcconfig; post-rename it's <AppName>/Version.xcconfig.
XCCONFIG=""
for candidate in Sprout/Version.xcconfig */Version.xcconfig; do
  if [ -f "$candidate" ]; then
    XCCONFIG="$candidate"
    break
  fi
done

if [ -z "$XCCONFIG" ]; then
  echo "Version.xcconfig not found. Run from the project root."
  exit 1
fi

CURRENT=$(grep '^MARKETING_VERSION' "$XCCONFIG" | awk -F'= *' '{print $2}' | tr -d ' ')
BUILD=$(grep '^CURRENT_PROJECT_VERSION' "$XCCONFIG" | awk -F'= *' '{print $2}' | tr -d ' ')

IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT"

case "$TYPE" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  *) echo "Usage: $0 <patch|minor|major>"; exit 1 ;;
esac

NEW="${MAJOR}.${MINOR}.${PATCH}"
NEW_BUILD=$((BUILD + 1))

sed -i.bak \
    -e "s|^MARKETING_VERSION = .*|MARKETING_VERSION = ${NEW}|" \
    -e "s|^CURRENT_PROJECT_VERSION = .*|CURRENT_PROJECT_VERSION = ${NEW_BUILD}|" \
    "$XCCONFIG"
rm -f "${XCCONFIG}.bak"

echo "Bumped ${CURRENT} (build ${BUILD}) -> ${NEW} (build ${NEW_BUILD})"

# Only stage + tag if inside a clean working tree on the version file
# alone. Avoid surprise commits if other changes are pending.
if [ -z "$(git status --porcelain | grep -v "$XCCONFIG")" ]; then
  git add "$XCCONFIG"
  git commit -m "chore(version): bump ${TYPE} to ${NEW}"
  git tag "v${NEW}"
  echo "Tagged v${NEW}. Run 'git push --follow-tags' when ready."
else
  echo "Other changes pending — version bumped in file only, not committed."
  echo "Stage, commit, and tag manually."
fi
