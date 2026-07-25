# Reviewer Notes — Seed

> Wizard substitutes "Seed" → app name at /new-app --commit time.
> This file is provided to App Store Reviewers via App Store Connect
> "App Review Information → Notes."

## What this app does

{{MISSION}}

## Test account

Not required. The app works without account creation.

## How to test premium features

In DEBUG builds, **Settings → Developer → Force Premium** unlocks Pro
features instantly.

In RELEASE builds, premium features are gated by StoreKit purchases
configured per `Seed.storekit`. The sandbox StoreKit environment will
display test products at $0 — purchase any of them to unlock.

## Hidden / developer surfaces

The app includes a **non-discoverable developer debug menu** behind a
7-tap gesture on the version string in Settings → About. This is a
developer utility, never used in user-facing flows:

- Requires 7 consecutive taps within 2 seconds
- Auto-suppressed when the run looks like a fresh App Store sandbox
  install (within 1 hour of first launch)
- Any unlock is bounded to 24 hours; flag wipes on every version bump

The menu exists for early-user production testing of premium features
(common case: developers + first 50 users post-launch). It does not
bypass monetization at scale, leak data, or expose customer info.

If you'd prefer this surface fully removed before approval, we can
ship a build with the gesture recognizer compiled out — let us know.

## Privacy

- No tracking. `NSPrivacyTracking` is `false` in `PrivacyInfo.xcprivacy`.
- All required-reason API usage is declared.
- No analytics SDKs except optionally TelemetryDeck (privacy-preserving
  aggregate signals only; no per-user identifiers).

## Support

See `docs/SUPPORT.md` for the contact path.

## Notes for accessibility review

- All motion respects `UIAccessibility.isReduceMotionEnabled`.
- Haptics respect `UIAccessibility.isReduceMotionEnabled` (the
  Apple-standard signal for "no haptics either").
- All text/background contrast meets WCAG AAA on the primary surface
  (verified by `ThemeContrastTests`).
- Every interactive element has a VoiceOver label.
