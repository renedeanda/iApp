#!/usr/bin/env bash
#
# init-claude-md.sh — wizard plumbing
#
# Substitute {{PLACEHOLDER}} tokens in CLAUDE.md with ADR-derived
# values. Called by `/new-app --commit` after rename-template.sh, and
# by the `/init` skill if placeholders leak through later.
#
# This is the "Automation" layer (per CLAUDE.md's Maturity matrix) —
# it either succeeds and leaves CLAUDE.md placeholder-free, or exits
# nonzero with a specific list of what's still unfilled. The wizard
# does the value extraction from ADRs; this script does the
# mechanical substitution and validation.
#
# Usage:
#   bin/init-claude-md.sh <CLAUDE.md path> KEY=value [KEY=value ...]
#
# Example:
#   bin/init-claude-md.sh ./CLAUDE.md \
#     APP_NAME=MyApp \
#     MISSION='On-device PDF tools, free tier covers daily use' \
#     VISUAL_IDENTITY=warm-minimal \
#     PALETTE_SEED=Sage \
#     ...

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <CLAUDE.md path> KEY=value [KEY=value ...]" >&2
  exit 2
fi

TARGET="$1"; shift

if [ ! -f "$TARGET" ]; then
  echo "Error: $TARGET not found" >&2
  exit 1
fi

TMP="$(mktemp -t init-claude-md.XXXXXX)"
cp "$TARGET" "$TMP"

for pair in "$@"; do
  if [[ "$pair" != *=* ]]; then
    echo "Error: '$pair' is not KEY=value" >&2
    rm -f "$TMP"
    exit 2
  fi
  KEY="${pair%%=*}"
  VAL="${pair#*=}"
  # Escape characters that have meaning in sed's replacement: backslash,
  # the delimiter (|), and ampersand. Newlines in VAL are passed verbatim
  # since sed handles them.
  ESC_VAL=$(printf '%s' "$VAL" | sed -e 's/[\\&|]/\\&/g')
  sed -e "s|{{${KEY}}}|${ESC_VAL}|g" "$TMP" > "$TMP.next"
  mv "$TMP.next" "$TMP"
done

# Validate: no unfilled {{KEY}} placeholders remain. The literal
# {{PLACEHOLDERS}} string in the file header is documentation, not
# a substitution target — filter it out.
REMAINING=$(grep -oE '\{\{[A-Z_]+\}\}' "$TMP" | grep -v '^{{PLACEHOLDERS}}$' | sort -u || true)

if [ -n "$REMAINING" ]; then
  echo "Error: unfilled placeholders remain in $TARGET:" >&2
  echo "$REMAINING" | sed 's/^/  /' >&2
  echo "" >&2
  echo "Run again with all KEY=value pairs, or check DECISIONS/ for the missing ADR." >&2
  rm -f "$TMP"
  exit 1
fi

mv "$TMP" "$TARGET"
echo "✓ $TARGET — all placeholders substituted"
