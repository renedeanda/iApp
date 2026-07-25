# Add delight animations

> **Source:** [`docs/DELIGHT_REEL.md`](../../docs/DELIGHT_REEL.md) — the catalog; each entry cites its source path (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift (the catalog is mostly SwiftUI; several entries have RN analogs)
> **Reliability:** ✅ — every reel entry is a shipped, sourced moment.

## What it adds

A small set (3–5) of specific, earned micro-animations harvested from the portfolio's [Delight Reel](../../docs/DELIGHT_REEL.md). This recipe is **seeded by `/pick-delight-moments`** during `/new-app` — the wizard writes `DECISIONS/014-delight-moments.md` and drops copy-ready snippets here for the chosen moments.

## When to use

- The wizard's `/pick-delight-moments` step ran and picked 3–5 moments — this recipe is where their snippets land.
- You're implementing one of the chosen moments and need the source file + the contrast/Reduce-Motion-verified snippet.
- A later, deliberate addition of a moment (with the ADR addendum a 6th requires).

## When NOT to use

- **"Make it more delightful."** The wizard rejects this as a feature request, and so should you. Delight is *specific moments tied to specific user actions*, not a vibe you sprinkle on.
- **More than 5 moments.** Cap is 5; each consumes an attention budget. A 6th needs an ADR addendum justifying it — same discipline as `/earn-haptic`.
- **The forbidden patterns.** Confetti on routine actions, screen-shake, continuous idle animations, anything over 600 ms that isn't a *completion* moment, auto-playing splash video. `docs/DELIGHT_REEL.md` lists these — the wizard rejects them.
- **Skipping the Reduce Motion fallback.** Every delight moment degrades to a tasteful *static* state under Reduce Motion. A moment without a fallback isn't done.

## How

### 1. Harvest

Each chosen moment cites its source in [`docs/DELIGHT_REEL.md`](../../docs/DELIGHT_REEL.md). Examples:

| Moment | Source | Fires on |
|---|---|---|
| Result reveal / celebration pop | `templates/swift/Seed/Theme/DelightMoments.swift` | completion |
| Liquid Glass under floating bars | `templates/swift/Seed/Theme/LiquidGlass.swift` | chrome |
| Brutalist hard-cut sheet transitions | `templates/swift/Seed/Services/_Disabled/NavigationRouter.swift` | sheet present/dismiss |
| Save → favorite haptic chain | proven in production — a two-step action chaining `.softConfirm` then a celebration haptic | two-step action |

Open the cited file, read the whole animation, adapt it to this app's palette and timing.

### 2. Wire

- **Tie to a user action + a success state.** A delight moment fires on a *specific* event (a completion, a milestone), not on appear, not on a timer.
- **Duration discipline:** 200–400 ms for transitions, 400–600 ms for state changes, longer only for genuine *celebration* completions. Never exceed 600 ms otherwise.
- **`motionSafeAnimation()`:** every animation goes through the motion-safe wrapper (in `Theme/MotionSafe.swift`) — never a bare `.animation()`. The wrapper resolves to a static state under Reduce Motion.
- **Theme-driven:** colors from the `theme` environment, never literals. A delight moment is a *brand* moment — it must honor the palette.
- **Record it:** when a *new* delight moment ships (not from the reel), add a row to `docs/DELIGHT_REEL.md` with the file path, per the Kindling CLAUDE.md "evolve Kindling" rule.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# then on the simulator: Settings → Accessibility → Motion → Reduce Motion ON
#   → trigger each delight moment → confirm it degrades to a static, tasteful state.
```

Expected: build green; with Reduce Motion off, each chosen moment plays within its duration budget; with Reduce Motion on, each resolves to a static state with no janky half-animation.

## Gotchas

- `motionSafeAnimation()` is not optional — a delight moment with a raw `.animation()` will animate for a user who explicitly asked the OS not to. That's an accessibility failure, and `/review` category 4 flags it.
- The Reduce Motion fallback is a *design decision*, not "skip the animation" — the static state should still feel intentional (the ring bloom becomes three settled rings, not nothing).
- Visual-harvest-only entries — take the *animation*, write your own copy strings; never inherit a source's on-surface strings (they can carry unlocalized or WIP l10n).
- Snapshot tests don't catch animation quality — verify these by eye, on a device, both Reduce-Motion states.
