# Add portfolio cross-promotion (Swift)

> **Source:** `templates/swift/Seed/Services/PortfolioRegistry.swift` + `templates/swift/Seed/Views/Settings/MoreFromStudioSection.swift`; registry data in `portfolio/CROSS_PROMO_REGISTRY.json`. RN reference: the same pattern as a "Made with care" row in an Expo Settings screen, proven in production.
> **Platform:** iOS / macOS (SwiftUI)
> **Reliability:** ✅ Apple-compliant — plain links, no incentivization, no interruptive modal.

## What it adds

Two Settings surfaces:
1. **"Made with care by Your Studio"** — one always-present row that opens the studio site. Every app gets this.
2. **"More from Your Studio"** — a list of sibling apps that are **live on the App Store**, hidden entirely when none are. Flagship apps (those with a real Settings/About surface) get this; lightweight apps can ship just the row.

## When NOT to use

- **As an interstitial / modal / launch interrupt.** Cross-promo lives quietly in Settings, never in a popup.
- **Linking to unreleased apps.** The registry filters to non-empty `appStoreURL`, so a not-yet-shipped app never produces a dead link. Don't hardcode a coming-soon App Store URL.
- **With any "download X to unlock Y" incentivization.** That violates App Review guideline 3.2.2. Plain links only.

## How

1. **Vendor the registry.** Copy `portfolio/CROSS_PROMO_REGISTRY.json` into the app's Resources as `CrossPromoRegistry.json` and add it to *Copy Bundle Resources* (XcodeGen: it's picked up from the synced folder; pbxproj: add explicitly). Refresh it when a sibling launches (set its `appStoreURL`).
2. **Add the loader.** Copy `PortfolioRegistry.swift` into `Services/`. `liveApps()` excludes the current app by `Bundle.main.bundleIdentifier` and returns only live siblings.
3. **Add the section.** Copy `MoreFromStudioSection.swift` into `Views/Settings/`; adapt the theme tokens (`AppTheme`/`Typography`) and localization keys to the host app. Drop `MoreFromStudioSection()` into the Settings `List`/`Form`. For a row-only app, keep just the "Made with care" `Button`.
4. **Localize.** Translate `madeWithCare.title`, `madeWithCare.subtitle`, `moreApps.title`, `moreApps.openAppStore` to the app's tier-1 locales in the same commit (`/translate`). App names + taglines come from the registry as `Text(verbatim:)` — do not localize brand names.

## Verify

- Build; open Settings → tap "Made with care" → opens your studio URL (`https://example.com` in the seeded registry).
- With the seeded registry, the "More from" list shows the fictional example apps marked live (e.g. Sample Notes, Sample Timer); the current app is absent.
- Temporarily blank both live URLs → the whole "More from" section disappears (only the care row remains).
