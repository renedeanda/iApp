---
name: review
description: Auto-healing code review for this Swift app. Scans 14 SwiftUI/SwiftData-flavored categories (force-unwraps, @MainActor, theme leaks, a11y, l10n, platform guards, etc.), fixes what can be auto-fixed, builds + tests in a heal loop, reports what remains. Use after completing a feature or before opening a PR.
---

> SOURCE: pattern adapted from the iApp root skill `review`, scoped to a Swift child app.

# /review

Auto-healing audit pass. After a feature's commits land, run `/review` to catch consistency bugs before merging.

## When to use

- After pushing a feature branch's commits.
- Before opening a PR to `main`.

## When NOT to use

- Mid-feature — wait until the feature is logically complete.
- Inside the iApp repo itself — use that repo's `/review`.

## The 14 audit categories

1. **Force-unwraps** — no `!` in production code; use `guard let` / `if let` / `??`.
2. **`@MainActor`** — every `@Observable` that touches a SwiftData `@Model` is `@MainActor`.
3. **Theme leaks** — no color literals / `Color(hex:)` / `.system(size:)` in views; go through the `theme` + `Typography` environment.
4. **A11y** — every `.buttonStyle(.plain)` pairs with `.accessibilityAddTraits(.isButton)`; decorative `Image(systemName:)` is `.accessibilityHidden(true)`; tappable areas ≥ 44×44.
5. **Reduce Motion** — every `.animation()` goes through `motionSafeAnimation()`.
6. **Localization** — every user-facing `Text`/`Label`/`.accessibilityLabel` is a `LocalizedStringKey`; enum `displayName`s use `String(localized:)` (brand names exempt).
7. **`ThemeRootView`** — every `.sheet` / `.fullScreenCover` / context-menu `preview:` wraps its content in `ThemeRootView { }`.
8. **Task cleanup** — every `Task<Void, Never>?` property is `.cancel()`ed in `cleanup()`.
9. **`@Query` predicates** — filter in `#Predicate`, not a Swift `.filter` on a fetched array.
10. **Relationship rules** — every `@Relationship` has an explicit inverse + delete rule.
11. **Platform guards** — iOS-only APIs (`UIKit`, `UIPasteboard`) wrapped in `#if os(iOS)`.
12. **`@GestureState`** — drag offsets use `@GestureState`, not `@State` (which can stick).
13. **View size** — files ≤ 300 lines; extract subviews.
14. **pbxproj integrity** — run `/pbxproj-check` if files were added; no orphaned/duplicate refs.

## Auto-fix

Apply directly: missing a11y traits, hardcoded colors/fonts → theme tokens, force-unwraps → guards, missing `#if os()`, uncancelled Tasks, missing `ThemeRootView`, missing l10n keys (add to `Localizable.xcstrings` + all 7 tier-1 locales).

Don't fix (report only): architecture changes, UX flow changes, anything needing design judgment.

## Build / test / heal loop

After fixes, loop up to 5×:
1. `xcodegen generate`
2. `xcodebuild build` — iOS + macOS
3. `xcodebuild test`

Exit when both platforms build and all tests pass, or after 5 iterations (report what remains).

## Output

```
## Review: <scope>

Fixed
  - <what>, <file:line>

Remaining
  - <issue that needs input>

Build: iOS ✓ / macOS ✓
Tests: PASSED (N) / N failed
Heal iterations: N/5
```
