# Add photo capture + library

> **Source:** ⚠️ pattern-only (production-proven; the template doesn't ship it — attach to your models per `templates/swift/Seed/Models/Item.swift`). Confirm against [`REUSE_INDEX`](../../portfolio/REUSE_INDEX.md).
> **Platform:** Swift
> **Reliability:** ⚠️ pattern-only — the pattern below is shipped-app-proven; adapt names to your domain.

## What it adds

Letting users attach photos to their items — picked from the library via `PhotosPicker` or captured live with the camera — stored efficiently in SwiftData with external storage, displayed with downsampled thumbnails. This is a top-three request in almost every "log/track/collect things" app idea.

## When to use

- A photo materially enriches the item (proof, memory, identification, before/after).
- Users already have the photos on their phone — `PhotosPicker` requires **no permission prompt at all** in its default flow, which keeps the first-sixty-seconds clean.
- Camera capture is tied to a clear in-the-moment action.

## When NOT to use

- **The photo would be decoration.** If items are complete without an image, an empty photo slot is guilt UI. Ship without it; add when users ask.
- **You're about to request full library access.** Don't. `PhotosPicker` runs out-of-process — the system shows the picker, your app receives only what the user chose. If you find yourself adding `NSPhotoLibraryUsageDescription`, stop and check you actually need library *write* or *scan* access (you almost never do).
- **Asking for camera permission at launch.** Permission comes at the moment the user taps the camera button — never before (taste rule: permissions at intent, see `DECISIONS/010-first-sixty-seconds.md`).

## How

### 1. Harvest

- Attach image storage to your model per the shape in `templates/swift/Seed/Models/Item.swift`:

```swift
@Model
final class Item {
    var title: String
    @Attribute(.externalStorage) var photoData: Data?   // external storage — keeps the DB small
    // ...
}
```

### 2. Wire

**Library pick (no permission needed):**

```swift
import PhotosUI

@State private var pick: PhotosPickerItem?

PhotosPicker(selection: $pick, matching: .images) {
    Label("Add Photo", systemImage: "photo.badge.plus")
}
.onChange(of: pick) { _, item in
    Task {
        guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
        model.photoData = downsampled(data, maxPixel: 2048)   // never store the 48 MP original
    }
}
```

**Camera capture:** add `NSCameraUsageDescription` to `templates/swift/Seed/Info.plist`'s equivalent in your app (localized via `InfoPlist.xcstrings` — one honest sentence about why). Present `UIImagePickerController` (`.sourceType = .camera`) or an `AVCaptureSession` wrapper; request permission only inside the button action.

**Downsample before storing and before display.** Use `CGImageSourceCreateThumbnailAtIndex` with `kCGImageSourceThumbnailMaxPixelSize` — decoding full-size images in a `List` is the #1 scroll-jank cause in photo-bearing apps.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: build green. Manual: pick a photo (no permission alert should appear), kill and relaunch the app, confirm the image survives; scroll a list of 50+ photo items with no hitching.

## Gotchas

- `@Attribute(.externalStorage)` is what keeps SwiftData + CloudKit happy with image blobs; raw `Data` in-row balloons the store and sync payloads.
- Photos count toward your data-deletion obligations — the wipe flow must clear them too ([docs/ICLOUD_DATA_DELETION.md](../../docs/ICLOUD_DATA_DELETION.md)).
- Camera doesn't exist in the Simulator — test capture on a device; guard `UIImagePickerController.isSourceTypeAvailable(.camera)` so the button hides on iPads without cameras / Simulator.
- HDR/portrait originals can be huge and rotated — normalize orientation during the downsample pass or widgets/exports show sideways images.
