# Add alternate app icons + the "Snow" seasonal variant (Swift)

> **Source:** `templates/swift/Seed/Theme/AppIconOption.swift` + `templates/swift/Seed/Views/Settings/AppIconPickerView.swift` (the enum + picker). The Python render → asset catalogs → `setAlternateIconName` pipeline is proven in production. RN reference: an Expo config-plugin pattern (described below).
> **Platform:** iOS (alternate icons are iOS-only)
> **Reliability:** ✅ proven across multiple shipped production apps.

## What it adds

A user-selectable alternate app icon, plus a portfolio-wide shared **Snow** seasonal variant. Snow is a *per-identity frosted reinterpretation of the app's own mark* — a cool-white/pale-frost field with the app's accent as a wintry tint — NOT one literal white recipe. It must read as clearly distinct from the app's primary icon.

## When NOT to use

- **When the app has no icon picker and you only want Snow.** Build the picker first; a lone alternate with no UI to choose it is dead weight.
- **When the primary icon is already light/monochrome** (e.g. an ink-on-paper app whose primary is white-on-ink). A white "snow" would duplicate it — either skip Snow for that app, or design a dark "snow at night" inverse so it's distinct.
- **Generating PNGs on a non-macOS box.** `sips`/`qlmanage`/`actool` need macOS. Author the enum + render-script entry + project.yml on any machine, but run the render + build on a Mac.

## How

1. **Enum.** Add `case snow` to the app's `AppIconOption` / `AppIconPreference` enum (alphabetical/grouped as the app does). Keep it on the same Pro gate as the app's other alternates — Snow inherits, it does not change the gate.
2. **Art.** Add a `{ name: "snow", field: "#…", mark: "#…" }` entry to the app's alt-icon render script (`bin/render-alt-icons.py`, or wherever the app keeps it), choosing a frosted palette derived from the app's mark. Regenerate → produces `AppIcon-Snow.appiconset` (run on macOS).
3. **Register.** Add `AppIcon-Snow` to `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` in `project.yml` (XcodeGen) or `CFBundleAlternateIcons` in Info.plist (pbxproj). The primary stays `CFBundlePrimaryIcon`.
4. **Pick.** The existing `AppIconPickerView` renders the new case automatically if it iterates `AppIconOption.allCases`. `setAlternateIconName("AppIcon-Snow")` applies it; `nil` restores primary.
5. **Localize** the picker's display name key for Snow across tier-1 locales.

### RN (Expo) apps

The same pattern is proven in shipped Expo apps: add the variant id to `constants/appIcons.ts` (or the Expo `expo-alternate-app-icons` config), generate the 1024² PNG (a Sharp-based `generate-app-icons.js` script), and the config plugin wires `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` on prebuild. Verify the picker (`AppIconSelector.tsx`) shows it.

## Verify

- [macOS] Render script produces `AppIcon-Snow.appiconset` with a 1024² + all sizes, opaque (no alpha).
- Build; Settings → App Icon → select **Snow** → icon changes; revert restores primary.
- Snow respects the app's existing Pro gate (locked for free users where other alternates are).
- Snow is visually distinct from the primary (skip/redesign if not — see "When NOT to use").
