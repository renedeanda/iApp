---
name: earn-haptic
description: Unlock a 4th, 5th, 6th, 7th, or 8th haptic pattern in this RN app. Writes an addendum to DECISIONS/012-haptic-vocabulary.md justifying the new pattern. Soft cap 8; hard cap 10 with stricter justification.
---

> SOURCE: pattern adapted from `iApp:.claude/skills/earn-haptic`; haptic types remapped from the 24-pattern Swift reference catalog to `expo-haptics` primitives.

# /earn-haptic

Add a haptic pattern beyond the 3 starters. RN-side, this maps onto one of `expo-haptics`'s primitives (impact light/medium/heavy, notification success/warning/error, selection) plus a wrapping helper.

## When to use

- A new UX moment legitimately benefits from a distinct haptic that the starter 3 can't carry.
- The pattern has a clear semantic role (success confirmation, soft prompt, irreversible warning).

## When NOT to use

- "It would feel nice" without a clear semantic — that's haptic fatigue waiting to happen.
- Decorative or per-keystroke feedback — RN's text input already provides system-level feedback.
- Without reading `DECISIONS/012-haptic-vocabulary.md` first — the starter 3 may already cover the use case.

## Soft cap

8 patterns per app. iApp's haptic discipline rule.

## Hard cap

10. Beyond 10, the addendum must demonstrate (with screen recordings, ideally) that each pattern is distinguishable from every other in real device use.

## Steps

1. Read `DECISIONS/012-haptic-vocabulary.md` — confirm the starter 3 and count current unlocks.
2. If at the soft cap (8), ask the user to confirm + add a "why this is the 9th" justification block.
3. Pick the `expo-haptics` primitive that best fits:
   - `Haptics.impactAsync(ImpactFeedbackStyle.Light | Medium | Heavy)` — physical event analog.
   - `Haptics.notificationAsync(NotificationFeedbackType.Success | Warning | Error)` — system-level outcome.
   - `Haptics.selectionAsync()` — discrete selection change.
4. Add a typed wrapper to `src/services/HapticService.ts` (create if not present) that respects a `reduceHaptics` setting (mirroring Reduce Motion behavior).
5. Append a dated entry to `DECISIONS/012-haptic-vocabulary.md`:

```md
## Addendum — <date> — Earned #<N>: `<patternName>`

- **Primitive:** `Haptics.<call>(...)`
- **Trigger:** <one-line: when this fires>
- **Why now:** <one paragraph: what UX moment this serves; why the starter 3 don't cover it>
- **Reduce-haptics behavior:** <how this silences>
```

6. Run `/test` to ensure no existing haptic-dependent test regressed.

## Output

```
/earn-haptic refillSuccess

Current unlocks: 3 / 8
Mapping refillSuccess -> Haptics.notificationAsync(NotificationFeedbackType.Success)

Wrote DECISIONS/012-haptic-vocabulary.md addendum.
Wrote src/services/HapticService.ts shim.
Tests: PASSED (5)
```
