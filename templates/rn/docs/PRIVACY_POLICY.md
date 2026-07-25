# Privacy Policy — {{APP_NAME}}

> Publish at the URL specified in App Store Connect. GitHub Pages
> from this file works fine. Last updated: {{LAST_UPDATED}}.

## TL;DR

- {{APP_NAME}} stores your data on your device and (optionally) in your private iCloud.
- {{APP_NAME}} does not track you, does not collect personal data, does not sell anything to anyone.
- {{APP_NAME}} has no servers. There is no account.

## What stays on your device

- Everything you create or configure in the app (stored via AsyncStorage / local files).
- Preferences, including any in-app purchase state (managed by the App Store, not by us).
- Diagnostic information you choose to share via system Settings → Privacy → Analytics.

## What goes to iCloud (only if you enable it)

- Your data, syncing through your **private** iCloud database via the
  app's `modules/icloud-sync/` native module.
- We never see your iCloud content. Apple's CloudKit terms apply.
- You can disable iCloud sync in Settings at any time.

## What goes to us

**Nothing personal.** No identifiers, no IP collection, no behavioral profiles.

The template ships with no analytics. If TelemetryDeck (or similar)
is added in a later version, it sends anonymous aggregate signals
only — never linked to you — and is opt-out in Settings, respected
immediately.

## What we don't do

- No advertising. No advertising IDs.
- No third-party data sharing.
- No SDKs that fingerprint or profile users.
- No "engagement" notifications. Notifications only happen when you
  schedule them yourself.

## Third-party services

| Service          | What it sees                              |
|------------------|-------------------------------------------|
| App Store (IAP)  | Purchase events. Apple's privacy terms.   |
| Apple CloudKit   | Your data in *your* private iCloud (opt-in). |

## Children

{{APP_NAME}} is not directed at children. We don't collect personal
data from anyone, so the COPPA / GDPR-K constraints that protect
minors have nothing to constrain.

## Contact

See `docs/SUPPORT.md` for how to reach us.

## Changes to this policy

If we change anything material, we'll bump the **Last updated** date
and post a What's New note in the release.
