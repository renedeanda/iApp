# Add Mac Catalyst (Universal Purchase)

> **Source:** the Swift template itself — `templates/swift/project.yml` (`SUPPORTS_MACCATALYST`) + `Seed/Seed-macOS.entitlements`. No single portfolio app is the gold standard yet.
> **Platform:** Swift
> **Reliability:** ⚠️ pattern-only — the template is *set up* for Catalyst but no shipped portfolio app proves the full path end-to-end. Treat the steps below as the considered pattern, not a verbatim harvest.

## What it adds

A Mac build of the iOS app via Mac Catalyst, sold as a **Universal Purchase** — one App Store listing, one price, the user buys once and gets iPhone + iPad + Mac. The app's SwiftUI views render on macOS with the iPad idiom.

## When to use

- The app's interaction model genuinely works with a pointer + keyboard + resizable window — lists, reading, editing, dashboards.
- You want a Mac presence without maintaining a separate AppKit/SwiftUI-for-Mac codebase.
- Universal Purchase is a real selling point for *this* app's audience.

## When NOT to use

- **The app is touch-first in a way that doesn't translate.** A breathing-exercise app, a camera app, anything built around gestures or device sensors — Catalyst will feel like a phone app in a window. Ship iOS-only.
- **You'd need a meaningfully different UX on Mac.** If Catalyst means rebuilding half the screens with `#if targetEnvironment(macCatalyst)`, that's not "free Mac app" — that's two apps. Consider a native macOS target instead (or skip Mac).
- **StoreKit complexity you're not ready for.** Universal Purchase needs the products configured for it in App Store Connect from day one — retrofitting is painful.
- **Window management is an afterthought.** A Catalyst app that ignores window sizing, the menu bar, and keyboard shortcuts reads as lazy. Budget the polish or don't ship it.

## How

### 1. Enable the target setting

- In `Seed/project.yml`, flip `SUPPORTS_MACCATALYST: NO` → `YES` on the app target.
- Set `DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER: NO` and keep the same bundle id so Universal Purchase ties the SKUs together.
- `xcodegen generate` to regenerate.

### 2. Wire the macOS entitlements

- `Seed/Seed-macOS.entitlements` ships with app-sandbox + user-selected-file read-write. Reference it via a Catalyst-conditional `CODE_SIGN_ENTITLEMENTS` or merge into the main entitlements with platform conditionals.
- Anything iOS-only in `Seed.entitlements` (push, etc.) must be valid for Mac too, or guarded.

### 3. Adapt the UX

- Audit every `#if os(iOS)` — Catalyst reports as iOS, so use `#if targetEnvironment(macCatalyst)` for Mac-specific branches.
- Add a menu bar (`.commands { }`), keyboard shortcuts on primary actions, and sensible minimum window size.
- Test pointer hover states — Catalyst surfaces them and bare iOS UI looks unfinished without them.

### 4. Configure App Store Connect

- Create the products as **Universal Purchase** in App Store Connect *before* the first Mac build upload.
- The `.storekit` config (`Seed/Seed.storekit`) should mirror the Universal Purchase product setup for local testing.

### 5. Verify

```sh
xcodegen generate
xcodebuild build -scheme Seed -destination 'platform=macOS,variant=Mac Catalyst'
xcodebuild build -scheme Seed -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: both build green. Launch the Catalyst build — resize the window, exercise the menu bar, tab through with the keyboard.

## Gotchas

- Catalyst is `os(iOS)` to the compiler — `#if os(macOS)` blocks **do not** run in a Catalyst build. This is the #1 source of "works on my Mac target but not Catalyst" confusion.
- Some iOS frameworks are unavailable or behave differently on Catalyst (certain `UIKit` APIs, haptics) — guard with `#if targetEnvironment(macCatalyst)` and provide a no-op or alternative.
- Universal Purchase can't be added retroactively to existing separately-sold SKUs — decide before first submission.
- The Mac idiom defaults to iPad layout — if the app is iPhone-only (`TARGETED_DEVICE_FAMILY: "1"`), fix that first or Catalyst has nothing good to render.
