#!/usr/bin/env bash
#
# verify-rn-template.sh
#
# End-to-end check that templates/rn/ produces a working app. Used by
# CI on every Kindling PR that touches templates/rn/, and locally
# before flipping the Phase 6 box in DECISIONS/005-launch-readiness.md.
#
# Steps:
#   1. Copy templates/rn/ to a scratch directory.
#   2. Substitute the {{APP_NAME}} placeholder (the only one tsc + jest
#      actually reach — i18n strings + paths use no templating).
#   3. npm ci.
#   4. tsc --noEmit.
#   5. jest --ci (the 5 housekeeping tests + any suite-mode tests).
#   6. expo prebuild --no-install --platform ios (config-plugin smoke).
#
# Exit 0 = green. Any non-zero = failure with file:line context.
#
# Skipped automatically on Linux when xcodebuild isn't available;
# Expo prebuild only checks generated-file shape, not native compile.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/templates/rn"
SCRATCH="${VERIFY_DIR:-/tmp/iboot-rn-verify}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "[verify-rn] templates/rn/ not found at $SOURCE_DIR" >&2
  exit 1
fi

for cmd in node npm npx; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[verify-rn] required tool not found: $cmd" >&2
    exit 1
  fi
done

echo "[verify-rn] preparing $SCRATCH"
rm -rf "$SCRATCH"
mkdir -p "$SCRATCH"
# Copy the template, then drop any build artefacts. They're gitignored
# so a clean checkout won't have them, but a local run might — and we
# want a pristine scratch copy either way. (cp, not rsync: rsync isn't
# guaranteed on minimal CI runners or sandboxes.)
cp -R "$SOURCE_DIR/." "$SCRATCH/"
rm -rf "$SCRATCH/node_modules" "$SCRATCH/ios" "$SCRATCH/android" \
       "$SCRATCH/.expo" "$SCRATCH/dist"

cd "$SCRATCH"

echo "[verify-rn] substituting placeholders"
# Substitute just enough to make tsc + jest happy. CLAUDE.md / README
# stay templated — they don't affect compile or runtime. The Swift
# bridge's `SyncConfig.appNamespace` keeps its literal "Seed" default;
# the wizard rewrites it at /new-app --commit time.
APP_NAME="VerifyApp"
node - <<EOF
const fs = require("fs");
const cfg = JSON.parse(fs.readFileSync("app.json", "utf8"));
cfg.expo.name = "$APP_NAME";
fs.writeFileSync("app.json", JSON.stringify(cfg, null, 2) + "\n");
EOF

echo "[verify-rn] npm ci"
npm ci --no-audit --no-fund

echo "[verify-rn] typecheck"
npx tsc --noEmit

echo "[verify-rn] jest"
npx jest --ci --reporters=default --no-watchman

echo "[verify-rn] expo prebuild (iOS dry-run)"
# --no-install avoids cocoapods; we only care that config plugins run.
npx expo prebuild --clean --platform ios --no-install

if [ -d "ios" ]; then
  echo "[verify-rn] iOS prebuild produced ios/ — config plugins ran cleanly."
else
  echo "[verify-rn] expo prebuild did not produce ios/" >&2
  exit 1
fi

echo "[verify-rn] GREEN"
