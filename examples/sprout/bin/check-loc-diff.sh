#!/usr/bin/env bash
# check-loc-diff.sh — guard against whole-file re-serialization of localization
# catalogs. Adding N keys should be (almost) additions-only; a big DELETION
# count means a tool reformatted/re-sorted the whole file (a real xcstrings
# trap we hit in production): a 27k-line diff for 6 new keys, unreviewable, risky.
#
# Usage: bin/check-loc-diff.sh [base-ref]   (default: origin/main)
# Exit 1 if any *.xcstrings / *.strings file deletes more than THRESHOLD lines.
#
# Recovery when it fires: the content is almost always intact (only formatting
# changed). Restore the base file and re-add ONLY the new keys, e.g.:
#   python3 - <<'PY'
#   import json,subprocess,collections
#   raw=subprocess.check_output(["git","show","BASE:path/Localizable.xcstrings"]).decode()
#   orig=json.loads(raw,object_pairs_hook=collections.OrderedDict)
#   head=json.load(open("path/Localizable.xcstrings"),object_pairs_hook=collections.OrderedDict)
#   for k in ["new.key.one","new.key.two"]: orig["strings"][k]=head["strings"][k]
#   open("path/Localizable.xcstrings","w").write(
#       json.dumps(orig,indent=2,separators=(",", " : "),ensure_ascii=False)+"\n")
#   PY

set -euo pipefail
BASE="${1:-origin/main}"
THRESHOLD="${LOC_DELETE_THRESHOLD:-40}"
fail=0

# only consider tracked localization catalogs that changed
while IFS= read -r f; do
  [ -z "$f" ] && continue
  # numstat: "<added>\t<deleted>\t<file>"
  read -r add del _ < <(git diff --numstat "$BASE"...HEAD -- "$f")
  add=${add:-0}; del=${del:-0}
  if [ "$del" -gt "$THRESHOLD" ]; then
    echo "✗ $f: $del deletions (+$add) — looks re-serialized, not appended."
    fail=1
  fi
done < <(git diff --name-only "$BASE"...HEAD -- '*.xcstrings' '*.strings' 2>/dev/null)

if [ "$fail" -eq 0 ]; then
  echo "✓ localization diffs are append-shaped (no whole-file re-serialization)."
else
  echo ""
  echo "Localization catalog was re-serialized. See recovery in this script's header."
  exit 1
fi
