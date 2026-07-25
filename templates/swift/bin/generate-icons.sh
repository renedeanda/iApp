#!/usr/bin/env bash
#
# generate-icons.sh — wizard plumbing
#
# Render AppIcon.appiconset from a single SVG seed using macOS-builtin
# tools only: qlmanage rasterizes via WebKit, a JPEG round-trip strips
# alpha (required for the App Store 1024), then sips produces every
# pixel size referenced by Contents.json.
#
# Called by `/new-app --commit` after design-icon writes the SVG,
# and by `/generate-icons` after edits to icon_master.svg.
#
# Usage:
#   bin/generate-icons.sh <SVG path> <AppIcon.appiconset path>
#
# Example:
#   bin/generate-icons.sh Seed/Resources/icon_master.svg \
#                        Seed/Assets.xcassets/AppIcon.appiconset

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <SVG path> <AppIcon.appiconset path>" >&2
  exit 2
fi

SVG="$1"
OUT="$2"

[ -f "$SVG" ] || { echo "Error: $SVG not found" >&2; exit 1; }
[ -d "$OUT" ] || { echo "Error: $OUT is not a directory" >&2; exit 1; }

TMP=$(mktemp -d -t generate-icons.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

# Step 1 — qlmanage renders the SVG to PNG via WebKit. -s 1024 sets
# the longest edge; -o writes into our scratch directory.
qlmanage -t -s 1024 -o "$TMP" "$SVG" >/dev/null 2>&1
RAW_PNG="$TMP/$(basename "$SVG").png"
[ -f "$RAW_PNG" ] || { echo "Error: qlmanage failed to render $SVG" >&2; exit 1; }

# Step 2 — JPEG round-trip strips the alpha channel. The App Store 1024
# icon must not have alpha; actool rejects it otherwise.
sips -s format jpeg "$RAW_PNG" --out "$TMP/icon-flat.jpg" >/dev/null
sips -s format png "$TMP/icon-flat.jpg" --out "$TMP/icon-1024.png" >/dev/null
sips -Z 1024 "$TMP/icon-1024.png" >/dev/null

# Step 3 — seven sips resizes producing every pixel size referenced
# by the Kindling-standard Contents.json. Two files share the
# 120px size by design (iPhone 60@2x and iPhone 40@3x).
declare -a SIZES=(
  "1024:icon-1024.png"
  "180:icon-60@3x.png"
  "167:icon-83.5@2x.png"
  "152:icon-76@2x.png"
  "120:icon-60@2x.png"
  "120:icon-40@3x.png"
  "80:icon-40@2x.png"
)

for pair in "${SIZES[@]}"; do
  PX="${pair%%:*}"
  FN="${pair#*:}"
  sips -Z "$PX" "$TMP/icon-1024.png" --out "$OUT/$FN" >/dev/null
done

echo "✓ $OUT — 7 icon variants rendered from $SVG"
ls "$OUT"/*.png | sed 's|^|  |'
