# ADR 004 — Native Feature Checklist

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

The Swift template ships 20+ services on disk; a typical new app enables 4–6. The taste rule (CLAUDE.md #1: "services default off") only works if every new app explicitly opts each service in. This ADR is where that opt-in lives for the child app — and for Kindling itself.

## Decision

**Kindling as a docs-only repo enables zero native features.** No CloudKit, no widgets, no StoreKit, no Live Activities — there's no app to enable them on. The `templates/swift/` directory *contains* every gold-standard service in `Services/_Disabled/`, but Kindling itself never instantiates any of them.

For each child app, this ADR is the explicit yes/no list. The wizard's `/reliability-check` step runs in parallel — for each ✅ here, it confirms the gold-standard source per REUSE_INDEX is harvested correctly.

Child app ADR 004 fills in this checklist:

| Service | Enabled? | Gold-standard source (per REUSE_INDEX) | Notes |
|---|---|---|---|
| CloudKit + SwiftData | ☐ | `Seed/Services/_Disabled/DataController.swift` | |
| StoreKit 2 + paywall | ☐ | `Seed/Services/_Disabled/SubscriptionManager.swift` | Skip if monetization=Free with no IAP |
| Apple Intelligence | ☐ | `Seed/Services/_Disabled/OnDeviceAIService.swift` | Pro-gated, nil-fallback mandatory |
| BYOK AI providers | ☐ | `Seed/Services/_Disabled/BYOKProvider.swift` | Keychain-only secrets; deterministic fallback; use the curated model policy |
| Widgets | ☐ | `templates/swift/SeedWidgets/` ONLY | Widget extension has its own xcstrings (the widget-bundle trap) |
| Live Activities | ☐ | `SeedWidgets/` views + `Seed/Services/_Disabled/LiveActivityService.swift` | All 5 regions tested |
| Control Center quick actions | ☐ | `SeedWidgets/SeedControlButton.swift` ONLY | iOS 18+ |
| App Intents + Siri | ☐ | `Seed/Services/_Disabled/` intents scaffold | Intent extension has its own xcstrings |
| Spotlight | ☐ | `Seed/Services/_Disabled/SpotlightService.swift` | |
| Biometric lock | ☐ | `Seed/Services/_Disabled/BiometricAuthService.swift` | Face ID / Touch ID |
| Notifications | ☐ | `Seed/Services/_Disabled/NotificationService.swift` | Defer permission ask |
| App Review prompt | ☐ | `Seed/Services/_Disabled/AppReviewService.swift` | Post-success only |
| Sound (chime/ambient) | ☐ | *(forward-looking — see REUSE_INDEX SoundService row)* | Rare |
| Mac Catalyst | ☐ | (template-supported; no service) | Opt-in target only |
| Share Extension | ☐ | (no gold-standard yet) | Custom per app |
| Quick Actions | ☐ | `Seed/Services/_Disabled/QuickActionService.swift` | Home-screen long-press menu |
| Settings Sync | ☐ | `Seed/Services/_Disabled/SettingsSyncService.swift` | CloudKit key-value pairs |

When a service is enabled, the wizard moves its file out of `Services/_Disabled/` and uncomments imports. The ADR records the decision and gives `/reliability-check` something to verify against.

### App Privacy declaration (set when analytics or any data-transmitting service is enabled)

Enabling analytics (or any service that transmits data) carries a submission obligation that's inherited *here*, not discovered on submission day. A child app records its App Store Connect **App Privacy** answer:

| Signal in this app | ASC App Privacy declaration |
|---|---|
| **TelemetryDeck enabled** (the sanctioned analytics dep) | **Usage Data → Product Interaction**, *not linked to identity, not used for tracking*, purpose **Analytics**; `NSPrivacyTracking=false`; backed by `PrivacyInfo.xcprivacy`. |
| **No analytics, no other transmitted data** | **Data Not Collected** (still ship `PrivacyInfo.xcprivacy` for Required Reason APIs). |
| **Crash reporter (Sentry)** added | also declare **Diagnostics → Crash Data** (not auto-detected). |
| `NSUserTrackingUsageDescription` present | **contradiction** — either set Used for Tracking: Yes + declare the identifier, or drop the unused string. |

The ASC public API **cannot** set the nutrition label — it is a manual web-UI step. The standard + exact ASC steps live in [recipes/swift/app-privacy-declaration.md](../recipes/swift/app-privacy-declaration.md).

## Options considered

- **Enable everything by default** — rejected. Violates CLAUDE.md rule 1 (services default off). Bloats the binary. Every unused capability is a sign the architect didn't trust the mission.
- **Ship a thin scaffold (no `_Disabled/` services)** — rejected. Trades startup speed for sync friction. The win of "everything is already harvested" is real; the discipline lives in this ADR + the wizard, not in pruning the file tree.
- **Make this ADR a free-form prose decision** — rejected. The checklist format is the *test surface* for `/reliability-check`. Free-form prose can't be enforced.

## Consequences

- **Unlocks:** `/reliability-check` parses this file's table. For each ✅, it verifies the matching gold-standard source. For each ⚠️ in REUSE_INDEX, it refuses to harvest from the WIP source even if the user thinks they want it.
- **Forecloses:** services not on this checklist can still be added — but adding a new service to the template requires updating the checklist *here* + REUSE_INDEX + the wizard. The list is the canon.
- **Cost to revisit:** medium per service (add row to checklist + REUSE_INDEX + verify against template's `_Disabled/`).

## Cross-references

- [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — gold-standard source per feature
- [docs/WIDGETS.md](../docs/WIDGETS.md) — first-class widget rules
- [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) — what ships in `Services/_Disabled/`
- [CLAUDE.md](../CLAUDE.md) taste rule 1 — services default off
