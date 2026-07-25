---
name: deferred-check
description: Surface all deferred items (TODO comments, "decide later" ADR open questions, half-done phase checkboxes) and check which should be picked up now vs deferred further. Helps ensure nothing falls through phase cracks.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /deferred-check

Find everything that was deliberately deferred and triage it.

## When to use

- End of a phase, before opening the PR.
- When something feels half-done and you're not sure what.
- Periodically as the project grows — deferred items rot.

## What it finds

1. **Markdown TODOs** — `grep -rn 'TODO' --include='*.md' .`
2. **ADR "Open questions" sections** — each ADR has an optional Open questions section; if non-empty, surface it
3. **Forward references** — `recipes/swift/...` / `templates/swift/...` references in docs, where the target file doesn't exist yet (acceptable during build, must be resolved before launch)
4. **Unchecked phase items** — checkboxes in `DECISIONS/005-launch-readiness.md` that should be done by now
5. **Half-baked patterns** — REUSE_INDEX rows marked `*No verbatim source yet*` (like the SoundService row)
6. **Stale "to be added later" notes** — text like "deferred to Phase X" where Phase X is now active

## Triage decision per finding

For each item:

- **Now (in this phase)** — actionable; create a todo and start
- **Next phase** — punt to the next phase's intake
- **Specific future phase** — punt with a marker (`<deferred-to-phase-N>`)
- **Forever deferred** — close it; rewrite the doc so it's not framed as "later"

## Output shape

```
Deferred items — <date>

NOW (this phase):
  [ ] <checklist item that's actionable today>
  [ ] <REUSE_INDEX row with no verbatim source yet>

NEXT phase:
  [ ] <paths referenced in docs that don't exist yet>

FUTURE (named phase):
  [ ] <item explicitly punted to a later phase>

CLOSED (no longer relevant):
  [ ] <"deferred to Phase X" note where Phase X is done>

Recommend starting with the N NOW items. Proceed?
```

## Cross-references

- [DECISIONS/005-launch-readiness.md](../../../DECISIONS/005-launch-readiness.md)
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md)
