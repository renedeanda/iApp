# Widgets — First-Class Surface

Widgets in Kindling are not an afterthought. They're a primary surface. The template treats them with the same care as the home screen.

## Why widgets matter

For many focused apps, the lock screen + home screen widget is the *real* product surface. The user sees the widget 20× more often than they open the app. A polished widget can be the entire value proposition (a breathing orb on the lock screen of a wellness app) or the difference between forgettable and indispensable (a quick-glance widget on a notes app).

Three reasons widgets get first-class treatment:

1. **Acquisition**: tasteful widgets in App Store screenshots convert.
2. **Retention**: widgets keep the app present without nagging.
3. **Apple-feature potential**: Apple features apps with widgets that look like Apple made them.

## Non-negotiable rules

### 1. Edge-to-edge `containerBackground`

```swift
.containerBackground(for: .widget) {
    LinearGradient(colors: [Theme.surfaceTop, Theme.surfaceBottom],
                   startPoint: .top, endPoint: .bottom)
}
```

Never use `.background(...)` on the root widget view — it creates a gutter inside the OS-supplied border. `containerBackground(for: .widget)` is the only correct API since iOS 17. Verified by `WidgetEdgeToEdgeTests.swift`.

### 2. Localize strings via the widget extension's OWN `Localizable.xcstrings`

**This is a trap we hit in production.** Live Activity and widget runtimes load strings from the *extension's* bundle, not the host app's. A string keyed only in the app's `Localizable.xcstrings` will return the key (or English fallback) on the widget surface.

Correct setup:

- `Seed/Localizable.xcstrings` — app strings.
- `Widgets/Resources/Localizable.xcstrings` — widget strings. **Separate file. Owned by the widget target.** Use `String(localized:bundle:)` with `.module` (SPM) or `Bundle(for: WidgetEntryView.self)` (XcodeGen).

```swift
Text(String(localized: "widget.title.next_session", bundle: .main))
//                                                    ^ this is the widget's bundle, not the app's
```

Verified by `WidgetLocalizationParityTests.swift` — fails CI if any widget-surface string is in the app's xcstrings but missing from the widget's.

### 3. Shared data via App Group

```swift
// ✅ Right
guard let url = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.\(appName)") else { return }
let data = try Data(contentsOf: url.appendingPathComponent("widget-data.json"))

// ❌ Wrong
let defaults = UserDefaults(suiteName: "group.com.example.\(appName)")
```

`UserDefaults(suiteName:)` works but silently fails on first access in some entitlement-misconfigured edge cases. `containerURL(forSecurityApplicationGroupIdentifier:)` returns `nil` immediately so you know the entitlement is wrong.

The template ships this pattern in `templates/swift/SeedWidgets/` (see `WidgetSharedData.swift`).

### 4. All five Live Activity regions

If Live Activities are enabled, ship all five layouts and verify each renders with localized content. (Apple sometimes calls these "four presentations" because the Dynamic Island *compact* presentation splits into leading + trailing — we list them as five to keep the test surface explicit.)

- **Compact leading** (Dynamic Island compact, left side)
- **Compact trailing** (Dynamic Island compact, right side)
- **Expanded** (Dynamic Island expanded)
- **Minimal** (multi-activity Dynamic Island)
- **Lock screen** (the bordered island on the lock screen below notifications)

`LiveActivityViewTests.swift` snapshots all five against localized fixtures for `en es de fr pt ja zh-Hans`.

### 5. Native widgets even for RN apps

RN apps do not "do widgets in JS." The RN template's `ios-widget/` is a real Swift widget extension, proven in shipped RN apps:

- A multi-language `.lproj` setup (15 languages in the source app), `WidgetTheme.swift`, edge-to-edge layouts.
- The Expo-bridge plugin pattern that wires the widget into `app.json`.

The Expo config plugin `plugins/withWidgetExtension.js` runs on `expo prebuild` and adds the widget target to the generated `.xcodeproj`. The TS shim at `modules/widget-bridge/index.ts` lets JS update widget data via `requireNativeModule('WidgetBridge').reloadAllTimelines()`.

### 6. Widget-design checklist (visual)

Before shipping any widget, run this checklist:

- [ ] Edge-to-edge background (no accidental padding gutters)
- [ ] No more than 2 font weights per widget family
- [ ] No more than 1 accent color per widget
- [ ] Locale-aware date / number formatting (`Date.FormatStyle`, `Decimal.FormatStyle`)
- [ ] Timeline reload strategy documented in a comment at the top of the widget file
- [ ] Snapshot view differs from real view ONLY in content, not in layout (Apple uses snapshot in widget gallery)
- [ ] Family support declared explicitly: `.systemSmall`, `.systemMedium`, `.systemLarge`, `.accessoryRectangular`, `.accessoryCircular`, `.accessoryInline` — list the ones you support, omit the rest
- [ ] AAA contrast on widget text vs widget background (test on lock screen with wallpaper)
- [ ] Tappable region is the whole widget (use `Link` or `widgetURL`, not `Button`)
- [ ] No animations inside a widget (widgets are static snapshots; animation lives in Live Activities)

## Reference reel — widget shapes that work

Proven widget shapes from shipped production apps. The structural code for each lives in the template's widget scaffold (`templates/swift/SeedWidgets/`).

### Native (Swift)

- **Quick-action widget** — edge-to-edge gradient, one accent, three font weights total; the lock-screen variant must work on photo wallpapers (the hardest test).
- **Recent-items list widget** — three-row list, localized relative dates, intelligent truncation. The title-row weight differs from body for visual hierarchy without changing color.
- **Live Activity** — all five presentations shipped. The Dynamic Island compact layout uses an SF Symbol on leading + a tiny number on trailing — never text labels in compact.
- **Ambient state widget** — a lock-screen circular variant showing e.g. a literal breathing circle. Static snapshot per timeline entry; the "animation" is the user's brain reading the size delta over time.

### RN (Expo-bridged)

- **Data-dots widget** — pure Swift in an Expo project, `.lproj/` localized strings for every supported language. JS calls `WidgetBridge.reloadAllTimelines()` when app state changes.
- **Daily-text widget** — lock-screen rectangular variant. Type-driven design — a single sentence-as-art piece.

### Avoid

- **Half-localized widget code.** We shipped a widget once where strings broke on widget surfaces because of the localization bundle mismatch described in rule 2 — the logic was fine, the l10n setup wasn't. Harvest widget structure only from a source that passes `WidgetLocalizationParityTests` — in this repo, that's the template's widget scaffold. If you need an App Intent that drives a widget, note that intent-side strings load from the correct bundle even when the widget-side display is broken — so a broken widget does not mean the intents are unusable.

## Timeline strategy

Per-widget, document one of:

1. **Static** — never updates after install. Examples: a "today's date" widget. Timeline returns one entry valid until `.never`.
2. **Calendar** — updates at known times. Examples: alarm countdown, sunset countdown. Timeline returns N entries, one per future tick.
3. **Triggered** — updates when app state changes. Examples: most app data widgets. App calls `WidgetCenter.shared.reloadAllTimelines()` after writes.
4. **Polling** — updates every N minutes via system schedule. Rare. Battery cost is real. Document why.

Comment at the top of every widget file states which strategy and why:

```swift
// Timeline: Triggered.
// Reloaded by the app on item save / delete / favorite.
// Snapshot uses placeholder data so widget gallery renders without app data.
```

## Live Activities

Same first-class treatment. Three rules:

1. **All five presentations.** (See rule 4 above.)
2. **Localized in extension bundle.** (See rule 2 above.)
3. **End the activity at the right time.** A Live Activity that lingers is worse than no Live Activity. End on the natural completion event; don't rely on the 8-hour system timeout.

Reference: the template's Live Activity scaffold in `templates/swift/SeedWidgets/`.

## Control Center quick actions (iOS 18+)

The hardest of the three native widget surfaces to get right — the entitlement, the bundle, the asset catalog targets, the symbol art rendering, all conspire to confuse.

When enabling, use the template's scaffold. Pattern:

- `Widgets/SeedControlButton.swift` — the `ControlWidget` declaration.
- Asset catalog membership for the SF Symbol must include the widget target.
- Entitlements: no special key, but the widget extension Info.plist needs `NSExtension > NSExtensionAttributes > WKAppBundleIdentifier`.

## Performance budget

Widgets run in a constrained process. Budgets:

- Snapshot view must render in ≤ 30 ms.
- Timeline provider's `timeline(for:in:completion:)` must complete in ≤ 5 seconds (system kills after).
- Memory: 16 MB hard cap on iPhone, 30 MB on iPad. Don't load large images; use SF Symbols.
- Disk reads: prefer the shared App Group container, prefer a small JSON over SwiftData (cold-start cost on widget process).

## When to skip a widget

Not every app needs a widget. Skip when:

- The app's state isn't glanceable.
- The widget would only serve as a "launch app" button (use a Shortcut instead).
- The user has to *do* something for the widget to be useful (widgets are read-only — taps deep-link, they don't act in place).

Document the decision in `DECISIONS/004-native-feature-checklist.md` either way.
