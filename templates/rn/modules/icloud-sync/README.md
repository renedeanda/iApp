# @example/expo-icloud-sync

Generic CloudKit private-database sync as a local Expo module.

## What it does

- Creates a custom CKRecordZone (so server change tokens work; the default zone doesn't support them).
- Subscribes for silent push so other devices learn about edits without polling.
- Stores arbitrary records with a string `id` + JSON primitive fields.
- Supports a single binary asset per record via the `__assetPath` convention (path-in → CKAsset → path-out).
- Persists change tokens in `UserDefaults` so each fetch is incremental.
- Handles `changeTokenExpired` by clearing the token (next fetch does a full re-pull).
- Falls back to a no-op stub on Android / web / iOS-without-pods.

## Usage

```ts
import { createICloudSync, SyncableRecord } from '@/modules/icloud-sync';

// 1. Declare your record shape.
type Note = SyncableRecord & {
  title: string;
  body: string;
  createdAt: number;
};

// 2. Build a typed client.
const sync = createICloudSync<Note>();

// 3. On app launch, check + setup.
if (await sync.isAvailable()) {
  await sync.setup(); // idempotent
  const { changed, deleted } = await sync.fetchChanges();
  applyToLocalStore(changed, deleted);
}

// 4. Save / delete as the user edits.
await sync.saveOne({ id: 'n1', title: 'Hi', body: 'There', createdAt: Date.now() });
await sync.deleteOne('n2');

// 5. Listen for remote changes.
const unsubscribe = sync.addChangeListener(() => {
  void sync.fetchChanges().then(({ changed, deleted }) => {
    applyToLocalStore(changed, deleted);
  });
});
```

## Configuration

Open `ios/ICloudSyncModule.swift` and set `SyncConfig.appNamespace` to your app's name (single token, no spaces). The wizard's `/new-app --commit` substitutes the `Seed` default for you. Derived names:

- Record zone: `<AppName>SyncZone`
- Record type: `<AppName>Record`
- Subscription ID: `<appname>-sync-subscription`
- UserDefaults keys: `<appname>.icloud.zone_change_token`, `<appname>.icloud.zone_created`
- Asset directory: `Documents/cloud-assets/<recordId>.<ext>`

## Entitlements

Use the matching Expo config plugin in `app.json`:

```jsonc
"plugins": [
  "./plugins/withICloudEntitlements"
]
```

The plugin adds: `com.apple.developer.icloud-services` (CloudKit + CloudDocuments), `icloud-container-identifiers`, `ubiquity-container-identifiers`, `ubiquity-kvstore-identifier`, `aps-environment` (silent push).

Bundle id must match the iCloud container — the plugin sets `iCloud.<bundleId>` automatically.

## Record schema rules

- `id` (required): string. Becomes the CKRecord.recordName.
- All other fields: string | number | boolean | null/undefined (null/undefined drop).
- Nested objects / arrays: NOT supported. Serialize to a string field if you need them.
- `__assetPath` (optional): absolute on-device file URL. Stored as CKAsset; on read you get back a path inside `Documents/cloud-assets/`.

## Known limits

- One asset per record. Multi-asset records need a wrapper using N sibling records or a JSON-encoded manifest field.
- 1 MB per non-asset record (CloudKit hard limit). Long text fields should be assetified.
- 400 records per single save operation (chunked automatically in `saveMany`).
- No conflict resolution beyond `savePolicy = .changedKeys`. Last-writer-wins on field-level overlap.

## Provenance

- Pattern: harvested from a shipped production app's iCloud bridge (clean Expo-module shape), genericized for reuse.
- An earlier custom-bridge approach (a hand-rolled CloudKit manager wired through the RN bridge) is superseded by this Expo-module approach.

If a future app refines this further, the goal is to lift it back to a public npm package — drop the `"private": true` in `package.json` and publish.
