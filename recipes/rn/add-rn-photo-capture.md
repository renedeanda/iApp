# Add photo capture + library (RN)

> **Source:** ⚠️ pattern-only (production-proven; first-party Expo modules). Storage pairs with the wrapper in [add-rn-storage](add-rn-storage.md). Confirm against [`REUSE_INDEX`](../../portfolio/REUSE_INDEX.md).
> **Platform:** React Native (Expo)
> **Reliability:** ⚠️ pattern-only — `expo-image-picker` + `expo-file-system` are the canonical pairing.

## What it adds

Photos attached to the user's items — picked from the library or captured with the camera — copied into the app's own document storage and rendered as fast thumbnails. Same top-three feature as on the Swift side, with the same taste rules: permission at intent, downsample before store.

## When to use

- A photo materially enriches the item (proof, memory, identification, before/after).
- Library picking should be zero-friction — the system picker flow needs no blanket library permission.
- Camera capture is tied to a clear in-the-moment user action.

## When NOT to use

- **Decoration photos.** If items are complete without an image, skip it — an empty photo slot is guilt UI.
- **Storing picker URIs directly.** The URI `expo-image-picker` returns points at a cache location the OS may purge. Always copy into `FileSystem.documentDirectory` and store *your* path.
- **Requesting camera permission at launch.** Ask inside the camera button's handler, never before (permissions at intent — `DECISIONS/010-first-sixty-seconds.md`).

## How

### 1. Harvest

```sh
npx expo install expo-image-picker expo-file-system expo-image-manipulator
```

### 2. Wire

```ts
import * as ImagePicker from 'expo-image-picker';
import * as FileSystem from 'expo-file-system';
import { manipulateAsync, SaveFormat } from 'expo-image-manipulator';

export async function pickPhoto(): Promise<string | null> {
  const res = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'], quality: 1 });
  if (res.canceled) return null;
  return persist(res.assets[0].uri);
}

export async function capturePhoto(): Promise<string | null> {
  const perm = await ImagePicker.requestCameraPermissionsAsync();   // at intent, in the button handler
  if (!perm.granted) return null;
  const res = await ImagePicker.launchCameraAsync({ quality: 1 });
  if (res.canceled) return null;
  return persist(res.assets[0].uri);
}

async function persist(cacheUri: string): Promise<string> {
  const small = await manipulateAsync(cacheUri, [{ resize: { width: 2048 } }],
    { compress: 0.8, format: SaveFormat.JPEG });                    // downsample before storing
  const dest = `${FileSystem.documentDirectory}photos/${Date.now()}.jpg`;
  await FileSystem.makeDirectoryAsync(`${FileSystem.documentDirectory}photos/`, { intermediates: true });
  await FileSystem.copyAsync({ from: small.uri, to: dest });
  return dest;                                                      // store THIS path with the item
}
```

- Add the camera permission string via `app.json` → `ios.infoPlist.NSCameraUsageDescription` (one honest, localized sentence). The default library-pick flow needs no photo-library permission string.
- Render lists with the stored file URIs at thumbnail sizes (`expo-image` caches + downsamples for you).

### 3. Verify

```sh
npm test && npx expo start
```

Expected: tests green. Manual: pick a photo (no permission alert), force-quit + relaunch — image survives; camera path prompts only on first camera tap; scroll 50+ photo items without jank.

## Gotchas

- Camera doesn't exist in the Simulator — test capture on a device; the library path works everywhere.
- Photos live in your document directory, so the data-deletion flow must delete the `photos/` directory too (`templates/rn/src/services/DataDeletionService.ts` is the wiring point).
- iCloud sync of photo files through the key-value bridge (`templates/rn/modules/icloud-sync/`) is the wrong tool — sync metadata, keep image files device-local, or move to a real file-sync design deliberately.
- EAS builds: permission strings live in `app.json`, not Info.plist directly — a missing one fails App Review, not your local run.
