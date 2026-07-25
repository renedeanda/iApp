#!/usr/bin/env bash
#
# check-recipe-sources.sh
#
# Recipe-accuracy gate. Every recipe in recipes/**/*.md cites its
# gold-standard source as an in-repo path (templates/..., docs/...,
# .claude/skills/..., tools/..., scripts/..., portfolio/...). This
# script:
#
#   1. Extracts every backtick-wrapped in-repo path from the recipes.
#   2. Verifies each path exists in this repo — catching renames and
#      typos before they ship a dead pointer (the realistic failure
#      mode when a template file moves).
#
# _TEMPLATE.md is skipped (its paths are placeholders by design).
# Tokens containing placeholders or globs (<App>, {var}, *, ...) are
# skipped — they're illustrative, not concrete citations.
#
# Exit 0 = clean. Non-zero = at least one cited path does not exist.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RECIPES_DIR="$REPO_ROOT/recipes"

if [ ! -d "$RECIPES_DIR" ]; then
  echo "[recipe-check] recipes/ not found at $RECIPES_DIR" >&2
  exit 1
fi

# Top-level directories a recipe may cite as a source.
PREFIXES='templates|docs|tools|scripts|portfolio|recipes|\.claude'

errors=0
checked=0

while IFS= read -r file; do
  while IFS= read -r ref; do
    # Skip placeholder / glob / illustrative tokens.
    case "$ref" in
      *'<'*|*'{'*|*'*'*|*'...'*|*'…'*) continue ;;
    esac
    checked=$((checked + 1))
    if [ ! -e "$REPO_ROOT/$ref" ]; then
      echo "[recipe-check] MISSING: '$ref' cited in ${file#"$REPO_ROOT"/} does not exist" >&2
      errors=$((errors + 1))
    fi
  done < <(
    grep -hoE "\`($PREFIXES)/[^\`]+\`" "$file" 2>/dev/null \
      | tr -d '\`' \
      | sort -u
  )
done < <(find "$RECIPES_DIR" -name '*.md' ! -name '_TEMPLATE.md')

echo "[recipe-check] in-repo path citations checked: $checked"

if [ "$errors" -gt 0 ]; then
  echo "[recipe-check] FAILED with $errors error(s)." >&2
  exit 1
fi

echo "[recipe-check] GREEN"
