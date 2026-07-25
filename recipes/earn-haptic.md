# Earn a haptic

> **Source:** `docs/HOUSEKEEPING.md` + the `/earn-haptic` skill (ships in both templates' `.claude/skills/`)
> **Platform:** Both (Swift `HapticManager`; RN `expo-haptics`)
> **Reliability:** ✅ — this is portfolio process, not harvested code.

## What it adds

Not a feature — a **gate with paperwork**. Every app ships with **3 starter haptic patterns**. This recipe is the deliberate process for unlocking a 4th, 5th, … up to a soft cap of 8 (hard cap 10). Each unlock writes a dated addendum to `DECISIONS/012-haptic-vocabulary.md` justifying why the pattern earns its place.

## When to use

- A new UX moment genuinely needs a **distinct, semantically-meaningful** haptic the starter 3 can't carry.
- You can name the pattern's role in one line (success confirmation, soft prompt, irreversible-action warning).
- You've confirmed the starter 3 don't already cover it (read `DECISIONS/012` first).

## When NOT to use

- **"It would feel nice."** No semantic role = haptic fatigue. Rejected.
- **Decorative / per-keystroke feedback.** The OS already handles input haptics.
- **To hit a number.** Eight patterns is a *soft cap*, not a target. Most apps are done at 3–5.
- **Skipping the addendum.** The `DECISIONS/012` addendum *is* the gate. An unlock with no written justification fails `HapticPatternTests` (Swift) — the test counts compiled-in patterns against the ADR.
- **Beyond 10.** Hard cap. A 9th or 10th needs the addendum to prove — ideally with device recordings — that every pattern is distinguishable in real use.

## How

### 1. Run the skill

```
/earn-haptic <patternName>
```

It reads `DECISIONS/012-haptic-vocabulary.md`, confirms the current unlock count, and warns if you're at the soft cap.

### 2. What the skill does

- **Swift:** moves the pattern out of `Utilities/_HapticVocabulary/HapticPatterns.full.swift` into the compiled `Utilities/HapticPatterns.swift`, wired through `HapticManager` (which gates on Reduce Motion / `reduceHaptics`).
- **RN:** maps the pattern onto the closest `expo-haptics` primitive (`impactAsync` / `notificationAsync` / `selectionAsync`) and adds a typed wrapper in `src/services/HapticService.ts` that respects a `reduceHaptics` setting.
- **Both:** appends the dated addendum to `DECISIONS/012-haptic-vocabulary.md`:

```md
## Addendum — <date> — Earned #<N>: `<patternName>`

- **Primitive / generator:** <the underlying call>
- **Trigger:** <when this fires — one line>
- **Why now:** <one paragraph — what moment this serves, why the starter 3 don't cover it>
- **Reduce-haptics behavior:** <how this silences>
```

### 3. Verify

```sh
# Swift
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/HapticPatternTests
# RN
npx jest
```

Expected: the pattern-count test passes — compiled-in patterns == 3 + (addenda in `DECISIONS/012`). An unlock without an addendum fails the test; that's the gate working.

## Gotchas

- Haptics are a no-op on the Simulator — verify the actual feel on a device before deciding a pattern is distinct.
- "Distinct" is the hard part: two impact styles a half-step apart feel identical in a noisy real-world context. If you can't tell them apart blindfolded, they're the same pattern.
- See also [add-haptics](swift/add-haptics.md) for the initial 3-pattern setup.
