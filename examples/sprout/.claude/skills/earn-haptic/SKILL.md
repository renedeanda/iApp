---
name: earn-haptic
description: Unlock a 4th, 5th, 6th, 7th, or 8th haptic pattern in this Swift app. Moves the pattern from the _HapticVocabulary/ reference into the compiled set and writes an addendum to DECISIONS/012-haptic-vocabulary.md. Soft cap 8; hard cap 10.
---

> SOURCE: pattern adapted from the Kindling root skill `earn-haptic`.

# /earn-haptic

Add a haptic pattern beyond the 3 starters. The full 24-pattern vocabulary (distilled from a shipped production app) ships as a reference at `Sprout/Utilities/_HapticVocabulary/HapticPatterns.full.swift` (excluded from compile); this skill graduates one pattern into `Sprout/Utilities/HapticPatterns.swift`.

## When to use

- A new UX moment legitimately benefits from a distinct haptic the starter 3 can't carry.
- The pattern has a clear semantic role (success confirmation, soft prompt, irreversible-action warning).

## When NOT to use

- "It would feel nice" with no semantic role — that's haptic fatigue. Rejected.
- Per-keystroke / per-scroll feedback — the OS already handles input haptics.
- Without reading `DECISIONS/012-haptic-vocabulary.md` first — the starter 3 may already cover it.
- To hit a number — 8 is a soft cap, not a target. Most apps are done at 3–5.

## Soft cap 8 · hard cap 10

Kindling's haptic discipline. Beyond 8, the addendum must justify hard. Beyond 10, refuse.

## Steps

1. Read `DECISIONS/012-haptic-vocabulary.md` — confirm the starter 3 and count current unlocks.
2. If at the soft cap (8), ask the user to confirm + add a "why this is the 9th" justification.
3. Find the pattern in `Sprout/Utilities/_HapticVocabulary/HapticPatterns.full.swift`. Move that case (and its definition) into the compiled `Sprout/Utilities/HapticPatterns.swift`.
4. Confirm it plays through `HapticManager` (which gates on `UIAccessibility.isReduceMotionEnabled` + the `reduceHaptics` setting). Never a raw `UIImpactFeedbackGenerator` at the call site.
5. Append a dated addendum to `DECISIONS/012-haptic-vocabulary.md`:

```md
## Addendum — <date> — Earned #<N>: `<patternName>`

- **Generator config:** <UIImpact/UINotification + style>
- **Trigger:** <when this fires — one line>
- **Why now:** <one paragraph — what moment this serves; why the starter 3 don't cover it>
- **Reduce-haptics behavior:** <how this silences>
```

6. Run `xcodebuild test -only-testing:SproutTests/HapticPatternTests` — it counts compiled-in patterns against the ADR. An unlock without an addendum fails the test; that's the gate working.

## Output

```
/earn-haptic bloomComplete

Current unlocks: 3 / 8
Graduated `bloomComplete` from _HapticVocabulary/ into HapticPatterns.swift.
Wrote DECISIONS/012-haptic-vocabulary.md addendum.
HapticPatternTests: PASSED (4 patterns)
```
