# Add sharing + export (outbound)

> **Source:** ⚠️ pattern-only (production-proven; SwiftUI-native APIs). For *receiving* shared content instead, see [add-share-extension](add-share-extension.md). Confirm against [`REUSE_INDEX`](../../portfolio/REUSE_INDEX.md).
> **Platform:** Swift
> **Reliability:** ⚠️ pattern-only — APIs are first-party; adapt the `Transferable` shapes to your domain.

## What it adds

Letting users get their stuff *out* — share an item as a beautifully-rendered image or text to Messages/social, and export their whole collection as a real file (PDF, JSON, CSV). Outbound share is how personal-tool apps grow without ad spend, and export is both a trust signal ("your data is yours") and an App Review expectation for data-holding apps.

## When to use

- An item in your app is inherently show-able (a result, a milestone, a made thing) — share-as-image.
- Users accumulate data they'd reasonably want on paper or in another tool — export-as-file.
- You want the "your data always stays yours" promise to be verifiable, not marketing.

## When NOT to use

- **Share buttons on everything.** One well-placed `ShareLink` at the natural "I'm proud of this" moment beats a share icon in every row. If you can't name the moment, don't add the button.
- **Watermark-as-growth-hack.** A tasteful app-name caption on a shared image is fine; a paywall to *remove* the watermark from the user's own content is a dark pattern (see [docs/NOT_FOR.md](../../docs/NOT_FOR.md)).
- **Inventing a custom export format.** JSON + CSV + PDF cover every real request. A proprietary format locks users in — the opposite of the promise.

## How

### 1. Harvest

Pattern is inline below. Fonts/colors for rendered share cards come from your theme tokens (`templates/swift/Seed/Theme/AppTheme.swift`, `templates/swift/Seed/Theme/Typography.swift`) so shares look unmistakably like your app.

### 2. Wire

**Share one item as an image** — render a SwiftUI card offscreen with `ImageRenderer`:

```swift
@MainActor
func shareImage(for item: Item) -> Image? {
    let renderer = ImageRenderer(content: ShareCardView(item: item))  // a ~1080pt branded card view
    renderer.scale = 3
    guard let ui = renderer.uiImage else { return nil }
    return Image(uiImage: ui)
}

// At the proud moment:
if let img = shareImage(for: item) {
    ShareLink(item: img, preview: SharePreview(item.title, image: img)) {
        Label("Share", systemImage: "square.and.arrow.up")
    }
}
```

**Export the collection as a file** — conform a document wrapper to `Transferable`:

```swift
struct ExportedArchive: Transferable {
    let json: Data
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { $0.json }
            .suggestedFileName("MyApp-Export.json")
    }
}
```

Offer it from Settings ("Export My Data") with `ShareLink` — the system sheet handles Files, AirDrop, Mail. For PDF, render pages with `ImageRenderer` into a `UIGraphicsPDFRenderer` context; for CSV, escape fields properly (quotes, commas, newlines).

- Localize everything on the share card — shared images travel to recipients in *their* locale; strings go through `Localizable.xcstrings` like any view.
- `ShareCardView` must not depend on live app state (timers, animations) — it renders once, offscreen.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: build green; unit-test the JSON/CSV encoders round-trip. Manual: share to Messages (image arrives crisp @3x, dark-mode card legible), export via Files, re-open the JSON — every field present.

## Gotchas

- `ImageRenderer` runs on the main actor — render on demand, not in `List` rows.
- Test share cards against both light and dark theme tokens; a dark-surface card shared into a light Messages thread is where `#000`-adjacent mistakes show.
- Exports are user data leaving the sandbox — never route them through your own analytics or a third-party SDK; the system share sheet only.
- If the app holds meaningful user data, pair export with the deletion flow ([docs/ICLOUD_DATA_DELETION.md](../../docs/ICLOUD_DATA_DELETION.md)) — the two together are the "your data is yours" story App Review and users both look for.
