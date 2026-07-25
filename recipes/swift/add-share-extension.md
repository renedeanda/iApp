# Add a Share Extension

> **Source:** *No verbatim portfolio source yet.* Pattern follows the same app-extension shape as `templates/swift/SeedWidgets/` (target in `project.yml`, own Info.plist, App Group bridge).
> **Platform:** Swift
> **Reliability:** ⚠️ pattern-only — no shipped portfolio app has a Share Extension. The steps are the considered pattern; the first app to ship one should write the canonical version back via `/sync-from-portfolio`.

## What it adds

A Share Extension target so the app appears in the system share sheet — the user can send a URL, image, text selection, or file into the app from Safari, Photos, Mail, anywhere. The extension writes the shared payload to the App Group container; the app picks it up on next launch.

## When to use

- The app's core loop is "capture something the user found elsewhere" — a read-later app, a notes app, a collection app.
- The shared item maps cleanly to an app entity (a URL → a saved link, an image → a new item).
- The capture can be **fast and non-interactive**, or needs only a tiny confirmation UI.

## When NOT to use

- **The app has nothing to capture.** A timer, a single-purpose utility — there's no payload that makes sense. Skip it.
- **You'd need the full app UI to handle the share.** The extension runs in a constrained process with tight memory limits — if completing the share needs the real editor, just deep-link into the app instead.
- **The share needs heavy processing.** Image resizing, network calls, parsing — do the minimum in the extension (write the raw payload to the App Group), defer the work to the app.
- **No App Group yet.** The extension and app communicate only through the shared container — wire that first (it already ships in `Seed.entitlements`).

## How

### 1. Add the target

- Create `ShareExtension/` as a sibling of `Seed/` (same layout as `Widgets/`): `ShareViewController.swift`, `Info.plist`, `ShareExtension.entitlements` (App Group only).
- Add the target to `Seed/project.yml` — `type: app-extension`, `NSExtensionPointIdentifier = com.apple.share-services`, the `NSExtensionActivationRule` declaring which payload types you accept (URL, image, text).
- Keep it gated/commented like the widget target until the wizard enables it.

### 2. Wire the handoff

- The extension's `ShareViewController` reads the input items, extracts the payload, and writes it to the App Group container (`FileManager.containerURL(forSecurityApplicationGroupIdentifier:)` — never `UserDefaults(suiteName:)`).
- The app, on `scenePhase` active, checks the container for pending shares and ingests them.
- Keep the extension UI minimal — a confirmation, or `SLComposeServiceViewController` if you need a caption field. Call `extensionContext?.completeRequest(...)` promptly.

### 3. Localize

- The extension has its **own** Info.plist display name and (if it has UI) its **own** `Localizable.xcstrings` — extension surfaces load strings from the extension bundle, same rule as widgets.

### 4. Verify

```sh
xcodegen generate
xcodebuild build -scheme Seed -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# then on the simulator: Safari → Share → find the app → confirm the payload lands.
```

Expected: build green; the app appears in the share sheet for the declared types; a shared item shows up in the app on next activation.

## Gotchas

- The extension process is memory-constrained (often ~120 MB) and short-lived — do the minimum, defer everything.
- `NSExtensionActivationRule` is fiddly — too broad and the app shows up for irrelevant content; too narrow and it never appears. Start specific, widen deliberately.
- The extension can't launch the app directly — it writes to the container and finishes. The handoff is asynchronous by design.
- Test from multiple source apps (Safari, Photos, Files) — activation rules behave differently per host.
