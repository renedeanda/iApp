# Add Control Center quick actions (iOS 18+)

> **Source:** *pattern described inline* — proven in a shipped production app; the control lives inside the template's widget scaffold (`templates/swift/SeedWidgets/`) once added.
> **Platform:** Swift
> **Reliability:** ✅ the pattern is production-proven — but this is the hardest of the three native widget surfaces, so follow the steps exactly.

## What it adds

A `ControlWidget` that places a quick-action button (toggle or push) in Control Center, accessible from the lock screen and the swipe-down panel. The control performs one fast action — start a reset, create a quick note, toggle a mode — without launching the app.

## When to use

- There is **one** action so frequent and so fast that a Control Center button genuinely saves the user a launch.
- The action is **idempotent or clearly reversible** — Control Center taps are easy to hit by accident.
- The app already ships widgets and an App Intent for the action (the Control reuses the intent).

## When NOT to use

- **More than one or two controls.** Control Center is shared real estate. One control per app is the norm; a second needs a strong reason.
- **The action needs context or confirmation.** Controls fire instantly with no UI. Anything destructive, anything that needs a parameter the user picks — not a control.
- **You haven't shipped the App Intent yet.** A `ControlWidget` is a thin shell over an `AppIntent`. Build [add-app-intents](add-app-intents.md) first.
- **Pre-iOS-18 is a meaningful share of your users.** `ControlWidget` is iOS 18+. Guard with availability and make sure the app is fully usable without it.

## How

### 1. Harvest

- The pattern (proven in production): a `ControlWidget` declaration inside the widget extension, plus the asset-catalog and Info.plist setup around it — all described in Wire below.
- Create: `<App>/Widgets/<App>ControlButton.swift`.

### 2. Wire

- **The intent:** the control's action is an existing `AppIntent` (`perform()` does the work). If it doesn't exist, do [add-app-intents](add-app-intents.md) first.
- **Control declaration:** `ControlWidget` with a `ControlWidgetButton` or `ControlWidgetToggle`. Provide a `displayName`, an SF Symbol, and a tint.
- **Asset catalog membership:** if the control uses a custom symbol, the symbol's asset must include the **widget extension target** in its target membership — not just the app. This is the step that's easiest to miss.
- **Info.plist:** the widget extension's Info.plist needs `NSExtension > NSExtensionAttributes > WKAppBundleIdentifier` set to the host app's bundle id.
- **Register** the control in the widget bundle (`<App>WidgetBundle.swift`) alongside the regular widgets.
- **pbxproj:** new file → PBXBuildFile entry in the widget target. Run `/pbxproj-check`.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# then, on the simulator: swipe down for Control Center → + → find the app's control → add it → tap it.
```

Expected: build green; the control appears in the Control Center gallery; tapping it performs the intent without launching the app.

## Gotchas

- The control's symbol renders in a constrained, monochrome-ish context — test it small. Detailed art turns to mud.
- A `ControlWidgetToggle` needs its state to come from a source of truth the intent also writes — otherwise the toggle and the app disagree.
- Availability: wrap the `ControlWidget` registration in `if #available(iOS 18, *)` inside the bundle, or the whole bundle fails to load on iOS 17.
