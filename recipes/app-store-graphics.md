# Generate App Store screenshot graphics

> **Source:** `tools/app-store-graphics/generate.py` (this repo) — the one
> engine that emits every app's screenshot studio. Reference gallery at
> `tools/app-store-graphics/index.html`. See [`../tools/app-store-graphics/README.md`](../tools/app-store-graphics/README.md).
> **Platform:** Both (Swift + React Native)
> **Reliability:** ✅ gold-standard — modernized from bespoke reference files
> proven on shipped App Store listings; every output is XML-validated and the
> SVG→canvas→PNG export matches the proven reference technique.

## What it adds

Two self-contained HTML files per app — a **Studio** (locale switcher, toggles,
bulk per-locale ZIP export) and a minimal **Simple** page (drop-and-download,
modelled verbatim on the proven bespoke reference files) — that turn raw
screenshots into framed, captioned, exact-size App Store graphics at **both
Apple-approved sizes**: iPhone 6.9″ 1320×2868 + 6.5″ 1242×2688, iPad 13″
2064×2752 + 12.9″ 2048×2732, Mac 2880×1800 for universal apps. One rendering
engine + a per-app config (palette, font, feature copy) means each app's files
are on-brand but maintained in one place. Live toggles cover the high-converting
"bold hero first image" pattern and a device-frame option without re-exporting.

## When to use

- Preparing an App Store Connect submission and you need the required
  screenshot sizes with marketing captions.
- Refreshing a listing after a feature ships (edit the app's `screens` in
  `generate.py`, re-run).
- A new app's `/new-app --commit` Phase B graphics step.

## When NOT to use

- **Don't hand-author SVG per screenshot.** That's the trap this replaces —
  the reference files were ~1,800 lines of copy-pasted SVG and drifted. Edit
  the config in `generate.py` and regenerate instead.
- **Don't use it to build the app *icon*.** Icons come from `icon_master.svg`
  via `/generate-icons`. This tool frames *screenshots*, not the icon.
- **Don't keep a hand-maintained bespoke page for one app while the rest
  render from the engine.** Drift between a bespoke file and the engine is
  exactly how the ~1,800-line copy-paste trap happens — keep every app's
  config in `generate.py` and regenerate.
- **Don't paste a screenshot that already has a device bezel into "Device
  frame" mode** — you'll double-frame it. Use a clean full-screen capture.

## How

### 1. Harvest

- Source: `tools/app-store-graphics/generate.py` — already in this repo.
- Per-app output is written into each app repo (e.g.
  `<app>/Marketing/app-store-graphics.html`); see the README's path table.

### 2. Wire

- Edit the app's entry in `APPS` (palette tokens from `DECISIONS/002`,
  typography from `DECISIONS/011`, feature copy in `screens`).
- New app? Copy a block, set `name` / `slug` / `out` / `font_key` /
  `devices`, and add the key to `ORDER`.

### 3. Verify

```sh
cd tools/app-store-graphics && python3 generate.py
```

Expected: one `wrote …` line per app plus `index.html`. Open the app's HTML
in Chrome, drop a screenshot into a slot, flip the toggles, and the
download buttons save exact-size PNGs.

## Gotchas

- **Web fonts in the exported PNG** depend on the browser having loaded them
  first — prefer Chrome and give the page a moment on first open.
- **Dark apps** set `dark: True`, which lifts panel-tint and
  frame contrast. Flipping an app light↔dark is a 4-token + flag edit.
- **Card 1 only** follows the "First image" toggle; cards 2…N are always
  caption layout.
