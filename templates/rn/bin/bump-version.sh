#!/usr/bin/env bash
#
# bump-version.sh
#
# Bump version + buildNumber in app.json, create a commit, and tag the
# new version. Called by `make bump-patch`, `make bump-minor`,
# `make bump-major`.
#
# What gets bumped:
#   - expo.version              (1.0.0 -> 1.0.1 etc.)
#   - expo.ios.buildNumber      ("1" -> "2", string)
#   - expo.android.versionCode  (1 -> 2, integer)
#
# Universal Purchase is NOT supported between iOS and Android in RN, so
# the iOS buildNumber and Android versionCode are kept in lockstep here
# only for convenience — the wizard can split them later if needed.

set -euo pipefail

TYPE="${1:-patch}"

if [ ! -f "app.json" ]; then
  echo "app.json not found. Run from the project root."
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found. Required to parse app.json safely."
  exit 1
fi

# Read current values via Node (JSON-safe; sed would mangle nested quotes).
CURRENT=$(node -e 'console.log(require("./app.json").expo.version)')
BUILD=$(node -e 'console.log(require("./app.json").expo.ios.buildNumber)')
CODE=$(node -e 'console.log(require("./app.json").expo.android.versionCode)')

IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT"

case "$TYPE" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  *) echo "Usage: $0 <patch|minor|major>"; exit 1 ;;
esac

NEW="${MAJOR}.${MINOR}.${PATCH}"
NEW_BUILD=$((BUILD + 1))
NEW_CODE=$((CODE + 1))

# Use Node to rewrite app.json in place; preserves field order under
# the v20+ JSON parser (and any pretty-printing) better than sed.
# Env vars MUST be prefixed before `node` so they reach process.env.
NEW="$NEW" NEW_BUILD="$NEW_BUILD" NEW_CODE="$NEW_CODE" node -e '
  const fs = require("fs");
  const file = "app.json";
  const cfg = JSON.parse(fs.readFileSync(file, "utf8"));
  cfg.expo.version = process.env.NEW;
  cfg.expo.ios.buildNumber = String(process.env.NEW_BUILD);
  cfg.expo.android.versionCode = Number(process.env.NEW_CODE);
  fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + "\n");
'

echo "Bumped ${CURRENT} (build ${BUILD} / code ${CODE}) -> ${NEW} (build ${NEW_BUILD} / code ${NEW_CODE})"

# Only stage + tag if app.json is the only pending change. Avoids
# bundling unrelated work into a "chore(version)" commit.
if [ -z "$(git status --porcelain | grep -v 'app.json')" ]; then
  git add app.json
  git commit -m "chore(version): bump ${TYPE} to ${NEW}"
  git tag "v${NEW}"
  echo "Tagged v${NEW}. Run 'git push --follow-tags' when ready."
else
  echo "Other changes pending — version bumped in file only, not committed."
  echo "Stage, commit, and tag manually."
fi
