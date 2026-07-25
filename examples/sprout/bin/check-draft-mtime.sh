#!/usr/bin/env bash
#
# check-draft-mtime.sh — wizard plumbing (overnight-pause enforcement)
#
# Refuse `/new-app --commit` if the draft folder's mtime is less than
# 12 hours old. The sleep-required rule from CLAUDE.md taste rule 6
# is a soft taste rule until something *enforces* it; this script is
# the ⬜ Automation layer that makes it real.
#
# Usage:
#   bin/check-draft-mtime.sh <drafts/app-name path>
#   bin/check-draft-mtime.sh <drafts/app-name path> --force
#
# Exit codes:
#   0 — draft is ≥ 12h old, proceed
#   0 — --force passed AND addendum written, proceed
#   1 — draft is < 12h old, no --force, refuse
#   2 — usage error
#
# The script does NOT write the addendum itself — it surfaces the
# refusal and tells the wizard how to override. The wizard, having
# called this script and gotten exit 1, can prompt the user, write
# the addendum to 016-spec.md, then re-invoke with --force.

set -euo pipefail

MIN_AGE_SECONDS=$((12 * 60 * 60))  # 12 hours

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

# Get the mtime of the most-recently-modified file in the draft tree.
# The folder's own mtime can lag behind individual file edits; using
# the youngest file is the honest read of "when was this last touched."
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
  echo "  noting the override and the reason. Suggested addendum:"
  echo ""
  echo "    ## Addendum — overnight-pause override ($(date '+%Y-%m-%d %H:%M'))"
  echo ""
  echo "    Draft committed ${AGE_HOURS}h ${AGE_MIN}m after last edit, ${REMAINING_HOURS}h ${REMAINING_MIN}m"
  echo "    short of the 12-hour minimum. User confirmed override via --force."
  echo "    Reason: <wizard fills in from AskUserQuestion>"
  exit 0
fi

REMAINING_HOURS=$(( (MIN_AGE_SECONDS - AGE) / 3600 ))
REMAINING_MIN=$(( ((MIN_AGE_SECONDS - AGE) % 3600) / 60 ))
echo "✗ Draft is only ${AGE_HOURS}h ${AGE_MIN}m old — overnight-pause requires 12h" >&2
echo "  ${REMAINING_HOURS}h ${REMAINING_MIN}m remaining. Come back tomorrow, or rerun with --force" >&2
echo "  (which requires the wizard to write an addendum justifying the override)." >&2
exit 1
