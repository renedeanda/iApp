# Add QuickLook preview

> **Source:** *No verbatim portfolio source yet.* Pattern-only.
> **Platform:** Swift
> **Reliability:** ⚠️ pattern-only — no shipped portfolio app uses QuickLook. The first to ship it writes the canonical version back via `/sync-from-portfolio`.

## What it adds

QuickLook integration — one or both of: (a) presenting system previews of files *inside* the app via `QLPreviewController`, and (b) a **Thumbnail Extension** so the app's own document type renders a rich thumbnail in Files, Spotlight, and share sheets.

## When to use

- **In-app previews:** the app handles files the user wouldn't otherwise be able to inspect — PDFs, documents, images, exports. `QLPreviewController` gives you Apple-quality rendering for free.
- **Thumbnail extension:** the app defines its own document UTI and those documents should look like *something* (not a generic icon) in Files and Spotlight.

## When NOT to use

- **The app has no files.** QuickLook is about *documents*. A SwiftData-only app with no file artifacts has nothing to preview.
- **You're tempted to build a custom preview UI for standard types.** If it's a PDF or an image, `QLPreviewController` is better than anything you'd hand-roll, and free. Don't reinvent it.
- **The thumbnail would just be the app icon.** A thumbnail extension that renders the same glyph for every document is worse than the system default — it implies content differences that aren't there.
- **The document type isn't really yours.** Don't ship a thumbnail extension for `.pdf` or `.txt` — the system already handles those.

## How

### Part A — in-app previews (no extension needed)

1. Conform a small type to `QLPreviewControllerDataSource` returning the file `URL`s.
2. Present `QLPreviewController` (wrap in `UIViewControllerRepresentable` for SwiftUI).
3. Files must be on disk with real URLs — QuickLook can't preview in-memory `Data`.

### Part B — Thumbnail Extension

1. Add `ThumbnailExtension/` as a sibling of `Seed/` (same shape as `Widgets/`): `ThumbnailProvider.swift` subclassing `QLThumbnailProvider`, `Info.plist`, entitlements.
2. Add the target to `Seed/project.yml` — `type: app-extension`, `NSExtensionPointIdentifier = com.apple.quicklook.thumbnail`, with the `QLSupportedContentTypes` declaring your document UTI.
3. Declare the document UTI itself in the **app's** Info.plist (`UTExportedTypeDeclarations`) — the extension references it.
4. `ThumbnailProvider.provideThumbnail` renders into the requested size — keep it fast (the system has a tight budget) and use the palette from a widget-style standalone theme, not the app's theme environment.
5. Keep the target gated/commented until the wizard enables it.

### Verify

```sh
xcodegen generate
xcodebuild build -scheme Seed -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# in-app: open a file, confirm QLPreviewController renders it.
# thumbnail: save one of the app's documents, view it in Files — confirm the custom thumbnail.
```

Expected: build green; previews render; the app's document type shows its custom thumbnail in Files.

## Gotchas

- The thumbnail extension runs in a constrained, short-lived process — render fast, no network, no heavy frameworks.
- `QLThumbnailProvider` must handle being called for sizes you didn't expect — scale, don't assume.
- The document UTI must be **exported** (you own it) not **imported** (someone else owns it) for a thumbnail extension to make sense.
- In-app `QLPreviewController` needs the file to still exist when the preview opens — don't preview a temp file you've already cleaned up.
