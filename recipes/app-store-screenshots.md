# Create App Store screenshots

> **Source:** *pattern described inline* — a screenshot-launch skill + real-capture pipeline proven in shipped Swift and RN production apps; the steps below carry the full pattern. Confirm reuse conventions against [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md).
> **Platform:** Both
> **Reliability:** ✅ gold-standard with platform caveats

## What it adds

A repeatable App Store screenshot pipeline: real simulator captures from seeded app data, localized marketing frames, exact App Store pixel exports, heavy artifact ignore rules, and a QA checklist that catches fake UI, prompt overlays, bad iPad spacing, and weak seed content before upload.

## When to use

- Preparing launch or major-update screenshots for any SwiftUI or React Native app.
- Replacing hand-made mockups with real app captures and reproducible render scripts.
- Adding screenshot-only app routing, seeded demo data, generated in-app media, or localized frame rendering.
- Porting a proven screenshot workflow into a new portfolio app.

## When NOT to use

- The app cannot yet show the promised value in real UI — fix the product first.
- The requested scenario depends on a system surface you cannot capture truthfully, such as a fake widget or fake Lock Screen — skip it or capture the real OS surface.
- The user wants to commit large generated JPG/PNG/ZIP output folders — keep those as local/cloud deliverables unless explicitly approved.
- The seed data would use sensitive, controversial, public-tragedy, medical, or financial examples — choose neutral realistic data instead.

## How

### 1. Harvest

- Swift isolation pattern (proven in production): an isolated screenshot profile in `DataController` gated by an environment flag (e.g. `<APP>_SCREENSHOT_PROFILE`) that seeds demo data and routes to the target screens.
- RN real-capture pattern (proven in production): a simulator seed script (`seed-<app>-simulator.js`), a capture script (`capture-<app>-real-simulator.sh`), an exact-size render script (`render-<app>-real-appstore.swift`), and a `utils/marketingCapture.ts` helper.
- Build these in the app under `Marketing/AppStoreScreenshots/`, adapting bundle id, scheme, device ids, events/fixtures, locales, and output sizes.

### 2. Wire

- Plan 6-10 differentiated scenarios before capture.
- Before creating fixtures, write a seed-media brief: the screen being proven, the app value it should make visible, whether people can appear, which states must be mixed, and which card should lead.
- For RN/Expo, add a small `marketingCapture` helper that requires both `EXPO_PUBLIC_<APP>_MARKETING_CAPTURE=1` and a seeded runtime key before it can route screens or suppress StoreKit/notification prompts.
- Seed realistic app data through app-safe stores or APIs. Generated AI images may be used as in-app fixture media, but the final App Store graphics must use real simulator screenshots.
- If the product lets users attach media, build a reusable in-app fixture media library instead of a one-off screenshot hack. Keep it useful in product surfaces too: pick strong images for the hero/card views, and leave some items media-free so the captures prove both treatments.
- For generic lifestyle or habit-style media, default to face-safe ambiguous compositions: hands, backs, silhouettes, lower-body motion, objects, rooms, landscapes, and over-the-shoulder angles. Use visible faces only when identity is central to the product and rights/privacy are explicitly settled.
- Build a Release simulator app with bundled JS for RN/Expo or an isolated screenshot profile for Swift/macOS.
- Capture raw iPhone/iPad screenshots with a clean 9:41 status bar.
- Render final frames with bottom-bleed screenshot panels unless the scenario deliberately needs a full-device or top-bleed treatment.
- Keep subtitles clear of screenshot/device imagery and avoid repeated wordmarks that waste space.
- Put every full refresh in a new versioned output folder (`raw_real_vN/`, `final_real_vN/`). Never overwrite the prior round unless the owner explicitly asks.
- Ignore generated heavy assets by default: raw captures, generated fixture PNGs, manifests, and zip archives. Commit final PNG folders only when the owner wants upload-ready binaries versioned.

### 3. Verify

~~~sh
# project-specific examples
node --check Marketing/AppStoreScreenshots/seed-*.js
bash -n Marketing/AppStoreScreenshots/capture-*.sh
swiftc -parse Marketing/AppStoreScreenshots/render-*.swift
npm run typecheck        # RN/Expo apps
xcodebuild build ...     # Swift apps
~~~

Expected: raw screenshot count matches scenario x device count; final output count matches locale x size x scenario count; representative exports have exact pixels; visual QA confirms real app content, no prompts/dev overlays, no subtitle collision, no fake UI, and generated media appears inside the app.

Before framing, review the raw simulator captures at full size. Recapture any launch fade, permission sheet, stale loading state, empty state, simulator chrome issue, or accidental debug overlay. After framing, verify exact dimensions with an image tool (for example `sips -g pixelWidth -g pixelHeight`) across the whole output matrix. If a native renderer uses host-dependent APIs such as `NSImage.lockFocus()`, prefer an explicit bitmap context so retina scale does not silently double the export size.

When generated media is part of the product UI, verify it under the real app treatment: card crop, detail hero crop, scrim, tone sampling, light/dark themes, and text contrast. The screenshot set should make the media feature obvious without turning every card into the same state.

## Gotchas

- A storage key alone is not a safe RN screenshot mode gate. Require a build-time flag too.
- Do not let the first attempt drift into mockups. Stop and build the seed/capture path first.
- Bottom bleed usually looks more premium than a fully floating device. Recheck iPad because its panel often needs more top gap.
- AI-generated fixture images belong in the app data model/media folder, not as decorative App Store backgrounds.
- A beautiful image can still be wrong seed data if it shows a recognizable face, fights the app palette, crops poorly in the actual UI, or hides the feature the screenshot is meant to prove.
- A full screenshot refresh is a new artifact version, not an in-place replacement. Keep `v1`, `v2`, `v3` style folders so the owner can compare rounds.
- Keep generated artifacts out of git unless the user explicitly wants the binaries versioned.
