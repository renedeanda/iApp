---
name: earn-haptic
description: Unlock a 4th, 5th, 6th, 7th, or 8th haptic pattern in an existing app. Writes an addendum to DECISIONS/012-haptic-vocabulary.md justifying the new pattern. Soft cap 8; hard cap 10.
---

# /earn-haptic

Every new app starts with 3 starter haptics. Adding more requires *earning* the unlock — this skill enforces that gate.

## When to use

- Inside an existing portfolio app (not Kindling itself).
- After shipping the app for ≥2 weeks (some patterns prove themselves only with real users).
- When a specific user action genuinely deserves a distinct haptic that isn't covered by the current 3.

## When NOT to use

- During `/new-app --draft` — pick the starter 3 via `/pick-haptic-vocabulary` instead.
- Just because the catalog has a cool pattern you haven't shipped yet — needs a *triggering user action* in your app.
- To paper over UX uncertainty — if the action isn't clear enough, more haptics won't fix it.

## The bandwidth lesson

(Recorded in RECENT_LEARNINGS.md.) A shipped production app carried 24 patterns; after 8, users stopped distinguishing them — the app started feeling like "the app vibrating" instead of distinct emotional events. **Soft cap: 8. Hard cap: 10 with reviewer sign-off.**

## Steps

1. Read current `DECISIONS/012-haptic-vocabulary.md` in the child app.
2. Count current patterns. If at 8: warn and require explicit `--past-soft-cap` flag. If at 10: refuse.
3. Ask the user to justify:
   - **Triggering user action** — what user moment fires this haptic?
   - **Why the existing patterns don't cover it** — be specific about why none of the current 3–7 work
   - **Source pattern** — which of the catalog's 24 patterns matches (or "Other" with a new pattern definition)
4. Sanity-check the justification:
   - Is the triggering action genuinely distinct? (Save vs. favorite vs. complete — three distinct actions OK; three flavors of "tap" — not OK)
   - Is the new pattern semantically different from existing ones? (Test: can a user blindfolded distinguish them?)
5. Write the addendum to `DECISIONS/012-haptic-vocabulary.md`:
   ```markdown
   ## Addendum — YYYY-MM-DD — Earned 4th haptic

   Pattern: bloomSettle
   Source: Utilities/_HapticVocabulary/HapticPatterns.full.swift
   Fires on: user marks a note as "done for now" (distinct from completion + distinct from save)
   Why existing 3 don't cover: save is too soft, completion is too final, this is a "rest" moment
   ```
6. Update `Seed/Utilities/HapticPatterns.swift` in the app — add the pattern definition.
7. Commit: `feat(haptics): earn bloomSettle pattern for done-for-now moment`.

## Constraints

- One addendum per earned pattern (no batching).
- Each addendum must be ≥48 hours after the previous one — *earning* implies considered, not bulk.
- HapticManager + `UIAccessibility.isReduceMotionEnabled` gating still applies.

## Cross-references

- [DECISIONS/012-haptic-vocabulary.md](../../../DECISIONS/012-haptic-vocabulary.md) — vocab + addendum shape
- [portfolio/RECENT_LEARNINGS.md](../../../portfolio/RECENT_LEARNINGS.md) — the bandwidth lesson
- [CLAUDE.md](../../../CLAUDE.md) taste rule 2 — haptics are earned
- [/pick-haptic-vocabulary](../pick-haptic-vocabulary/SKILL.md) — the starter-3 pick
