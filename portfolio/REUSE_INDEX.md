# Reuse Index — Feature → Gold-Standard Source Map

The single source of truth for "where do I copy this feature from?" Cross-referenced by `/reliability-check`, `/new-app`, every recipe, and every template's `// SOURCE:` header.

In iApp's starter state, the gold-standard source for every feature is **the template itself** — the scaffolds under `templates/swift/` and `templates/rn/` were distilled from multiple shipped production apps and are CI-verified. As *your* apps ship and improve on a pattern, this index evolves: your app becomes the gold-standard source for that feature, and `sync-from-portfolio` propagates the improvement back into the template.

**Rule:** never harvest a feature from a source that's flagged ⚠️ for that feature, even if the code "looks fine." A flag exists because a WIP state caused a real shipped problem (record it in [RECENT_LEARNINGS.md](RECENT_LEARNINGS.md)).

---

## Reliability matrix — Swift

Per-feature lookup. ✅ = gold-standard; ⚠️ = WIP / known issue.

| Feature | ✅ Use as gold-standard | Notes |
|---|---|---|
| **Native widgets** (edge-to-edge, localized) | `templates/swift/SeedWidgets/` | The hardest native surface to get right. The widget target ships its **own** `Localizable.xcstrings` — see [docs/WIDGETS.md](../docs/WIDGETS.md) rule 2. |
| **Live Activities + Dynamic Island** | `templates/swift/SeedWidgets/SeedLiveActivity.swift` + `Services/_Disabled/LiveActivityService.swift` | All five presentation regions covered. |
| **Apple Intelligence (Foundation Models)** | `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift` | `#if canImport(FoundationModels)` + runtime availability check + deterministic nil fallback. |
| **BYOK AI providers** (Anthropic, OpenAI, Google) | `templates/swift/Seed/Services/_Disabled/BYOKModelCatalog.swift` | Keys stay in Keychain; content goes directly to the selected provider; every call has a deterministic fallback. See `recipes/swift/add-byok-ai.md`. |
| **App Intents + Siri shortcuts** | `templates/swift/Seed/Intents/` | Intent strings load from the intent's bundle — same extension-bundle rule as widgets. |
| **App-extension localization** (each extension ships its OWN `Localizable.xcstrings`) | `templates/swift/SeedWidgets/Resources/Localizable.xcstrings` + `project.yml` resource pins | Every extension loads strings from its own bundle. Verified by `WidgetLocalizationParityTests`. See `recipes/swift/extension-localization.md`. |
| **Per-extension privacy manifests** | `templates/swift/{Seed,SeedWidgets}/PrivacyInfo.xcprivacy` + explicit `project.yml` pins | Pin each manifest as an explicit resource so it actually ships; `PrivacyManifestTests` enforces it. |
| **Dev/Debug premium toggle** (production hard-gate) | `templates/swift/Seed/Utilities/DebugUnlock.swift` | Inert in production via `AppTransaction.environment` — replaces the receipt-URL check removed in iOS 18. |
| **Haptic vocabulary (24 patterns)** | `templates/swift/Seed/Utilities/_HapticVocabulary/HapticPatterns.full.swift` | Every new app starts from a 3-pattern subset (CLAUDE.md taste rule 2). |
| **CloudKit + SwiftData** | `templates/swift/Seed/Services/_Disabled/DataController.swift` | Start minimal; grow only when the app's model demands it. |
| **StoreKit 2 + paywall** | `templates/swift/Seed/Services/SubscriptionManager.swift` + `Views/PaywallView.swift` | Clean StoreKit 2 baseline; no third-party billing SDK. |
| **Pure Sendable domain logic** | `recipes/swift/add-sendable-engine.md` | Value types, no UI imports, all `Sendable`. UI talks via `@Observable` services on `@MainActor`. |
| **Single-screen + sheets navigation** | `templates/swift/Seed/Services/_Disabled/NavigationRouter.swift` | Sheet-driven UX; no drill-down hierarchies deeper than 1. |
| **Theme system + Liquid Glass material** | `templates/swift/Seed/Theme/` | `AppTheme`, `Typography`, `Spacing`, `LiquidGlass`, `ThemeRootView`, button styles. |
| **Analytics (TelemetryDeck)** | `templates/swift/Seed/Services/_Disabled/AnalyticsService.swift` | Signal taxonomy + opt-out wiring included. |
| **Notifications** | `templates/swift/Seed/Services/_Disabled/NotificationService.swift` | Simple, clean, opt-in pattern. |
| **App review prompts** | `templates/swift/Seed/Services/_Disabled/AppReviewService.swift` | Throttled request after success moments. |
| **Biometric auth** | `templates/swift/Seed/Services/_Disabled/BiometricAuthService.swift` | Face ID / Touch ID wrapper with graceful fallbacks. |
| **Keychain** | `templates/swift/Seed/Services/_Disabled/KeychainService.swift` | Thin wrapper, no force-unwraps. |
| **Spotlight indexing** | `templates/swift/Seed/Services/_Disabled/SpotlightService.swift` | Index app entities for Spotlight + Siri suggestions. |
| **Milestone catalog** (Sendable enum pattern) | `templates/swift/Seed/Services/_Disabled/MilestoneCatalog.swift` | Milestone-as-acknowledgment (see WHATS_ALLOWED.md). |
| **Home-screen quick actions** | `templates/swift/Seed/Services/_Disabled/QuickActionService.swift` | The long-press menu on the app icon. |
| **Interactive onboarding + About replay** | `templates/swift/Seed/Views/OnboardingView.swift` + `AdaptiveOnboardingPage.swift` | Promise → input → payoff → trust, deferred permissions, replay from About. See `recipes/swift/add-interactive-onboarding.md`. |
| **Sound design** | `templates/swift/Seed/Services/_Disabled/SoundService.swift` | Optional; bake in only if the wizard says yes. |
| **Cross-promo section** | `templates/swift/Seed/Services/PortfolioRegistry.swift` + `Views/Settings/MoreFromStudioSection.swift` | Reads `CROSS_PROMO_REGISTRY.json`; live-apps-only, self-excluding, Apple-compliant plain links. |
| **Icon generation from SVG** | `templates/swift/bin/generate-icons.sh` + the `generate-icons` skill | Regenerates AppIcon.appiconset + splash + notification + store icons from `icon_master.svg`. |
| **App Store screenshot pipeline** | `tools/app-store-graphics/` | Real captures composed into localized store graphics. See `recipes/app-store-screenshots.md`. |
| **App Review pre-submission audit** | `.claude/skills/apple-app-review/` | Verify Apple's live rules, inspect the final archive, report evidence levels. See `recipes/app-review-readiness.md`. |
| **App Store / App Review video pipeline** | `.claude/skills/record-app-store-video/` | Separates private reviewer evidence from public 15–30s previews. See `recipes/app-store-videos.md`. |

## Reliability matrix — React Native

| Feature | ✅ Use as gold-standard | Notes |
|---|---|---|
| **RN widgets (native Swift, Expo plugin bridge)** | `recipes/rn/add-rn-widgets.md` | Widget i18n at scale needs per-locale `.lproj` in the widget target. |
| **RN local notifications** | `templates/rn/src/services/NotificationService.ts` | Rolling 64-limit window pattern, `setHours/setMinutes` iOS-compat, auto-reschedule on receive. |
| **RN iCloud sync** | `templates/rn/modules/icloud-sync/` | Clean Expo-module bridge — not a hand-rolled CloudKit bridge (a proven maintenance trap). |
| **RN onboarding (multi-screen, fade-in cadence)** | `recipes/rn/add-rn-onboarding.md` | Multi-page fade-in; permissions deferred to intent. |
| **RN storage (AsyncStorage wrapper)** | `recipes/rn/add-rn-storage.md` | Type-safe wrapper with namespacing + migration support. |
| **RN reminders / scheduling** | `recipes/rn/add-rn-reminders.md` | Full scheduling service pattern. |
| **RN rating prompts** | `recipes/rn/add-rn-rating.md` | Native `expo-store-review` with throttling. |
| **RN theme registry (multi-theme)** | `templates/rn/contexts/ThemeContext.tsx` + `theme/` | Registry pattern that scales to a dozen themes with per-theme accents. |
| **RN i18next + expo-localization** | `recipes/rn/add-rn-i18n.md` | Tier-1 locales day one. |
| **Expo config plugins (App Group, iCloud entitlements)** | `templates/rn/plugins/` | `withAppGroup.js`, `withICloudEntitlements.js`. |

---

## Repo shorthand convention

Recipes and code comments cite sources as plain repo-relative paths (`templates/swift/Seed/Theme/AppTheme.swift`). When your own apps become gold-standard sources, adopt a short `repo:path` shorthand and document the mapping here:

| Shorthand | Full repo URL |
|---|---|
| *(add yours as your apps ship)* | |

`// SOURCE:` headers in template files should use the full form, ideally pinned to a commit (`// SOURCE: <owner>/<repo>@<sha>:Path/File.swift`).

---

## Adding to this index

When one of your shipped apps proves a pattern is worth canonical status:

1. Open a PR adding a row in the appropriate table.
2. Cite the specific file path (full, not shorthand).
3. Justify why this should be canonical (proven in production for ≥4 weeks, no known issues, generalizes cleanly).
4. If it supersedes an existing row, mark the old row ⚠️ with a pointer to the new one and a date.
5. Consider running `sync-from-portfolio` to fold the improvement back into the template itself.

The matrix is small on purpose. Most things have one ✅ and zero ⚠️. Its value comes from being a curated index, not a comprehensive one.

---

## When the matrix is wrong

If a row is wrong (a feature flagged ⚠️ is actually fine, or a ✅ has a hidden bug):

1. Document in [RECENT_LEARNINGS.md](RECENT_LEARNINGS.md) with date + the specific bug.
2. Update this matrix.
3. Update `/reliability-check` if its enforcement logic depends on the changed row.

Don't ignore a flag. Don't quietly remove a flag without learnings. The matrix is how a portfolio stops repeating its mistakes.
