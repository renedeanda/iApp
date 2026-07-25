# Working with Expo prebuild + config plugins (RN)

> **Source:** the RN template's own `plugins/` (`withICloudEntitlements.js`, `withAppGroup.js`) + `app.json`. Pattern per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md) "Expo config plugins" row.
> **Platform:** React Native (Expo)
> **Reliability:** ✅ — the template is the reference. This recipe is the discipline for *changing* native config, not adding prebuild (it's already the workflow).

## What it adds

Not a feature — the **discipline** for native config. The RN template uses Expo's "prebuild" workflow: `ios/` and `android/` are **generated** from `app.json` + the config plugins in `plugins/`, and are **not checked in**. This recipe is how you change anything native (entitlements, Info.plist keys, native modules) without ever hand-editing the `ios/` project.

## When to use

- Adding a native capability that needs entitlements or Info.plist changes — iCloud, App Groups, background modes, a new permission.
- Adding or configuring an Expo config plugin.
- A teammate's `ios/` is out of sync — delete it, re-prebuild, sync gone.

## When NOT to use

- **Hand-editing `ios/` or `android/`.** They're generated. Any change is erased on the next `expo prebuild --clean`. Native changes go in `app.json` or a config plugin — full stop.
- **Checking in `ios/` or `android/`.** They're `.gitignore`d. Committing them reintroduces the per-machine drift prebuild exists to kill.
- **Editing the generated `.xcodeproj` / `Podfile`.** Same rule — if you need a Podfile change, that's a config plugin (`withPodfileProperties` etc.), not a hand edit.
- **Running `prebuild` without `--clean` when plugins changed.** A non-clean prebuild merges into stale native dirs and can silently keep old config. When in doubt, `--clean`.

## How

### Changing an Info.plist key

Add it under `app.json` → `expo.ios.infoPlist`. The template already sets `ITSAppUsesNonExemptEncryption`, `MinimumOSVersion`, `UIBackgroundModes`, the privacy manifest, etc. there. Re-prebuild to apply.

### Changing entitlements

Entitlements are **not** in `app.json` directly — they come from config plugins. The template ships:
- `plugins/withICloudEntitlements.js` — iCloud container + KVS + APS environment.
- `plugins/withAppGroup.js` — App Group for extensions / shared storage.

Add the plugin to `app.json` → `expo.plugins` to activate it. Write a new `plugins/withX.js` for a new entitlement — follow the existing two as the shape (`withEntitlementsPlist`, derive ids from the bundle id, throw if a prerequisite is missing).

### Adding a native module

- An Expo module (like `modules/icloud-sync/`) is autolinked — prebuild picks it up.
- A third-party native dep: `npm install` it, then `expo prebuild --clean` so it's linked into the regenerated project. No new dep without an ADR.

### The prebuild commands

```sh
npm run prebuild         # expo prebuild — merges into existing ios/android
npm run prebuild:clean   # expo prebuild --clean — regenerates from scratch (prefer this when plugins changed)
```

### Verify

```sh
npm run prebuild:clean -- --platform ios
# confirms every config plugin runs cleanly and produces a valid ios/ project
git status   # ios/ and android/ should NOT appear — they're gitignored
```

Expected: prebuild finishes clean, config plugins all apply, no `ios/`/`android/` in `git status`. The repo-level `scripts/verify-rn-template.sh` runs exactly this as its last step.

## Gotchas

- After **any** `app.json` or `plugins/` change, `expo prebuild --clean` before building — stale `ios/` is the #1 "but I changed app.json" confusion.
- A config plugin that throws mid-prebuild leaves a half-generated `ios/` — always `--clean` after fixing it.
- `withWidgetExtension.js` (if/when widgets are added — see [add-rn-widgets](add-rn-widgets.md)) mutates the xcodeproj and is the riskiest plugin; an Expo SDK bump can break it. CI runs "prebuild then build the widget target" specifically to catch that.
- The privacy manifest lives in `app.json` → `expo.ios.privacyManifests`, **not** a hand-placed `PrivacyInfo.xcprivacy` — editing the generated file is pointless.
