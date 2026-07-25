# Recipes

Step-by-step guides for adding a feature to an existing portfolio app (or a fresh app generated from a template). Every recipe harvests from a **gold-standard source** named in [`portfolio/REUSE_INDEX.md`](../portfolio/REUSE_INDEX.md) — never from a source flagged ⚠️ WIP for that feature. In the starter state the gold-standard sources are the templates in this repo; where a template doesn't ship the code, the recipe carries the production-proven pattern inline.

## How to use a recipe

1. **Read the `When NOT to use` section first.** Recipes are easy to follow — that's the danger. The anti-pattern list is there to stop you adding a feature that doesn't earn its weight.
2. Open the cited source path (usually `templates/...` in this repo). Read it before you adapt it.
3. Follow the `How` steps. Run the verification command at the end.
4. If the feature has a `Services/_Disabled/` stub in the current app, move it up and uncomment the imports rather than re-harvesting.

## The four-section shape

Every recipe — no exceptions — has exactly these four sections:

1. **What it adds** — one paragraph.
2. **When to use** — bullet list of legitimate triggers.
3. **When NOT to use** — bullet list of anti-patterns.
4. **How** — file paths, source path, edit steps, verification command.

See [`_TEMPLATE.md`](_TEMPLATE.md) for the canonical skeleton.

## Index

### Swift (`swift/`)

| Recipe | Adds | Gold-standard source |
|---|---|---|
| [add-widgets](swift/add-widgets.md) | Native home/lock-screen widgets | `templates/swift/SeedWidgets/` |
| [add-live-activity](swift/add-live-activity.md) | Live Activities + Dynamic Island | `templates/swift/SeedWidgets/SeedLiveActivity.swift` |
| [add-control-center](swift/add-control-center.md) | Control Center quick actions (iOS 18+) | pattern inline (production-proven) |
| [add-apple-intelligence](swift/add-apple-intelligence.md) | Foundation Models, gated + fallback | `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift` |
| [add-app-intents](swift/add-app-intents.md) | App Intents + Siri shortcuts | `templates/swift/Seed/Intents/` (provider pattern) |
| [add-haptics](swift/add-haptics.md) | Haptic vocabulary (3-pattern subset) | `templates/swift/Seed/Utilities/HapticPatterns.swift` |
| [add-cloudkit-sync](swift/add-cloudkit-sync.md) | CloudKit + SwiftData | `templates/swift/Seed/Services/_Disabled/DataController.swift` |
| [add-storekit-paywall](swift/add-storekit-paywall.md) | StoreKit 2 + paywall | `templates/swift/Seed/Services/SubscriptionManager.swift` |
| [add-sendable-engine](swift/add-sendable-engine.md) | Pure Sendable domain logic | pattern inline (production-proven) |
| [add-sheet-navigation](swift/add-sheet-navigation.md) | Single-screen + sheets navigation | `templates/swift/Seed/Services/_Disabled/NavigationRouter.swift` |
| [add-analytics](swift/add-analytics.md) | TelemetryDeck analytics | `templates/swift/Seed/Services/_Disabled/AnalyticsService.swift` |
| [app-privacy-declaration](swift/app-privacy-declaration.md) | ASC App Privacy label + `PrivacyInfo.xcprivacy` | pattern inline (deterministic mapping) |
| [add-notifications](swift/add-notifications.md) | Native local notifications | `templates/swift/Seed/Services/_Disabled/NotificationService.swift` |
| [add-app-review](swift/add-app-review.md) | Throttled review prompts | `templates/swift/Seed/Services/_Disabled/AppReviewService.swift` |
| [add-biometric-auth](swift/add-biometric-auth.md) | Face ID / Touch ID gate | `templates/swift/Seed/Services/_Disabled/BiometricAuthService.swift` |
| [add-keychain](swift/add-keychain.md) | Keychain wrapper | `templates/swift/Seed/Services/_Disabled/KeychainService.swift` |
| [add-spotlight](swift/add-spotlight.md) | Spotlight indexing | `templates/swift/Seed/Services/_Disabled/SpotlightService.swift` |
| [add-mac-catalyst](swift/add-mac-catalyst.md) | Mac Catalyst + Universal Purchase | template `project.yml` ⚠️ pattern-only |
| [add-share-extension](swift/add-share-extension.md) | Share Extension | ⚠️ pattern-only (no shipped source yet) |
| [add-quicklook](swift/add-quicklook.md) | QuickLook previews + thumbnails | ⚠️ pattern-only (no shipped source yet) |
| [add-xcodegen](swift/add-xcodegen.md) | Working with `project.yml` (discipline) | `templates/swift/project.yml` |
| [add-collections-data-model](swift/add-collections-data-model.md) | Lists of structured things (parent/child SwiftData) | `templates/swift/Seed/Models/Item.swift` |
| [add-photo-capture](swift/add-photo-capture.md) | Photo library pick + camera capture | ⚠️ pattern-only (production-proven) |
| [add-timers](swift/add-timers.md) | Countdown/elapsed timers that survive backgrounding | `templates/swift/Seed/Services/_Disabled/NotificationService.swift` |
| [add-share-export](swift/add-share-export.md) | Outbound share cards + data export | ⚠️ pattern-only (production-proven) |
| [delight-animations](swift/delight-animations.md) | Copy-ready delight snippets (wizard-seeded) | `docs/DELIGHT_REEL.md` |

### React Native (`rn/`)

| Recipe | Adds | Gold-standard source |
|---|---|---|
| [add-rn-widgets](rn/add-rn-widgets.md) | Native Swift widget in an Expo app | pattern inline (production-proven) |
| [add-rn-notifications](rn/add-rn-notifications.md) | Local notifications, rolling 64-cap | `templates/rn/src/services/NotificationService.ts` |
| [add-rn-icloud-sync](rn/add-rn-icloud-sync.md) | iCloud sync via Expo module | `templates/rn/modules/icloud-sync/` |
| [add-rn-onboarding](rn/add-rn-onboarding.md) | Multi-screen onboarding | pattern inline (production-proven) |
| [add-rn-storage](rn/add-rn-storage.md) | Type-safe AsyncStorage wrapper | pattern inline (production-proven) |
| [add-rn-photo-capture](rn/add-rn-photo-capture.md) | Photo library pick + camera capture | ⚠️ pattern-only (Expo first-party modules) |
| [add-rn-reminders](rn/add-rn-reminders.md) | Reminder scheduling | pattern inline (production-proven) |
| [add-rn-rating](rn/add-rn-rating.md) | Store-review prompts | pattern inline (production-proven) |
| [add-rn-theme-registry](rn/add-rn-theme-registry.md) | Multi-theme registry | pattern inline (production-proven) |
| [add-rn-i18n](rn/add-rn-i18n.md) | i18next + expo-localization | `templates/rn/i18n/` |
| [add-rn-eas](rn/add-rn-eas.md) | EAS Build profiles | pattern inline (`eas.json` convention) |
| [add-rn-prebuild](rn/add-rn-prebuild.md) | Expo prebuild + config plugins (discipline) | `templates/rn/plugins/` |

### Cross-cutting (repo root of `recipes/`)

| Recipe | Adds | Source |
|---|---|---|
| [accessibility-sweep](accessibility-sweep.md) | Portfolio a11y checklist (Swift + RN), mechanical vs judgment | each app's a11y scan (the template `/review` skill) |
| [widget-design](widget-design.md) | The widget visual checklist (native + RN) | `docs/WIDGETS.md` |
| [earn-haptic](earn-haptic.md) | Process for unlocking a 4th+ haptic | `docs/HOUSEKEEPING.md` + the `/earn-haptic` skill |
| [add-sound-design](add-sound-design.md) | Ambient + chime audio | `templates/swift/Seed/Services/_Disabled/SoundService.swift` |
| [app-store-screenshots](app-store-screenshots.md) | Real screenshot capture + App Store frame pipeline | pattern inline (production-proven) |
| [app-store-videos](app-store-videos.md) | Reviewer walkthroughs + public App Store previews | `.claude/skills/record-app-store-video/` |
| [archive-ios](archive-ios.md) | One-command App Store archive path | `templates/swift/bin/archive-ios.sh` + `templates/rn/scripts/archive-ios.sh` |
| [app-review-readiness](app-review-readiness.md) | Evidence-based policy + archive + device preflight | `.claude/skills/apple-app-review/` |

All 41 recipes are written: 21 Swift, 11 RN, 8 cross-cutting, plus `delight-animations` (wizard-seeded). A few (`add-share-extension`, `add-quicklook`, `add-mac-catalyst`) are marked **⚠️ pattern-only** — no shipped app proves them yet; the first app to ship one writes the canonical version back via `/sync-from-portfolio`. [`DECISIONS/005-launch-readiness.md`](../DECISIONS/005-launch-readiness.md) tracks overall phase status.

## Recipe accuracy

[`scripts/check-recipe-sources.sh`](../scripts/check-recipe-sources.sh) walks the `Source:` header of every recipe in `recipes/**/*.md` and verifies that each cited in-repo path (`templates/...`, `docs/...`, `.claude/skills/...`) actually exists — catching renames and typos before they ship a dead pointer. It runs as the `verify-recipes` job in [`.github/workflows/ci.yml`](../.github/workflows/ci.yml). Recipes are only as trustworthy as their sources.
