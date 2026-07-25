#!/usr/bin/env bash
#
# render-sprout-example.sh
#
# Regenerates examples/sprout/ — the worked-example app rendered from
# templates/swift the same way /new-app --commit would: rename-template,
# palette departure applied, CLAUDE.md placeholders filled. The example's
# DECISIONS/ (the worked ADRs) and EXAMPLE.md are hand-written and
# preserved across regeneration.
#
# Run from the repo root after any templates/swift change so the example
# never drifts:   bash scripts/render-sprout-example.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EX="$ROOT/examples/sprout"
KEEP="$(mktemp -d)"

# Preserve hand-written files across regeneration.
for f in DECISIONS EXAMPLE.md; do
  [ -e "$EX/$f" ] && mv "$EX/$f" "$KEEP/"
done

rm -rf "$EX"
mkdir -p "$ROOT/examples"
cp -r "$ROOT/templates/swift" "$EX"

# 1. Rename Seed -> Sprout exactly as the wizard does.
( cd "$EX" && bash bin/rename-template.sh Sprout com.example.sprout )

# 2. Apply the palette: Sage seed, departed (see DECISIONS/002-palette.md).
#    Surface cooled 6 degrees toward blue; accent desaturated ~12% from seed moss.
THEME="$EX/Sprout/Theme/AppTheme.swift"
sed -i.bak \
  -e 's/dynamic(light: 0xF7F2EA, dark: 0x1B1712)/dynamic(light: 0xE8EBE3, dark: 0x181B14)/' \
  -e 's/dynamic(light: 0xEFE7D8, dark: 0x272019)/dynamic(light: 0xDADFD2, dark: 0x242821)/' \
  -e 's/dynamic(light: 0xE8DEC9, dark: 0x342B20)/dynamic(light: 0xC8CFC0, dark: 0x30352C)/' \
  -e 's/dynamic(light: 0x2A2520, dark: 0xF0E9DC)/dynamic(light: 0x21261E, dark: 0xE4E8DF)/' \
  -e 's/dynamic(light: 0x5A4F45, dark: 0xA89C88)/dynamic(light: 0x5A6051, dark: 0xA8B0A0)/' \
  -e 's/dynamic(light: 0x9E5A35, dark: 0xCE8C5A)/dynamic(light: 0x5F7A55, dark: 0x93AC89)/' \
  -e 's/dynamic(light: 0x744228, dark: 0xE3AE82)/dynamic(light: 0x46603F, dark: 0xB2C7A9)/' \
  -e 's/warm copper/departed Sage moss/' \
  "$THEME"
rm -f "$THEME.bak"

# 3. Fill the CLAUDE.md placeholders the init skill would substitute.
CMD="$EX/CLAUDE.md"
python3 - "$CMD" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
subs = {
  "{{APP_NAME}}": "Sprout",
  "{{MISSION}}": "Tiny daily wins, logged in five seconds, growing into proof.",
  "{{VISUAL_IDENTITY}}": "Warm-minimal",
  "{{PALETTE_SEED}}": "Sage",
  "{{PALETTE_TOKENS}}": "Surface `#E8EBE3` / `#181B14` · OnSurface `#21261E` / `#E4E8DF` · Accent `#5F7A55` / `#93AC89` (Sage, departed: surface cooled 6°, accent desaturated ~12%).",
  "{{SIGNATURE_MOTION}}": "Breathing (template default, kept deliberately)",
  "{{TYPOGRAPHY_SPECIMEN}}": "Rounded-system",
  "{{HAPTIC_NAMES}}": "bloomOpen · completionRing · reminderSoft",
  "{{DELIGHT_MOMENTS}}": "Result reveal on logging a win · celebration pop on a 7-day run · breathing idle tile.",
  "{{TIER}}": "0 — pure free (no infra costs; the gift tier)",
  "{{UNIVERSAL}}": "iOS-only. No Mac Catalyst — the five-second log is a pocket gesture.",
}
for k, v in subs.items():
    s = s.replace(k, v)
open(p, "w").write(s)
PY

# Slim the example AFTER the render is complete (the rename script
# walks these dirs, so they must exist while it runs): agent-skill
# mirrors, hooks, and per-app CI ship with real rendered apps but are
# noise in a browsing example — and would pollute agent skill discovery
# in sessions opened at the repo root. The template remains the
# reference for the complete render.
rm -rf "$EX/.claude" "$EX/.agents" "$EX/.github" "$EX/.githooks"

# Restore hand-written files.
for f in DECISIONS EXAMPLE.md; do
  [ -e "$KEEP/$f" ] && mv "$KEEP/$f" "$EX/"
done
rmdir "$KEEP" 2>/dev/null || true

# Guard: no placeholders may survive ({{PLACEHOLDERS}} is the header's
# literal documentation of the mechanism, not an unfilled token).
if grep -rn '{{[A-Z_]*}}' "$EX" --include='CLAUDE.md' | grep -v '{{PLACEHOLDERS}}'; then
  echo "[render-sprout] FAILED: unfilled placeholders remain" >&2
  exit 1
fi
echo "[render-sprout] examples/sprout regenerated."
