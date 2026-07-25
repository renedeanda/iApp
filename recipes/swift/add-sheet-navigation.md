# Add sheet-driven navigation

> **Source:** `templates/swift/Seed/Services/_Disabled/NavigationRouter.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — the single-screen + sheets pattern, proven in production.

## What it adds

A `NavigationRouter` (`@Observable`) that drives the app from **one root screen plus sheets**, rather than a deep `NavigationStack` push hierarchy. Every secondary surface is a sheet or a `.sheet(item:)`; the router holds the presentation state.

## When to use

- The app's mental model is **one home + focused tasks** — e.g. one main view + detail sheets, or one session screen + setup sheets.
- Surfaces are **shallow** — the user opens a thing, does it, comes back. No "drill three levels then back-back-back".
- You want presentation state **centralized and testable** rather than scattered across `@State` booleans.

## When NOT to use

- **The app is genuinely hierarchical.** A file browser, a nested-folder notes app — that's a real `NavigationStack`. Don't force a hierarchy into sheets.
- **Push trees deeper than one level.** If a sheet needs to push to another screen that pushes again, you've outgrown this pattern — that's the explicit ⚠️ in REUSE_INDEX.
- **Modal-over-modal stacks.** A sheet presenting a sheet presenting a sheet is a UX smell. Flatten it.
- **As a global event bus.** The router holds *navigation* state. It doesn't own subscription state, data, or app settings.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/NavigationRouter.swift` — read it whole. It's small.
- In a generated app it ships in `Services/_Disabled/` — move it up to `<App>/Services/NavigationRouter.swift`.

### 2. Wire

- **Router:** `@Observable final class NavigationRouter` with an enum of presentable destinations (`enum Destination: Identifiable`).
- **Root injection:** the router is created at the app root and injected via `.environment(...)`. Sheets inherit it.
- **Presentation:** the root view has `.sheet(item: $router.presented) { destination in ... }`. Each destination case maps to its view.
- **`ThemeRootView`:** every sheet's content is wrapped in `ThemeRootView { ... }` — sheets don't inherit the theme environment otherwise. This is non-negotiable (it's the #1 sheet bug in the review checklist).
- **macOS:** sheets need an explicit `.frame(width:height:)` and a visible dismiss button — macOS doesn't give you the swipe-down.
- **Dismissal:** the router exposes `dismiss()`; views call that, not their own `@Environment(\.dismiss)`, so state stays centralized.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild build -scheme <App> -destination 'platform=macOS'
```

Expected: both platforms build. Manually: presenting and dismissing each destination updates `router.presented` and never leaves an orphaned sheet. On macOS every sheet has a frame and a dismiss control.

## Gotchas

- `.sheet(item:)` re-creates its content when the item's identity changes — don't rely on `@State` inside a sheet surviving an item swap.
- Forgetting `ThemeRootView` on a sheet produces a sheet that renders with default system colors — it *looks* like a theme bug, it's actually a missing wrapper.
- The router is `@Observable`, not a singleton — inject it, don't `.shared` it, so previews and tests can supply their own.
