#!/usr/bin/env bash
#
# SessionStart hook for child apps generated from the iApp RN template.
# Two jobs:
#   1) Print a briefing banner so Claude orients fast.
#   2) Bootstrap node_modules so lint/typecheck/jest can run.
#
# Wizard substitutes {{PLACEHOLDERS}} at /new-app --commit time.
# Keep it idempotent and fast (~60s ceiling); push slower work to CI.

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-$PWD}"

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo "unknown")

cat <<EOF
====================================================================
{{APP_NAME}} session — read CLAUDE.md first.

Active branch: ${BRANCH}
Last commit:   ${LAST_COMMIT}

MISSION
  {{MISSION}}

VISUAL IDENTITY  ·  {{VISUAL_IDENTITY}}
PALETTE          ·  {{PALETTE_SEED}} (departure delta in theme/AppTheme.ts)
SIGNATURE MOTION ·  {{SIGNATURE_MOTION}}
TYPOGRAPHY       ·  {{TYPOGRAPHY_SPECIMEN}}
HAPTICS (3 starter) ·  {{HAPTIC_NAMES}}
TIER             ·  {{TIER}}    iOS-only / Android-only / Both: {{PLATFORMS}}

COMMON COMMANDS
  /roadmap            Where to start this session
  /build              expo prebuild --clean && expo run:ios
  /test               jest (5 housekeeping + suite)
  /generate-icons     Regenerate icons from assets/icon_master.svg
  /translate <lang>   Fill missing translations (replaces en-fallback stubs)
  /app-store-graphics Generate App Store screenshots

GUARDRAILS  (see the iApp repo's portfolio/REUSE_INDEX.md)
  ✅ iCloud sync → modules/icloud-sync/ (production-proven pattern, genericized)
  ✅ Rolling-64 notifications → src/services/NotificationService.ts (production-proven)
  ✅ RN widgets (multi-language i18n) → follow the widget-extension recipe
  ⚠️  Never harvest legacy custom CloudKit bridges (superseded by the Expo module)
  ⚠️  No RevenueCat — react-native-iap 12 only
  ⚠️  Universal Purchase NOT supported between iOS and Android in RN

WHEN IN DOUBT
  CLAUDE.md  →  DECISIONS/  →  iApp repo
====================================================================
EOF

echo "[session-start] node $(node --version 2>/dev/null || echo 'missing'), npm $(npm --version 2>/dev/null || echo 'missing')"

if [ -f "package-lock.json" ]; then
  if [ ! -d "node_modules" ] || [ "package-lock.json" -nt "node_modules/.package-lock.json" ]; then
    echo "[session-start] installing dependencies via npm ci..."
    npm ci --no-audit --no-fund
  else
    echo "[session-start] node_modules up to date — skipping install."
  fi
fi

if [ -f "app.json" ] && [ ! -d "ios" ] && [ ! -d "android" ]; then
  echo "[session-start] Native dirs absent — run \`npx expo prebuild\` if you need to inspect generated projects."
fi

echo "[session-start] ready."
