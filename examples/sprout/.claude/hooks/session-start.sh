#!/usr/bin/env bash
# SessionStart hook for child apps generated from the Kindling Swift template.
# Wizard substitutes {{PLACEHOLDERS}} at /new-app --commit time.
set -e

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
PALETTE          ·  {{PALETTE_SEED}} (departure delta in AppTheme.swift)
SIGNATURE MOTION ·  {{SIGNATURE_MOTION}}
TYPOGRAPHY       ·  {{TYPOGRAPHY_SPECIMEN}}
HAPTICS (3/24)   ·  {{HAPTIC_NAMES}}
TIER             ·  {{TIER}}    Universal: {{UNIVERSAL}}

COMMON COMMANDS
  /roadmap            Where to start this session
  /build              xcodebuild build (iPhone 17 Simulator)
  /test               xcodebuild test (all 8 housekeeping tests)
  /generate-icons     Regenerate icons from icon_master.svg
  /translate <lang>   Fill missing translations
  /app-store-graphics Generate App Store screenshots

GUARDRAILS  (see portfolio/REUSE_INDEX.md in the Kindling repo this app came from)
  ✅ Harvest widgets from the template's own SproutWidgets/ scaffold ONLY
  ✅ Apple Intelligence gating: Services/_Disabled/OnDeviceAIService.swift
  ⚠️  Widget/Live-Activity l10n lives in the EXTENSION's own xcstrings
  ⚠️  Only harvest from production-grade sources (REUSE_INDEX discipline)

WHEN IN DOUBT
  CLAUDE.md  →  DECISIONS/  →  the Kindling repo this app was generated from
====================================================================
EOF
