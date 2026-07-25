# Add EAS Build profiles (RN)

> **Source:** *pattern described inline* — the `eas.json` build-config convention proven across shipped production RN apps (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)).
> **Platform:** React Native (Expo)
> **Reliability:** ✅ pattern — production RN apps build via EAS. Note: the iApp RN template ships *without* `eas.json` by default (it's account-specific); this recipe adds it.

## What it adds

An `eas.json` with the three standard build profiles — `development`, `preview`, `production` — plus `.easignore`, so the app can be built in the cloud via `eas build` instead of needing a local Mac + Xcode for every artifact. Production auto-increments the build number.

## When to use

- You're ready to produce installable builds (TestFlight, internal distribution) and don't want to babysit a local Xcode build each time.
- You want reproducible, cloud-pinned builds — same Node, same Xcode, every time.
- The app has native modules / config plugins (this template does: iCloud, App Group) — `eas build` runs the full prebuild + native compile remotely.

## When NOT to use

- **You only ever run the app in the simulator.** `npm run ios` is faster for the dev loop — EAS is for *distributable artifacts*, not iteration.
- **Before the app has an App Store Connect record.** `production` profile + auto-submit assume the app exists in ASC. Do the first manual upload first.
- **As a substitute for the local dev build.** Keep `npm run ios` / `expo prebuild` in the loop — EAS is the *release* path, not the *develop* path.
- **Without deciding the credentials story.** EAS-managed credentials vs. your own — pick deliberately; switching later is friction.

## How

### 1. Add `eas.json` at the project root

```json
{
  "cli": { "version": ">= 12.0.0", "appVersionSource": "remote" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": { "simulator": true }
    },
    "preview": {
      "distribution": "internal",
      "ios": { "simulator": false }
    },
    "production": {
      "autoIncrement": "buildNumber",
      "ios": { "simulator": false }
    }
  },
  "submit": {
    "production": {}
  }
}
```

### 2. Add `.easignore`

Mirror `.gitignore` plus anything that shouldn't ship to the build server — `ios/`, `android/` (EAS regenerates them), `__tests__/`, local scratch. Keeps the upload small and the build clean.

### 3. Reconcile version sources

- `production.autoIncrement: "buildNumber"` means EAS owns the build number on production builds. Decide: either let EAS own it (`appVersionSource: "remote"`) **or** keep `bin/bump-version.sh` authoritative — not both, or they fight.
- `app.json`'s `version` stays the marketing version regardless.

### 4. Verify

```sh
npx eas build:configure          # validates eas.json
npx eas build --profile development --platform ios --local   # or remote, if logged in
```

Expected: `eas.json` validates; a `development` build produces an installable simulator build with the dev client.

## Gotchas

- `appVersionSource: "remote"` and a local `bin/bump-version.sh` both claiming the build number is the classic EAS footgun — pick one owner, document it in `DECISIONS/005-launch-readiness.md`.
- The `development` profile needs `developmentClient: true` *and* `expo-dev-client` installed, or the build is useless for the dev loop.
- `.easignore` not excluding `ios/`/`android/` means EAS uses your stale local native dirs instead of a clean prebuild — subtle, breaks config-plugin changes.
- EAS credentials: the first build prompts to generate/upload signing assets — do this deliberately, not on autopilot.
