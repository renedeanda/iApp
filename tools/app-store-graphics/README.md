# App Store Graphics Generator

> One engine, every app in your portfolio. A data-driven generator that emits a self-contained HTML page per app: drop real screenshots in, pick a locale, and download every graphic at the exact App Store pixel sizes — no build step, no dependencies, nothing uploaded anywhere.

## What it produces

For each app config in `generate.py`:

- **`app-store-graphics.html` (the Studio)** — the full-featured page: locale switcher, "Bold hero / Plain caption" first-image toggle, "Soft panel / Device frame" screenshot treatment, per-screen live theme switching (for apps with a theme registry), and bulk export — a whole locale, or every locale × device, as one organized `.zip`.
- **`app-store-graphics-simple.html` (Simple)** — a deliberately minimal fallback: fixed caption layout, drop-a-screenshot, download-PNG. No toggles. Same per-app data as the Studio, so the two never drift.
- **`index.html` (the mega reference)** — an app switcher across every configured app, written next to this README. Open it to browse all your configs in one place.

Export sizes (App Store–ready, flattened opaque PNG/JPEG):

| Device | Size |
|---|---|
| iPhone 6.9″ | 1320 × 2868 (auto-scales to every iPhone shelf) |
| iPhone 6.5″ | 1242 × 2688 |
| iPad 13″ | 2064 × 2752 |
| iPad 12.9″ | 2048 × 2732 |
| Mac | 2880 × 1800 (universal apps only) |

## Quick start

```sh
cd tools/app-store-graphics
python3 generate.py            # writes out/<app>/… + index.html
python3 generate.py --list     # list configured apps and their output paths
open index.html                # browse every config in one page
```

Python 3 standard library only — no pip installs.

## Adding your app

1. Open `generate.py` and find the `APP CONFIGS` section. Two worked examples ship: **Sample Notes** (light, themed, iPhone/iPad/Mac) and **Sample Dots** (dark, dot-grid). A neutral `BLANK` starter (used by the `/new-app` flow) sits below them.
2. Copy a config block, change the key/name/slug, and fill in:
   - `surface` / `text` / `subText` / `placeholder` — your app's palette anchors,
   - `font_key` — one of the registered Google-font specimens,
   - `motif` — the hero background art (note, dotgrid, rings, heatmap, kanban, route, bloom, …),
   - `simpleStyle` — the Simple-page card style (default, flame, dotgrid, brutalist, ink, serif, blueprint),
   - `screens` — one `S(accent, emoji, headline-lines, sub-lines, filename)` per screenshot slot,
   - optionally `themes`/`themeDefaults` (a registry from `theme_data.py`) and `i18n` (a dict from `i18n_data.py`).
3. Add your key to `ORDER`, re-run `python3 generate.py`.

Design rules baked into the engine:

- **Headlines stay legible on every theme** — the engine auto-deepens accents until they clear the AA-large 3:1 contrast bar; `check_theme_contrast()` warns on regressions when you run the generator.
- **Real captures only.** The pages are composition tools around genuine app screenshots — composited fake UI drifts from the shipping product and risks App Review rejection (guideline 2.3).
- **Localized copy is conversion-critical.** `i18n_data.py` documents the shape; flag machine drafts for native-speaker review before submission.

## File map

| File | Role |
|---|---|
| `generate.py` | The engine + per-app configs. Single source of truth. |
| `theme_data.py` | Reusable theme registries (three sample registries ship). |
| `i18n_data.py` | Localized screenshot copy per app. |
| `index.html` | Generated mega reference (checked in for easy browsing). |
| `out/` | Generated per-app pages (gitignored). |

Set `APP_STORE_GRAPHICS_ROOT=/path` to write outputs somewhere else (e.g. directly into each app repo's `Marketing/` directory).
