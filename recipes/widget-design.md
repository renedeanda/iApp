# Widget design checklist

> **Source:** [`docs/WIDGETS.md`](../docs/WIDGETS.md)
> **Platform:** Both (native Swift widgets + RN Expo-bridged Swift widgets)
> **Reliability:** ✅ — the checklist is portfolio-wide policy.

## What it adds

Not code — a **gate**. This recipe is the visual + structural checklist every widget must pass before it ships, on either platform. The implementation recipes ([add-widgets](swift/add-widgets.md) for Swift, _add-rn-widgets_ for RN) tell you how to build the extension; this one tells you whether what you built is good enough.

## When to use

- Before shipping **any** widget — native or RN-bridged.
- During `/review` when a diff touches `Widgets/` or `ios-widget/`.
- When deciding whether a proposed widget should exist at all (the "When to skip" list below).

## When NOT to use

- As a substitute for reading [docs/WIDGETS.md](../docs/WIDGETS.md) — that doc has the *why* behind each rule and the code snippets. This recipe is the condensed gate.
- To justify a widget that fails the "When to skip a widget" test. A polished widget that shouldn't exist is still clutter.

## How

### The visual checklist

Every widget, before it ships:

- [ ] **Edge-to-edge** `containerBackground(for: .widget)` — never `.background(...)` (gutters inside the OS border).
- [ ] **≤ 2 font weights** per widget family.
- [ ] **≤ 1 accent color** per widget.
- [ ] **Locale-aware** date/number formatting (`Date.FormatStyle`, `Decimal.FormatStyle`).
- [ ] **Timeline strategy** documented in a top-of-file comment (Static / Calendar / Triggered / Polling — and *why*).
- [ ] **Snapshot view** differs from the real view only in *content*, not *layout* (Apple shows the snapshot in the gallery).
- [ ] **Families declared explicitly** — list the ones you support, omit the rest from `supportedFamilies`.
- [ ] **AAA contrast** on widget text vs widget background — test on the lock screen over a photo wallpaper (the hardest case).
- [ ] **Whole-widget tap target** — `Link` / `widgetURL`, never an inner `Button`.
- [ ] **No animations** inside the widget — widgets are static snapshots; motion lives in Live Activities.

### The localization gate

- [ ] Widget-surface strings live in the **widget extension's own** `Localizable.xcstrings` (native) or `.lproj/` set (RN), **not** the host app's. This is a trap we hit in production: the widget runtime loads strings from the extension's bundle, so host-app-only strings silently render as raw keys.
- [ ] `WidgetLocalizationParityTests.swift` (native) passes for all 7 tier-1 locales.

### The "should this widget exist?" gate

Skip the widget — and document the skip in `DECISIONS/004-native-feature-checklist.md` — when:

- [ ] The app's state isn't glanceable.
- [ ] The widget would only be a "launch app" button (use a Shortcut or a Control instead).
- [ ] The widget needs the user to *do* something to be useful (widgets are read-only — taps deep-link, they don't act).

### The performance budget

- [ ] Snapshot view renders in ≤ 30 ms.
- [ ] Timeline provider completes in ≤ 5 s (system kills after).
- [ ] Memory ≤ 16 MB iPhone / 30 MB iPad — SF Symbols, not bundled images.
- [ ] Disk reads go through the App Group container (small JSON), not a cold-start SwiftData open.

### Verify

```sh
# Native:
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/WidgetEdgeToEdgeTests \
  -only-testing:<App>Tests/WidgetLocalizationParityTests

# RN: confirm the widget target builds inside the prebuilt project
npx expo prebuild --clean --platform ios --no-install && \
  xcodebuild build -scheme <App>Widget -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: edge-to-edge + localization-parity suites green; the widget target compiles inside the Expo-prebuilt project.

## Gotchas

- The single most common shipped bug is the localization-bundle mismatch (rule 2). It passes locally because the dev's device is in English. It only surfaces for a non-English user. The parity test is the only reliable catch.
- RN apps do **not** "do widgets in JS." `ios-widget/` is a real Swift extension; JS only triggers reloads via the `WidgetBridge` native module.
- Reference reel — look at this before designing: `templates/swift/SeedWidgets/SeedWidget.swift` (native gold standard; the RN recipe bridges the same shape). Harvest only from gold-standard sources per [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — never from an app whose widgets are flagged WIP.
