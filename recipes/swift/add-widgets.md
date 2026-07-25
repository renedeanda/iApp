# Add native widgets

> **Source:** `templates/swift/SeedWidgets/` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — the template's widget scaffold is the proven source for native widgets.

## What it adds

A WidgetKit extension that renders home-screen and lock-screen widgets backed by the app's data. The widget reads from a shared App Group container, renders edge-to-edge with the palette, and reloads its timeline when the app writes. For most portfolio apps the widget is seen 20× more often than the app is opened — it is a primary surface, not an add-on.

## When to use

- The app's state is **glanceable** — a number, a short string, a simple visual that's useful without interaction.
- A lock-screen presence would aid retention without nagging (a breathing orb, a quick-note glance).
- App Store screenshots would convert better with a tasteful widget shown.

## When NOT to use

- **The widget would just be a "launch app" button.** Use a Home-screen Shortcut or a Control (see [add-control-center](add-control-center.md)) instead — widgets are read-only surfaces.
- **The state isn't glanceable.** If the user has to read three lines to get value, that's a notification or an app screen, not a widget.
- **The data updates faster than every ~5 minutes.** Widget timeline budgets can't keep up; you'll either drain battery polling or show stale data. Re-think the surface.
- **You're tempted to harvest from an app whose widget l10n is flagged WIP.** Widget strings that resolve from the wrong bundle ship raw keys to non-English users. Harvest from the template scaffold only.

## How

### 1. Harvest

- Source: `templates/swift/SeedWidgets/` — read `SeedWidget.swift`, `WidgetSharedData.swift`, `SeedWidgetBundle.swift`, `WidgetTheme.swift`, and the widget's own `Resources/Localizable.xcstrings`.
- **The Swift template already ships this** — `templates/swift/SeedWidgets/` has the full scaffold (`SeedWidgetBundle`, `SeedWidget`, `SeedLiveActivity`, `WidgetSharedData`, `WidgetTheme`, `Info.plist`, entitlements, `Resources/Localizable.xcstrings`). The build *target* is commented out in `project.yml` — uncommenting it is the "add" step. For a fresh app the directory renames to `<App>Widgets/`.

### 2. Wire

- **App Group:** add `group.com.example.<app>` to both the app target and the widget target entitlements. Read shared data via `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:)` — never `UserDefaults(suiteName:)` (it fails silently on entitlement misconfig).
- **Edge-to-edge:** the widget root view uses `.containerBackground(for: .widget) { ... }`. Never `.background(...)` — it creates a gutter inside the OS border.
- **Localization:** the widget target gets its **own** `Localizable.xcstrings` under `<App>Widgets/Resources/`. Strings keyed only in the app's xcstrings return the key on the widget surface — a trap we hit in production. See [docs/WIDGETS.md](../../docs/WIDGETS.md) rule 2.
- **Timeline:** add a top-of-file comment declaring the strategy (Static / Calendar / Triggered / Polling). For app-data widgets it's Triggered — call `WidgetCenter.shared.reloadAllTimelines()` after every relevant write.
- **pbxproj:** every widget source file needs a PBXBuildFile entry in the widget target's Sources phase. Run `/pbxproj-check` after adding files.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/WidgetEdgeToEdgeTests \
  -only-testing:<App>Tests/WidgetLocalizationParityTests
```

Expected: both suites green — edge-to-edge background present on every family, and every widget-surface string exists in the widget's own xcstrings for all 7 tier-1 locales.

## Gotchas

- The snapshot view (widget gallery) must differ from the real view **only in content, not layout** — Apple shows the snapshot in the gallery.
- No animations inside a widget. Widgets are static snapshots; motion belongs in Live Activities.
- 16 MB memory hard cap on iPhone. Use SF Symbols, not bundled images.
- Declare only the families you actually support — omit the rest from `supportedFamilies`.
