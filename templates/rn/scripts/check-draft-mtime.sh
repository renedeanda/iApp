#!/usr/bin/env bash
#
# check-draft-mtime.sh — wizard plumbing (overnight-pause enforcement)
#
# Identical-behavior twin of templates/swift/bin/check-draft-mtime.sh,
# placed at templates/rn/scripts/ because RN projects use scripts/
# rather than bin/ by convention. The wizard invokes whichever copy
# matches the tech choice in ADR 001.
#
# See templates/swift/bin/check-draft-mtime.sh for the full header.

set -euo pipefail

MIN_AGE_SECONDS=$((12 * 60 * 60))

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <drafts/app-name path> [--force]" >&2
  exit 2
fi

DRAFT="$1"
FORCE="${2:-}"

if [ ! -d "$DRAFT" ]; then
  echo "Error: $DRAFT not found or not a directory" >&2
  exit 2
fi

if [ -n "$FORCE" ] && [ "$FORCE" != "--force" ]; then
  echo "Error: unknown second argument '$FORCE' (expected --force)" >&2
  exit 2
fi

YOUNGEST=$(find "$DRAFT" -type f -print0 | xargs -0 stat -f '%m' | sort -nr | head -1)

if [ -z "$YOUNGEST" ]; then
  echo "Error: $DRAFT is empty — nothing to commit" >&2
  exit 1
fi

NOW=$(date +%s)
AGE=$((NOW - YOUNGEST))
AGE_HOURS=$((AGE / 3600))
AGE_MIN=$(( (AGE % 3600) / 60 ))

if [ "$AGE" -ge "$MIN_AGE_SECONDS" ]; then
  echo "✓ Draft is ${AGE_HOURS}h ${AGE_MIN}m old — overnight-pause satisfied"
  exit 0
fi

if [ "$FORCE" = "--force" ]; then
  REMAINING_HOURS=$(( (MIN_AGE_SECONDS - AGE) / 3600 ))
  REMAINING_MIN=$(( ((MIN_AGE_SECONDS - AGE) % 3600) / 60 ))
  echo "⚠ Draft is ${AGE_HOURS}h ${AGE_MIN}m old — --force overrides ${REMAINING_HOURS}h ${REMAINING_MIN}m of remaining pause"
  echo ""
  echo "  The wizard must write an addendum to ${DRAFT}/DECISIONS/016-spec.md"
  echo "  noting the override and the reason."
  exit 0
fi

REMAINING_HOURS=$(( (MIN_AGE_SECONDS - AGE) / 3600 ))
REMAINING_MIN=$(( ((MIN_AGE_SECONDS - AGE) % 3600) / 60 ))
echo "✗ Draft is only ${AGE_HOURS}h ${AGE_MIN}m old — overnight-pause requires 12h" >&2
echo "  ${REMAINING_HOURS}h ${REMAINING_MIN}m remaining. Come back tomorrow, or rerun with --force." >&2
exit 1
