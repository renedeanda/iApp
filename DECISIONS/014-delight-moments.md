# ADR 014 — Delight Moments

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Per docs/DELIGHT_REEL.md + CLAUDE.md taste rule 3: delight moments are *earned*, capped at 5 per app, and tied to specific user actions. The reel catalogs ~18 proven moments. Each new app picks 3-5 to bake in.

This ADR has the same bandwidth problem as haptics: more than 5 delight moments and the app feels busy rather than crafted — a lesson learned in production.

## Decision

**Kindling has zero delight moments** (no UI).

There is **one** quietly-delightful infrastructure moment that wasn't on the reel: the `/new-app --commit` workflow opens a PR back to Kindling that updates PORTFOLIO + PALETTE_CATALOG + MONETIZATION_MATRIX in a single commit — the new child app *claims its territory* atomically. That's a developer-facing delight, not user-facing, so it doesn't go on DELIGHT_REEL.

### Child app ADR 014 shape

```markdown
# ADR 014 — Delight Moments

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Selected delight moments (3-5 from docs/DELIGHT_REEL.md)

| # | Moment | Source | Fires on | Cost-benefit fit |
|---|---|---|---|---|
| 1 | <name> | <template path or reel entry> | <user action> | <one sentence — why it's right for THIS app's mission> |
| 2 | ... | ... | ... | ... |
| 3 | ... | ... | ... | ... |

## Constraints

- Cap: 5 per app. Adding a 6th requires:
  - Run /pick-delight-moments with --add-extra flag
  - Write an addendum to this ADR justifying the extra
  - Reviewer (you, tomorrow morning, after sleeping) approves

- Each moment must:
  - Tie to a specific user action (not "ambient delight")
  - Live at a specific file path you can link to
  - Pass the forbidden-delights checklist at the bottom of DELIGHT_REEL.md

- Timing budget (per moment):
  - 200-400 ms for transition moments
  - 400-600 ms for state-change moments
  - 600+ ms ONLY for completion celebrations (ring blooms, type-tally finishes)

- Reduce Motion fallback for every moment: defined, tasteful, conveys the same meaning statically

## New delight moments this app proves (PR to DELIGHT_REEL.md after launch)

If this app ships a moment not in the reel yet:
- Brief description
- Source file path
- One sentence: why it's general enough to add to the reel vs. app-specific
```

## Options considered

For Kindling itself:

- **Pretend to have delights for consistency** — rejected. Kindling has no UI; faking would dilute the ADR's meaning for child apps.
- **Skip this ADR entirely** — rejected. The ADR isn't optional in the child-app sequence; Kindling's "zero" is honest.

For the *shape* of child app ADR 014:

- **Free-form description of delights** — rejected. The table format is the *test surface* for `/pick-delight-moments` skill verification.
- **Just pick from DELIGHT_REEL with no per-moment rationale** — rejected. "Cost-benefit fit" column forces the developer to justify each moment against the app's mission, not just pick favorites.

## Consequences

- **Unlocks:** `/pick-delight-moments` skill reads DELIGHT_REEL, presents catalog items filtered by this app's visual identity + signature motion, user picks 3-5, fills in cost-benefit per row.
- **Forecloses:** ad-hoc "make it more delightful" requests during development. Each delight is committed up front; new delights require an ADR addendum.
- **Cost to revisit:** small (one ADR rewrite, often paired with a code change in views).

## Verification

`DelightMomentTests.swift` (template) is forward-looking — there's no canonical pattern yet. Likely uses snapshot testing or visual regression against fixtures.

## Cross-references

- [docs/DELIGHT_REEL.md](../docs/DELIGHT_REEL.md) — full catalog + forbidden delights
- [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md) — the delight bandwidth-limit lesson
- [CLAUDE.md](../CLAUDE.md) taste rule 3 + 6 — delight moments are an earned design checkpoint
- ADR 009 (signature motion) — delights are *specific* moments riding on top of the *general* motion principle
- ADR 012 (haptics) — many delights pair a visual moment with a haptic
