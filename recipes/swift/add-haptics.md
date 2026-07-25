# Add haptics

> **Source:** `templates/swift/Seed/Utilities/HapticPatterns.swift` + `templates/swift/Seed/Services/_Disabled/HapticManager.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)). Lightweight alternative: `templates/swift/Seed/Services/_Disabled/HapticsService.swift`.
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — the 24-pattern vocabulary, distilled from a shipped production app, is the reference.

## What it adds

A typed haptic vocabulary: named patterns (`.softConfirm`, `.bloom`, `.tickDown`) instead of raw `UIImpactFeedbackGenerator` calls scattered through views. Every pattern checks Reduce Motion / a `reduceHaptics` setting before firing.

## When to use

- An action has a **physical-feeling outcome** the user benefits from feeling — a save landing, a toggle flipping, a completion.
- The app already has the 3 starter patterns and you're using them at the right moments.
- You want haptics centralized so Reduce Haptics is one switch, not a grep.

## When NOT to use

- **Adding a 4th+ pattern casually.** The template ships **3 starter patterns**. A 4th is a deliberate unlock via `/earn-haptic` (writes an ADR addendum). Soft cap 8. See [earn-haptic](../earn-haptic.md).
- **Per-keystroke / per-scroll feedback.** That's haptic fatigue. The OS already handles text-input and picker haptics.
- **Decorative haptics.** A haptic with no semantic ("it feels nice") is noise. Every pattern maps to a specific user-meaningful event.
- **Bypassing the manager.** A raw `UIImpactFeedbackGenerator()` in a view defeats the Reduce Haptics gate. Always go through `HapticManager`.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Utilities/HapticPatterns.swift` (the pattern enum) + `Services/_Disabled/HapticManager.swift` (the gated player). The template ships the 3-pattern subset in `Utilities/HapticPatterns.swift` and the full 24-pattern reference in `Utilities/_HapticVocabulary/HapticPatterns.full.swift` (excluded from compile).
- For a 1–3 pattern app that doesn't need the full manager, `Services/_Disabled/HapticsService.swift` is a lighter wrapper.

### 2. Wire

- **Call site:** `HapticManager.shared.play(.softConfirm)` — never a raw generator.
- **Reduce gate:** `HapticManager` checks `UIAccessibility.isReduceMotionEnabled` *or* the app's `reduceHaptics` UserDefault before firing. Confirm this gate exists; it's the whole point.
- **Prepare before fire** for latency-sensitive moments — `generator.prepare()` in the manager ahead of the expected event.
- **Earning more:** to use a 4th pattern, run `/earn-haptic <name>` — it moves the pattern out of `_HapticVocabulary/` and writes the `DECISIONS/012` addendum.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/HapticPatternTests
```

Expected: the test asserts exactly N patterns are compiled in (N = 3 + earned unlocks) and that each maps to a valid generator config. A 4th pattern with no ADR addendum fails the test.

## Gotchas

- Haptics do nothing on the Simulator — verify on a device.
- `UINotificationFeedbackGenerator` (`.success`/`.warning`/`.error`) and `UIImpactFeedbackGenerator` (`.light`/`.medium`/`.heavy`/`.soft`/`.rigid`) are different families — pick by *meaning*, not by feel-shopping.
- Reduce Motion ≠ Reduce Haptics on the OS, but the portfolio convention is to honor Reduce Motion as the haptic gate too (plus the dedicated setting). Don't split them.
