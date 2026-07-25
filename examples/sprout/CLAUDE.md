# Sprout — CLAUDE.md

> Read this first, every session. This is your app's constitution.
> The wizard substitutes `{{PLACEHOLDERS}}` at `/new-app --commit` time
> using the values you captured in `DECISIONS/`. If you see a stray
> `{{...}}` token, the substitution failed — run `/init` to re-seed.

## Mission

Tiny daily wins, logged in five seconds, growing into proof.

## Visual identity

**Warm-minimal** — full rationale + portfolio diversity check in [`DECISIONS/015-visual-identity.md`](DECISIONS/015-visual-identity.md).

## Palette

The bespoke departure from the **Sage** seed (per `portfolio/PALETTE_CATALOG.md` in the Kindling repo this app was generated from). Full hex tokens live in [`Sprout/Theme/AppTheme.swift`](Sprout/Theme/AppTheme.swift); rationale + ΔE2000 matrix in [`DECISIONS/002-palette.md`](DECISIONS/002-palette.md).

Surface `#E8EBE3` / `#181B14` · OnSurface `#21261E` / `#E4E8DF` · Accent `#5F7A55` / `#93AC89` (Sage, departed: surface cooled 6°, accent desaturated ~12%).

## Signature motion

**Breathing (template default, kept deliberately)** — see [`DECISIONS/009-signature-motion.md`](DECISIONS/009-signature-motion.md) for timing curve + Reduce Motion fallback. Use `motionSafeAnimation()` (in `Sprout/Theme/MotionSafe.swift`) everywhere instead of bare `.animation()`.

## Typography

**Rounded-system** — 7-token API in [`Sprout/Theme/Typography.swift`](Sprout/Theme/Typography.swift). Never call `.system(size:)` directly; go through `Typography.<token>`. Rationale in [`DECISIONS/011-typography.md`](DECISIONS/011-typography.md).

## Haptic vocabulary

3 starter patterns: **bloomOpen · completionRing · reminderSoft** — defined in [`Sprout/Utilities/HapticPatterns.swift`](Sprout/Utilities/HapticPatterns.swift).

The full 24-pattern reference (distilled from a shipped production app) lives at [`Sprout/Utilities/_HapticVocabulary/HapticPatterns.full.swift`](Sprout/Utilities/_HapticVocabulary/HapticPatterns.full.swift) (excluded from compile). Earn a 4th via `/earn-haptic` — writes an ADR addendum, sleep on it. Soft cap 8.

Reduce Haptics is gated in `HapticManager` (checks `UIAccessibility.isReduceMotionEnabled` + the optional `settings.reduceHaptics` UserDefault).

## Delight moments

Result reveal on logging a win · celebration pop on a 7-day run · breathing idle tile.

See [`DECISIONS/014-delight-moments.md`](DECISIONS/014-delight-moments.md) for the table — each moment with its source file path, the user action that fires it, and the Reduce Motion fallback. Cap is 5; a 6th requires an addendum.

The moments live as code in [`Sprout/Theme/DelightMoments.swift`](Sprout/Theme/DelightMoments.swift) — reusable, Reduce-Motion-aware modifiers (`.resultReveal()`, `.celebrationPop(_:)`); `/wire-first-screen` applies them to the first screen. A bespoke moment is added there, never scattered inline.

## Monetization

**Tier 0 — pure free (no infra costs; the gift tier)** — see [`DECISIONS/003-monetization.md`](DECISIONS/003-monetization.md).

The dev premium toggle is wired through [`Sprout/Services/SubscriptionManager.swift`](Sprout/Services/SubscriptionManager.swift). `isPro` is the single authoritative read for premium-gated features. Force Premium short-circuits via [`Sprout/Utilities/DebugUnlock.swift`](Sprout/Utilities/DebugUnlock.swift): hard-gated to non-production builds (inert when `AppTransaction.environment == .production`), 24h auto-expiry, clear-on-bundle-version-change, reviewer-suppressed (StoreKit sandbox/TestFlight environment + 1h fresh-install window).

## Universal Purchase

iOS-only. No Mac Catalyst — the five-second log is a pocket gesture.

## Taste rules — inherited from Kindling

(See the root `CLAUDE.md` of the Kindling repo this app was generated from for the canonical seven rules.)

1. **Services default off.** Every service ships in `Sprout/Services/_Disabled/` and is graduated by `/new-app --commit` per `DECISIONS/004-native-feature-checklist.md`.
2. **Haptics are earned.** 3 starter; 4th+ via `/earn-haptic`. Soft cap 8.
3. **Six design-first checkpoints precede tech.** All captured in `DECISIONS/`.
4. **Visual identity novelty is a feature.** This app's `Warm-minimal` is the choice.
5. **Palettes are departure points.** Final hex tokens in `Theme/AppTheme.swift`.
6. **Sleep is required** before major decisions.
7. **NOT_FOR rejects manipulative patterns, not engagement.** Read `docs/NOT_FOR.md` AND `docs/WHATS_ALLOWED.md` in the Kindling repo this app was generated from.

## Code-quality rules

- **No force-unwraps in production code.** Use `guard let`, `if let`, or `??`.
- **All UI strings through `Localizable.xcstrings`.** No literal English in `Text(...)`.
- **Swift Testing for new code.** XCTest only when extending existing XCTest suites.
- **Views ≤ 300 lines.** Hard limit; extract subviews.
- **One `@Observable` per concern.** `DataController` doesn't own subscription state; `SubscriptionManager` does.
- **No new third-party deps without an ADR.** TelemetryDeck is pre-approved.

## Common tasks (slash commands)

- **`/roadmap`** — session starter; shows what's next from DECISIONS/005.
- **`/build`** — `xcodebuild build` for iPhone 17 Simulator.
- **`/test`** — `xcodebuild test`, includes all 8 housekeeping tests.
- **`/archive`** — `make archive`; regenerate, run archive preflight/hooks, verify host/extension localization tables and privacy manifests in the built archive, create `.xcarchive`, open Organizer.
- **`/generate-icons`** — regenerate AppIcon + splash + notification + store icons from `icon_master.svg`.
- **`/app-store-graphics`** — generate App Store screenshots.
- **`/translate <lang>`** — fill missing translations in `Localizable.xcstrings`.
- **`/earn-haptic`** — unlock a 4th+ pattern with an ADR addendum.
- **`/init`** — re-seed this CLAUDE.md if `{{placeholders}}` leaked through.

## Bumping version

```sh
make bump-patch   # 1.0.0 -> 1.0.1
make bump-minor   # 1.0.0 -> 1.1.0
make bump-major   # 1.0.0 -> 2.0.0
```

Each command edits `Sprout/Version.xcconfig`, creates a commit, and tags `v<version>`.

## Forbidden

- Never commit secrets (`.env`, App Store Connect API keys, signing certs).
- Never force-push `main`.
- Never edit files outside the task scope.
- Widget l10n, Live Activity, and Control Center code come from this template's own widget scaffold (`SproutWidgets/`) — it is the proven gold-standard source; never harvest from unproven sources.
- App Intent semantic keys are allowed only when their English source units are
  reviewed/compiled and the built metadata resolves them. Invocation phrases
  use readable source text and must include `\(.applicationName)`.
- Never ship a 4th haptic without `/earn-haptic`. Never ship a 6th delight moment without an addendum.
- Never use `Text("literal")` for app names or other verbatim text — read from `Bundle.main.localizedInfoDictionary` instead (avoids SwiftUI's LocalizedStringKey trap).

## When in doubt

1. **Mission** — can you state it in one sentence?
2. **Restraint** — does this feature earn its weight?
3. **Reliability** — is the source you're harvesting from production-grade? (See `portfolio/REUSE_INDEX.md` in the Kindling repo this app was generated from.)
4. **Taste** — would Jobs/Ive approve of the seam being invisible?
5. **Sleep** — have you slept on the decision?

If any answer is no, stop. Open a draft ADR. Come back tomorrow.
