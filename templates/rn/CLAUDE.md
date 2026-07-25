# {{APP_NAME}} — CLAUDE.md

> Read this first, every session. This is your app's constitution.
> The wizard substitutes `{{PLACEHOLDERS}}` at `/new-app --commit` time
> using the values you captured in `DECISIONS/`. If you see a stray
> `{{...}}` token, the substitution failed — run `/init` to re-seed.

## Mission

{{MISSION}}

## Visual identity

**{{VISUAL_IDENTITY}}** — full rationale + portfolio diversity check in [`DECISIONS/015-visual-identity.md`](DECISIONS/015-visual-identity.md).

## Palette

The bespoke departure from the **{{PALETTE_SEED}}** seed (per the Kindling repo's `portfolio/PALETTE_CATALOG.md`). Full hex tokens live in [`theme/AppTheme.ts`](theme/AppTheme.ts); rationale + ΔE2000 matrix in [`DECISIONS/002-palette.md`](DECISIONS/002-palette.md).

{{PALETTE_TOKENS}}

## Signature motion

**{{SIGNATURE_MOTION}}** — see [`DECISIONS/009-signature-motion.md`](DECISIONS/009-signature-motion.md) for timing curve + Reduce Motion fallback. `react-native-reanimated` 4 is the only motion engine; respect the OS Reduce Motion preference at every `withTiming` / `withSpring` site.

## Typography

**{{TYPOGRAPHY_SPECIMEN}}** — 7-token API in [`theme/Typography.ts`](theme/Typography.ts). Never use raw `fontSize:` in components; go through `useTheme().type.<token>`. Rationale in [`DECISIONS/011-typography.md`](DECISIONS/011-typography.md).

## Haptic vocabulary

3 starter patterns: **{{HAPTIC_NAMES}}**. RN uses `expo-haptics` impact / notification / selection types. The full 24-pattern reference catalog only exists in Swift; the RN side maps the chosen 3 onto the closest expo-haptics primitives.

Earn a 4th via `/earn-haptic` — writes an ADR addendum, sleep on it. Soft cap 8.

## Delight moments

{{DELIGHT_MOMENTS}}

See [`DECISIONS/014-delight-moments.md`](DECISIONS/014-delight-moments.md). Cap is 5; a 6th requires an addendum.

## Monetization

**Tier {{TIER}}** — see [`DECISIONS/003-monetization.md`](DECISIONS/003-monetization.md).

Wired through `react-native-iap` 12 (no RevenueCat). Note that **Universal Purchase is NOT supported between iOS and Android** — separate product IDs per platform.

## Localization

Tier-1 locales (en, es, de, fr, pt, ja, zh-Hans) ship as JSON files under [`i18n/locales/`](i18n/locales/). Run `/translate <lang>` per locale to replace the English-fallback stubs with real translations before App Store submission. See `i18n/locales/STATUS.md`.

## iCloud sync

If `DECISIONS/008-data-model-and-sync.md` says yes:

- Native module: [`modules/icloud-sync/`](modules/icloud-sync/) (generic Expo module — production-proven pattern, refactored for reuse).
- Entitlements plugin: [`plugins/withICloudEntitlements.js`](plugins/withICloudEntitlements.js).
- Set `SyncConfig.appNamespace` in `modules/icloud-sync/ios/ICloudSyncModule.swift` to `{{APP_NAMESPACE}}`.

## Reminders / notifications

[`src/services/NotificationService.ts`](src/services/NotificationService.ts) implements the **rolling 64-limit pattern**, proven in a shipped production app. Yearly reminders auto-reschedule from the notification-received handler so the window stays topped up.

Always check `NotificationService.pendingCount()` before scheduling more — iOS caps at 64. Eight slots of headroom is the safe floor.

## Taste rules — inherited from Kindling

(See the Kindling repo's root `CLAUDE.md` for the canonical seven rules.)

1. **Services default off.** Every service ships dormant in `src/services/_Disabled/` (or commented-imported in `app/_layout.tsx`). Wizard graduates per `DECISIONS/004-native-feature-checklist.md`.
2. **Haptics are earned.** 3 starter; 4th+ via `/earn-haptic`. Soft cap 8.
3. **Six design-first checkpoints precede tech.** All captured in `DECISIONS/`.
4. **Visual identity novelty is a feature.** This app's `{{VISUAL_IDENTITY}}` is the choice.
5. **Palettes are departure points.** Final hex tokens in `theme/AppTheme.ts`.
6. **Sleep is required** before major decisions.
7. **NOT_FOR rejects manipulative patterns, not engagement.** Read the Kindling repo's `docs/NOT_FOR.md` AND `docs/WHATS_ALLOWED.md`.

## Code-quality rules

- **No `any` in production code.** Use `unknown` + narrowing, or declare the precise type.
- **No `!` non-null assertions.** Use early-return guards or `??`.
- **All UI strings through `t()` from `react-i18next`.** No literal English in `<Text>`.
- **Components ≤ 250 lines.** Hard limit; extract subviews.
- **One Context per concern.** ThemeContext doesn't own subscription state; a SubscriptionContext does.
- **No new third-party deps without an ADR.** Pre-approved: anything `expo-*`, `@react-navigation/*`, `react-native-iap`, `react-native-reanimated`, `react-native-gesture-handler`, `react-native-safe-area-context`, `react-native-screens`, `i18next`, `react-i18next`. Everything else needs `DECISIONS/NNN-dependency-<name>.md`.
- **Reliability discipline.** Before harvesting a service from your portfolio, check the Kindling repo's `portfolio/REUSE_INDEX.md`. This template's `modules/icloud-sync/` is the gold-standard for iCloud sync; `src/services/NotificationService.ts` for rolling-window notifications.

## Common tasks (slash commands)

- **`/roadmap`** — session starter; shows what's next.
- **`/build`** — `expo prebuild --clean && expo run:ios`.
- **`/test`** — `jest` (the 5 RN housekeeping tests + suite).
- **`/archive`** — `npm run archive`; prebuild iOS, install pods, create `.xcarchive`, open Organizer.
- **`/generate-icons`** — regenerate icon PNGs from `assets/icon_master.svg` (icon, adaptive-icon, splash, favicon, notification, store).
- **`/app-store-graphics`** — generate App Store screenshots.
- **`/translate <lang>`** — fill missing translations in `i18n/locales/<lang>.json`.
- **`/earn-haptic`** — unlock a 4th+ pattern with an ADR addendum.
- **`/init`** — re-seed this CLAUDE.md if `{{placeholders}}` leaked through.

## Bumping version

```sh
make bump-patch   # 1.0.0 -> 1.0.1
make bump-minor   # 1.0.0 -> 1.1.0
make bump-major   # 1.0.0 -> 2.0.0
```

Each command edits `app.json`'s `version` + iOS `buildNumber` + Android `versionCode`, creates a commit, and tags `v<version>`.

## Forbidden

- Never commit secrets (`.env`, App Store Connect API keys, signing certs, EAS credentials).
- Never force-push `main`.
- Never edit files outside the task scope.
- Never harvest widget l10n, Live Activity, or Control Center code from unproven sources — in Swift use the template's widget scaffold; for RN widgets follow the template's proven widget-extension pattern.
- Never ship a 4th haptic without `/earn-haptic`. Never ship a 6th delight moment without an addendum.
- Never use `Text>literal english</Text>` — always `t('key')`.

## When in doubt

1. **Mission** — can you state it in one sentence?
2. **Restraint** — does this feature earn its weight?
3. **Reliability** — is the source you're harvesting from production-grade? (See the Kindling repo's `portfolio/REUSE_INDEX.md`.)
4. **Taste** — would Jobs/Ive approve of the seam being invisible?
5. **Sleep** — have you slept on the decision?

If any answer is no, stop. Open a draft ADR. Come back tomorrow.
