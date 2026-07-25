# Reviewer Notes — {{APP_NAME}}

> Wizard substitutes `{{APP_NAME}}` at `/new-app --commit` time.
> Provided to App Store Reviewers via App Store Connect
> "App Review Information → Notes."

## What this app does

{{MISSION}}

## Test account

Not required. The app works without account creation.

## How to test premium features

In sandbox, in-app purchases are configured via `react-native-iap`
(no RevenueCat). The sandbox StoreKit environment shows test products
at $0 — purchase any to unlock Pro features. Restore Purchases is on
the paywall and in Settings.

> Note: Universal Purchase is **not** supported between iOS and
> Android for RN apps — product IDs are per-platform.

## Privacy

- No tracking. `expo.ios.privacyManifests.NSPrivacyTracking` is
  `false` in `app.json`.
- Every required-reason API the template uses is declared in
  `app.json` → `expo.ios.privacyManifests` (verified by
  `__tests__/PrivacyManifest.test.ts`).
- No analytics SDKs by default. If TelemetryDeck is added later, it
  sends privacy-preserving aggregate signals only — no per-user
  identifiers — and is opt-out in Settings.

## Notifications

Local notifications only, and only ones the user schedules themselves
(see `src/services/NotificationService.ts`). No remote push, no
engagement / re-activation notifications.

## Support

See `docs/SUPPORT.md` for the contact path.

## Notes for accessibility review

- All motion respects the OS Reduce Motion setting
  (`AccessibilityInfo.isReduceMotionEnabled`).
- Haptics (`expo-haptics`) are gated on the same signal.
- Text/background contrast meets WCAG AAA on the primary surface
  (verified by `__tests__/ThemeContrast.test.ts`).
- Every interactive `Pressable` has an accessibility role + label;
  touch targets are ≥ 44×44pt.
