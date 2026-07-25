---
name: record-app-store-video
description: Plan, capture, edit, and validate videos of Apple-platform apps for private App Review evidence or public App Store product-page previews. Use when Codex needs to record an iPhone, iPad, Mac, Apple TV, or visionOS app; produce an App Review demo attachment; create a 15–30 second App Store preview; design a shot list or poster frame; capture Simulator or physical-device footage; remove private data from a demo; or inspect a video against current App Store Connect specifications.
---

# Record App Store Video

Produce truthful, polished footage from a deterministic app state. Treat private reviewer evidence and public product-page marketing as separate artifacts.

## Choose the deliverable

- **App Review attachment:** prioritize an uninterrupted proof of the exact feature, permission, purchase, deep link, hardware dependency, or rejection fix a reviewer needs. It may contain narration or captions, but never credentials, tokens, personal files, notification contents, or customer data.
- **App Store preview:** prioritize one clear value story for customers. Keep it within Apple's current duration, resolution, codec, frame-rate, bitrate, and file-size requirements. Design the first five seconds to work as both autoplay footage and a strong poster-frame source.
- **Internal QA or launch demo:** preserve enough context to reproduce the build, device, locale, appearance, seed state, and flow. Do not call it upload-ready unless the App Store checks pass.

Read [references/apple-video-requirements.md](references/apple-video-requirements.md) before creating an App Store preview or making a policy/specification claim. Refresh every requirement from the linked official Apple pages because specifications change.

## Workflow

### 1. Establish scope without recording

Confirm the purpose, app/branch/build, target device family, orientation, locale, appearance, required flows, and desired output. Inspect existing launch arguments, demo-data seeding, UI tests, screenshot automation, and recording assets before inventing a new harness.

Write a short shot plan with:

- the user promise demonstrated by each shot;
- start state, action, and visible result;
- planned duration and transition;
- required permission, StoreKit, network, or hardware state;
- privacy risks and how they are removed;
- the intended poster-frame moment.

Do not start recording until the app builds, the flow has been rehearsed, and the user has authorized capture when they asked only for planning.

### 2. Prepare a deterministic capture build

Use the release-equivalent scheme and the exact commit being submitted. Prefer a dedicated, clearly gated demo/marketing launch configuration that seeds fictional content without changing production defaults.

- Use fictional names, documents, colors, JSON, accounts, and purchases.
- Disable notifications and eliminate personal status-bar, clipboard, photo, file, and keyboard suggestions.
- Keep telemetry and network calls out of capture unless the flow requires them.
- Set locale, light/dark appearance, text size, orientation, time/status bar, and permissions intentionally.
- Verify Reduce Motion and accessibility behavior when relevant to the review claim.
- Never delete a user's simulator or device data unless explicitly authorized; use a disposable simulator for clean-state capture.

### 3. Rehearse and capture

Prefer a disposable Simulator for repeatable UI-only footage. Use a physical device and QuickTime when the feature requires camera, document scanning, Bluetooth, motion, biometric, or other hardware behavior.

For Simulator capture, run:

```sh
scripts/capture-simulator-video.sh <simulator-udid> <output.mov>
```

The script records only after an explicit confirmation unless `--yes` is passed. Stop with Control-C. Simulator capture does not show the Mac pointer, which is usually desirable. Record clean source takes; avoid racing through taps.

For reviewer evidence, favor one continuous take with enough setup to prove the state is real. For a public preview, record short modular takes so pacing can be refined without misrepresenting the interface.

### 4. Edit conservatively

- Show real app UI and real outcomes. Do not composite capabilities the app does not provide.
- Cut dead time while leaving controls and results readable.
- Use transitions sparingly; the app should remain the visual hero.
- Keep captions inside safe areas, concise, localized, and legible at phone size.
- Use only licensed music, fonts, footage, and voice. Prefer silence over low-quality or legally unclear audio.
- Avoid device frames, platform marks, prices, claims, or availability statements that can become inaccurate unless current requirements and marketing guidance allow them.
- Preserve a master-quality source plus the final delivery file and a manifest identifying commit, build, device, OS, locale, and edit settings.

### 5. Validate the final file

Install `ffprobe` locally if it is unavailable, then run:

```sh
scripts/validate-app-preview.py path/to/preview.mov --expected-size 886x1920
```

Treat a validator pass as technical evidence, not proof Apple will approve the creative. Visually review the entire exported file at 100% and thumbnail size. Confirm:

- no truncation, overlap, loading spinner, debug UI, cursor, notification, personal data, or accidental keyboard suggestion;
- no discontinuity that makes the result misleading;
- readable localized copy and a useful frame near five seconds;
- correct orientation, clean first/last frames, stable color, and intelligible audio if present;
- App Store preview duration and encoding match the current official specification;
- reviewer videos show every step mentioned in Review Notes.

## Deliverables

Return the video path plus a compact manifest containing purpose, app version/build/commit, capture device and OS, locale/theme/orientation, duration/resolution/codec, poster-frame recommendation, validation result, and remaining manual upload/reviewer steps. Never upload or submit unless the user explicitly authorizes it.
