# ADR 001 — Tech Choice

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** iApp
- **Authors:** iApp maintainers

## Context

iApp itself is mostly Markdown (docs, ADRs, recipes) plus a few shell scripts. But it ships **two templates** — one Swift, one RN — and the tech for each template is its own decision.

## Decision

**iApp repo:** Markdown + shell scripts. No app code.

**Swift template (`templates/swift/`):**
- XcodeGen for project generation (no checked-in `.xcodeproj`)
- SwiftUI + SwiftData + CloudKit
- StoreKit 2 (no third-party billing SDK)
- TelemetryDeck for anonymous analytics
- Swift Testing for new tests; XCTest only when extending existing suites
- iOS 26 minimum; Mac Catalyst opt-in
- No third-party UI libraries

**RN template (`templates/rn/`):**
- Expo SDK 54 + RN 0.81
- TypeScript strict
- Expo Router for navigation
- i18next + expo-localization
- EAS Build (no bare workflow)
- Native widgets via Expo modules (Swift code in `ios-widget/`, JS shim in `modules/widget-bridge/`)

## Portfolio-wide tech-mix rationale

A portfolio benefits from **both Swift native and RN** for the same reason it benefits from both subscription and IAP (see [ADR 003](003-monetization.md)): deliberate diversification.

- **Swift native** carries the **technically-demanding tier** — Apple Intelligence (Foundation Models), Live Activities, Control Center quick actions, Mac Catalyst (Universal Purchase), pure Sendable domain engines. These features either don't exist on RN or require fragile bridges that break on every iOS / RN upgrade (a hand-rolled custom CloudKit bridge in a bare-RN app is the cautionary tale we lived through).

- **RN with Expo SDK 54+** carries the **simpler-bounded tier** — utility apps, content unlocks, multilingual breadth (a 15-language `.lproj` setup shipped painlessly in RN), apps where the cross-platform path *might* matter later.

This dovetails with the monetization ladder ([ADR 003](003-monetization.md)):
- RN apps tend toward **Tier 0–1** (lower complexity → lower price → simpler infra)
- Swift apps tend toward **Tier 2–3** (more capability → higher price → some require ongoing infra)
- Mac Catalyst opt-in pushes any Swift app to the **top of its tier band** (Universal Purchase = pricing confidence)

Not a hard rule, a strong correlation. The `/pick-tech` wizard step uses it as a starting recommendation: simpler-bounded mission → RN; AI/Live Activities/Catalyst mission → Swift. User can override; the override is logged in this ADR.

**Why not unify on one stack?** Swift-only would lock out the rapid-iteration content / multilingual utility tier (15 locales of daily content is painful in Swift); RN-only would lock out the AI / Live Activities / Mac Catalyst tier (no RN bridge exists for Foundation Models that survives an iOS upgrade cycle). The mix is the moat.

## Options considered

For the templates:

- **Bare React Native** — rejected. We shipped a bare-RN app whose custom CloudKit bridge became a maintenance trap: every iOS / RN upgrade required touching the bridge. Expo + config plugins contains that risk.
- **Flutter** — rejected. Doesn't access the iOS feature surface (App Intents, Live Activities, Foundation Models) cleanly. Not Apple-feature-friendly.
- **Swift only, no RN template** — rejected. The RN tier's patterns (multilingual widgets, notification scheduling, iCloud KV bridge) are proven and worth scaffolding.
- **Tuist instead of XcodeGen** — rejected. Tuist is more powerful but adds a Ruby dependency. XcodeGen is one binary and has shipped multiple production apps unchanged.
- **Third-party billing SDK (e.g. RevenueCat)** — rejected. Adds a SaaS dependency for something StoreKit 2 does natively. Multiple shipped apps prove StoreKit 2 is enough.

## Consequences

- **Unlocks:** every recipe, every template service decision, every CI workflow.
- **Forecloses:** Android. The templates are iOS-only. If you ever target Android, the RN template is the starting point — but no iApp doc currently considers Android.
- **Cost to revisit:** swapping XcodeGen for Tuist is medium. Adding Android is large. Swapping Expo for bare RN is large.

## Cross-references

- [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — where each template service comes from
- [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) — Swift template Xcode hygiene
- [docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md) — code-level expectations
