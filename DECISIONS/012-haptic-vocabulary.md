# ADR 012 — Haptic Vocabulary

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Per CLAUDE.md taste rule 2, and a lesson learned in production: haptics are bandwidth-limited. A shipped app carried 24 patterns; after 8, users stopped distinguishing them. Every new app picks **3 starter haptics** and earns more via `/earn-haptic` (soft cap 8).

Kindling has no UI = no haptics. ADR exists as a worked example.

## Decision

**Kindling has no haptics** (no UI).

The Swift template ships:
- `Seed/Utilities/_HapticVocabulary/HapticPatterns.full.swift` — the full 24-pattern vocabulary distilled from a shipped production app. Reference, not active.
- `Seed/Utilities/HapticPatterns.swift` — the **3 chosen patterns** for this specific app, written by the `/pick-haptic-vocabulary` skill from this ADR's table.
- `Seed/Utilities/HapticManager.swift` — the production-proven engine. Manages CoreHaptics dictionary loading + Reduce Haptics gating.

### Child app ADR 012 shape

```markdown
# ADR 012 — Haptic Vocabulary

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Starter 3 (chosen from the 24-pattern catalog)

| Pattern | Fires on | Why this app needs it |
|---|---|---|
| <pattern name from the catalog> | <specific user action> | <one sentence — must tie to mission> |
| ... | ... | ... |
| ... | ... | ... |

## The 24-pattern catalog (reference, not enabled)

Full catalog at Seed/Utilities/_HapticVocabulary/HapticPatterns.full.swift.
Notable patterns the wizard typically draws from:

- bloomOpen          — soft expansion (for "begin a focused thing")
- completionRing      — three quick taps (for "you're done")
- senseTickDescending — slowing rhythm (for countdown / grounding)
- reminderSoft        — single soft tap (for notification)
- favoriteBurst       — quick burst with rebound (for "starred")
- launchBreath        — slow inhale (for app open)
- ... (24 total, see source)

## Reduce Haptics gating

All HapticManager calls check UIAccessibility.isReduceMotionEnabled
(repurposed for Reduce Haptics since iOS doesn't expose a separate flag).
Pattern ships in Seed/Utilities/HapticManager.swift.

## Earning more

Adding a 4th haptic requires:
1. Run /earn-haptic skill
2. Write an addendum to this ADR justifying the new pattern + which scene it fires
3. Verify it's a meaningful semantic event (not "the app vibrating because something happened")
4. Soft cap: 8 patterns total. Hard cap: 10 (requires PR + reviewer sign-off).
```

## Options considered

For Kindling itself: not applicable.

For the *shape* of child app ADR 012:

- **Ship all 24 by default** — rejected. Violates the bandwidth lesson. Apps with too many haptics feel like vibrating phones.
- **Make the 3 starter haptics fixed across all apps** — rejected. The starter set should match the app's mission (a calm app wants different haptics than a brutalist one).
- **No haptics at all by default** — rejected. Haptics done well are part of what makes an app feel distinct. Three is the right floor.

## Consequences

- **Unlocks:** the `/pick-haptic-vocabulary` skill reads the catalog, presents 5-7 wizard-recommended candidates based on visual identity + signature motion, user picks 3.
- **Forecloses:** ad-hoc `UIImpactFeedbackGenerator(...)` calls in views. Must go through HapticManager + a declared pattern.
- **Cost to revisit:** small per-haptic (write addendum, regenerate `HapticPatterns.swift` from the new selection).

## Verification

`HapticPatternTests.swift` (template) verifies every pattern in `HapticPatterns.swift` loads as a valid CoreHaptics dictionary. CI fails if the file is malformed.

## Cross-references

- [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — Haptic vocabulary row
- [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md) — the haptic bandwidth-limit lesson
- [CLAUDE.md](../CLAUDE.md) taste rule 2 — haptics are earned
- ADR 009 (signature motion) — haptics often co-fire with motion events
- ADR 014 (delight) — haptic moments are a delight subcategory
