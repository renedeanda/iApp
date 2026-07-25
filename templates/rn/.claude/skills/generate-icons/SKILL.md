---
name: generate-icons
description: Regenerate all app icon assets (iOS, Android adaptive, splash, favicon, notification) from the SVG source at assets/icon_master.svg. Use when the user wants to update, regenerate, or modify app icons.
---

> SOURCE: pattern adapted from `Kindling:.claude/skills/generate-icons` (originally for AppIcon.appiconset); retargeted to Expo's flat `assets/images/` layout.

# /generate-icons

Render every required icon variant from a single SVG seed.

## When to use

- After editing `assets/icon_master.svg`.
- After running `/new-app --commit` (the wizard's `design-icon` skill seeds the SVG; this skill renders it).
- Before a release build or App Store submission.

## When NOT to use

- For one-off marketing imagery — use `/app-store-graphics` instead.
- If `icon_master.svg` doesn't exist yet — run `/new-app --commit` (which calls `design-icon`) first.

## Output files

All written to `assets/images/`:

| File | Size | Use |
|---|---|---|
| `icon.png` | 1024×1024 | iOS app icon (App Store + device) |
| `adaptive-icon.png` | 1024×1024 | Android adaptive icon foreground |
| `splash.png` | 1284×2778 | Splash screen background |
| `favicon.png` | 48×48 | Web favicon (if `expo export --platform web`) |
| `notification.png` | 96×96 | Android notification monochrome |

Expo handles iOS @2x/@3x and Android density buckets at prebuild time — no need to ship every size.

## Steps

1. Verify `assets/icon_master.svg` exists and is valid SVG (`xmllint --noout` if available).
2. Verify a rasterizer is on PATH: prefer `sharp-cli` (`npx sharp-cli`) → fallback `rsvg-convert` → fallback `magick convert`.
3. For each output file in the table, render at the listed size.
4. Run `npx jest AppIconAsset` to confirm the housekeeping test now passes the "full set" assertion.
5. Commit the regenerated PNGs with message `chore(icons): regenerate from icon_master.svg`.

## Output

```
/generate-icons

Source: assets/icon_master.svg (3.2 KB)
Renderer: sharp-cli 5.x

  ✓ icon.png             1024×1024
  ✓ adaptive-icon.png    1024×1024
  ✓ splash.png           1284×2778
  ✓ favicon.png            48×48
  ✓ notification.png       96×96

AppIconAsset test: PASSED
```

## Forbidden

- Do NOT hand-edit the generated PNGs — they're outputs. Edit `icon_master.svg` and re-run.
- Do NOT ship pure `#000000` / `#FFFFFF` in the icon — even when the visual identity allows minimal palettes, use the palette's off-black / off-white from `theme/AppTheme.ts`.
