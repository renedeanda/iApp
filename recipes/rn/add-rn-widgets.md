# Add a native widget to an RN app

> **Source:** *pattern described inline* — a native widget with a 15-language `.lproj` setup + an Expo config-plugin bridge, both proven in shipped production RN apps (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)). The Swift widget itself follows `templates/swift/SeedWidgets/`.
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — proven both at i18n scale and in a leaner bridge variant.

## What it adds

A **real Swift WidgetKit extension** inside the Expo app. RN apps do not "do widgets in JS" — `ios-widget/` is native Swift, wired into the generated `.xcodeproj` by an Expo config plugin. JS only triggers timeline reloads via a small native module.

## When to use

- The app's state is glanceable and worth a home/lock-screen surface (see the "should this widget exist?" gate in [widget-design](../widget-design.md)).
- You're willing to maintain a small amount of Swift — there is no pure-JS path to a quality widget.
- The data the widget needs can be written to a shared App Group container as small JSON.

## When NOT to use

- **Expecting a JS-only widget.** There isn't one. If you can't touch Swift, you can't ship a good RN widget.
- **The widget would just launch the app.** Use a Shortcut. Widgets are read-only surfaces.
- **Fast-changing data.** Widget timeline budgets can't keep up with sub-5-minute updates.
- **Skipping the config plugin and editing the `.xcodeproj` by hand.** `expo prebuild` regenerates the project — hand edits vanish. The plugin is the only durable wiring.
- **Harvesting widget code from a source whose widget l10n is flagged WIP.** Strings that resolve from the wrong bundle ship raw keys to non-English users — follow the localization rule below instead.

## How

### 1. Harvest

- The shape (proven in production): an `ios-widget/` directory at the project root holding the Swift widget, a standalone `WidgetTheme.swift`, and the widget's own `.lproj/` localized strings. Model the Swift side on `templates/swift/SeedWidgets/`.
- Create `ios-widget/` in the project root, plus a `plugins/withWidgetExtension.js` config plugin (same shape as the template's `plugins/withAppGroup.js`) that adds the widget target on prebuild.

### 2. Wire

- **Config plugin:** add `"./plugins/withWidgetExtension"` to `app.json` `plugins`. It runs on `expo prebuild` and adds the widget target to the generated `.xcodeproj`.
- **App Group:** add `plugins/withAppGroup.js` (already in the template) so the app and widget share a container. Read shared data via the App Group container URL, not `UserDefaults(suiteName:)`.
- **JS → widget:** the TS shim `modules/widget-bridge/index.ts` exposes `requireNativeModule('WidgetBridge').reloadAllTimelines()`. Call it whenever the app writes data the widget shows.
- **Localization:** the widget has its **own** `.lproj/` string set — widget-surface strings are not in the JS `i18n/` JSON. This is the same bundle-mismatch trap as native; see [widget-design](../widget-design.md).
- **Edge-to-edge, families, timeline strategy:** all the [widget-design](../widget-design.md) checklist rules apply — the widget is Swift, the rules are identical to native.

### 3. Verify

```sh
npx expo prebuild --clean --platform ios --no-install
xcodebuild build -scheme <App>Widget -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: prebuild adds the widget target cleanly; the widget scheme builds inside the generated project. On the simulator, the widget appears in the gallery and reloads when JS calls `reloadAllTimelines()`.

## Gotchas

- After any `app.json` change, re-run `expo prebuild --clean` — the widget target is regenerated, not patched.
- `withWidgetExtension.js` mutates the xcodeproj; an Expo SDK upgrade can break it. The template's CI runs "prebuild then build the widget target" specifically to catch this.
- The widget's Swift code can't import anything from the JS side — it reads the App Group JSON and nothing else. Keep that JSON small and stable-schema.
