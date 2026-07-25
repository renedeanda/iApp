# Add iCloud sync (RN)

> **Source:** `templates/rn/modules/icloud-sync/` (clean Expo module) (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — the template's module is the canonical pattern. ⚠️ Do **not** harvest an older bespoke CloudKit bridge from one of your apps — legacy bridges predate and are obsoleted by this module.

## What it adds

A generic CloudKit private-database sync, shipped as a reusable Expo module (`modules/icloud-sync/`, already in the template). Any record shape with a string `id` syncs across the user's devices. The native Swift side handles zones, subscriptions, and change tokens; the TS side is a typed factory.

## When to use

- The app stores **user-owned data** that should follow them between their iOS devices.
- Records are **flat** — top-level fields are JSON-serializable primitives (nested objects/arrays are dropped silently).
- Last-writer-wins conflict resolution is acceptable for this data.

## When NOT to use

- **Android / cross-platform sync.** This is CloudKit — iOS only. The TS layer returns a no-op stub on Android and the web. If you need cross-platform sync, this isn't it.
- **Collaborative / shared data.** Private-database sync is single-user. `CKShare` is a different, much larger feature.
- **Large binaries inline.** Use the `__assetPath` special key (translated to `CKAsset` server-side), not a base64 blob in a field.
- **Nested data structures.** Only primitive top-level fields sync. Flatten your model or serialize sub-objects to strings deliberately.
- **Harvesting a legacy bespoke bridge.** Once the generic module exists, older per-app CloudKit bridges are obsolete. The template module only.

## How

### 1. Harvest

- Already in the template: `modules/icloud-sync/` (the Expo module — `index.ts` + `ios/ICloudSyncModule.swift`) and `plugins/withICloudEntitlements.js`.
- The module is genericized from a shipped app's event-specific bridge; the per-app customization surface is `SyncConfig` in `ICloudSyncModule.swift`.

### 2. Wire

- **Entitlements plugin:** add `"./plugins/withICloudEntitlements"` to `app.json` `plugins`. It derives the iCloud container, KVS identifier, and APS environment from the bundle id at prebuild. Without it, every iCloud call fails at runtime.
- **Namespace:** set `SyncConfig.appNamespace` in `modules/icloud-sync/ios/ICloudSyncModule.swift` (the wizard substitutes `{{APP_NAMESPACE}}` at `/new-app --commit`). It derives the zone, subscription id, and UserDefaults keys.
- **Typed client:** `const sync = createICloudSync<MyRecord>()` where `MyRecord extends SyncableRecord`. Call `await sync.setup()` once at launch (idempotent).
- **Availability gate:** every consumer checks `await sync.isAvailable()` first — it returns false on non-iOS and when the user is signed out. Don't assume sync is on.
- **Incremental pulls:** use `fetchChanges()` after the first `fetchAll()` — it uses the persisted change token.
- **Change listener:** `sync.addChangeListener(cb)` fires on `CKAccountChanged` + silent pushes; it returns an unsubscribe function — call it on unmount.

### 3. Verify

```sh
npx expo prebuild --clean --platform ios --no-install
# confirms withICloudEntitlements ran and the module autolinked
npx jest
```

Expected: prebuild produces `ios/` with the iCloud entitlements applied; the JS test suite passes (the module falls back to the no-op stub in jest, so consumers must not crash when `isAvailable()` is false).

## Gotchas

- On a fresh checkout with no `pod install`, `requireNativeModule('ICloudSync')` throws — the module catches this and falls back to the stub with a console warning. That's expected; rebuild with pods to get the real module.
- CloudKit's development schema is created lazily on first write — deploy it to **production** in the CloudKit dashboard before App Store release or shipped users get an empty container.
- Token-expired errors clear the persisted token so the next `fetchChanges()` does a full re-pull — don't treat that as an error to surface.
- The `__assetPath` key is special-cased both ways (path → `CKAsset` → path) — any other key starting with `__` is reserved; don't use them as record fields.
