# Record App Store and App Review videos

> **Source:** `.claude/skills/record-app-store-video/` (this repo) — confirm against [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md).
> **Platform:** Apple platforms
> **Reliability:** ✅ validator-backed capture workflow

## What it adds

A repeatable video pipeline that treats private App Review evidence and public App Store previews as different products. It plans a truthful flow, prepares fictional demo data, captures Simulator or physical-device footage, validates public-preview encoding, and preserves an exact build/device/locale manifest without uploading anything implicitly.

## When to use

- Demonstrating a non-obvious feature, permission, rejection fix, purchase flow, deep link, or hardware dependency to App Review.
- Creating a public 15–30 second App Store preview from real app UI.
- Producing a reproducible internal launch walkthrough tied to an exact build and seed state.
- Validating the duration, dimensions, codec, frame rate, bitrate, audio, and file size of an existing preview.

## When NOT to use

- The app cannot yet demonstrate the promise in working UI—fix the product first.
- A screenshot communicates the value more clearly and with less maintenance.
- The proposed footage contains real credentials, customer data, personal files, notifications, clipboard contents, or unlicensed media.
- The user asked only for planning or explicitly said not to record; prepare the shot list and stop before capture.

## How

1. Invoke `.claude/skills/record-app-store-video/SKILL.md` and choose either reviewer evidence or public App Store preview before writing the shot list.
2. Read the skill's live Apple-source links before relying on duration, resolution, codec, or upload requirements.
3. Use a release-equivalent build and a disposable Simulator with fictional seeded data. Use a physical device through QuickTime only when camera, scanning, Bluetooth, motion, biometrics, or other hardware is the point of the proof.
4. Rehearse the complete flow before capture. Keep reviewer evidence continuous enough to prove the state; keep public-preview takes modular enough to edit without misrepresenting behavior.
5. Capture Simulator footage with `.claude/skills/record-app-store-video/scripts/capture-simulator-video.sh`. The script refuses to overwrite an existing file and waits for explicit confirmation unless `--yes` is supplied.
6. Edit conservatively, keep the app UI as the hero, and preserve a manifest containing commit, version/build, device/OS, locale, appearance, orientation, seed profile, and export settings.
7. Validate a public preview with `scripts/validate-app-preview.py <video> --expected-size <width>x<height>`, then visually inspect the entire export and its five-second poster-frame candidate.
8. Keep raw takes and generated exports out of git unless the repository explicitly versions marketing binaries. Never upload or submit without separate user authorization.

Verification:

```sh
zsh -n .claude/skills/record-app-store-video/scripts/capture-simulator-video.sh
python3 -m py_compile .claude/skills/record-app-store-video/scripts/validate-app-preview.py
python3 .claude/skills/record-app-store-video/scripts/validate-app-preview.py --help
```
