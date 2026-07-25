# Seed — RN template

> This is the Kindling Expo / React Native starter. The `/new-app`
> wizard renders it into a new repo, substituting `Seed` →
> `<YourApp>`, the bundle id, app group, and the 16 `DECISIONS/`
> values you captured in the design-first sprint.

## Quick start (once renamed)

```sh
nvm use                  # picks up Node 20 from .nvmrc
npm install
npm run prebuild         # generates ios/ + android/ native projects
npm run ios              # builds + launches in iOS Simulator
```

## Archive

```sh
npm run archive
```

The command follows a production-proven path: Expo iOS prebuild, CocoaPods install,
Release archive for `generic/platform=iOS`, then open the `.xcarchive` in Xcode
Organizer. Override `APP_NAME`, `SCHEME`, `WORKSPACE`, `ARCHIVE_PRE_CMD`, or
`ARCHIVE_POST_CMD` when a child app has extra native steps.

## Stack

- **Expo SDK 54** (`expo@^54.0.10`) + **React Native 0.81** + **React 19**.
- **expo-router 6** for typed routes (filesystem-based).
- **react-native-reanimated 4** for motion (must respect Reduce Motion).
- **react-native-iap 12** for StoreKit 2 / Play Billing — no RevenueCat.
- **i18next + react-i18next** for translations (`i18n/<locale>/translation.json`).
- **expo-notifications**, **expo-haptics**, **expo-localization**, **expo-store-review** as opinionated defaults.

## Universal Purchase

Universal between iOS and Android is **not** supported by Apple StoreKit 2 — RN apps using `react-native-iap` ship with separate iOS / Android product IDs. The wizard's `/pick-monetization` step asks whether you want iOS-only, Android-only, or both.

## Reliability sources (do NOT improvise)

Every file with a `// SOURCE:` header is a verbatim or near-verbatim harvest from a shipped production app — that's why it works.

- iCloud bridge + data deletion: **`modules/icloud-sync/`** + **`src/services/DataDeletionService.ts`** (see the Kindling repo's `docs/ICLOUD_DATA_DELETION.md`).
- Yearly-reminder notifications (rolling 64-limit pattern): **`src/services/NotificationService.ts`**.
- Widget extension config plugins: **`plugins/withAppGroup.js`** + **`plugins/withICloudEntitlements.js`**.
- Widget i18n (multi-language `.lproj` setup): follow the Kindling repo's `docs/WIDGETS.md` recipe.

See the Kindling repo's `portfolio/REUSE_INDEX.md` for the full feature → path map.
