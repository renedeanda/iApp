---
name: generate-icons
description: Regenerate the AppIcon.appiconset (plus splash, notification, and store icons) from the SVG source at Seed/Resources/icon_master.svg. Use when the user wants to update, regenerate, or modify app icons.
---

> SOURCE: pattern adapted from the iApp root skill `generate-icons`.

# /generate-icons

Render every required icon variant from a single SVG seed.

## When to use

- After editing `Seed/Resources/icon_master.svg`.
- After `/new-app --commit` (the wizard's `design-icon` skill seeds the SVG; this renders it).
- Before a release build or App Store submission.

## When NOT to use

- For one-off marketing imagery — use `/app-store-graphics`.
- If `icon_master.svg` doesn't exist yet — run `/new-app --commit` (which calls `design-icon`) first.

## Output

- `Seed/Assets.xcassets/AppIcon.appiconset/` — every required size: 1024 (App Store), plus the device sizes (60@2x/3x, 76@2x, 83.5@2x, 167, 152, 40, 29, 20 families). The `Contents.json` references them all.
- `Seed/Assets.xcassets/LaunchBackground.colorset/` stays palette-driven (not regenerated here).
- Optional: notification icon + store/marketing icon if the app uses them.

`AppIconAssetTests` asserts the set is complete — partial sets fail.

## Steps

1. Verify `Seed/Resources/icon_master.svg` exists and is valid (`xmllint --noout` if available; otherwise trust qlmanage to surface a render failure).
2. Invoke `bin/generate-icons.sh`:
   ```sh
   bin/generate-icons.sh \
     Seed/Resources/icon_master.svg \
     Seed/Assets.xcassets/AppIcon.appiconset
   ```
   The script uses qlmanage → JPEG round-trip alpha strip → 7 `sips` resizes (1024 / 180 / 167 / 152 / 120 / 120 / 80). No external rasterizer required — works on a fresh macOS without `brew install librsvg`.
3. Run `xcodebuild test -only-testing:SeedTests/AppIconAssetTests` — confirms the full set is present and non-zero.
4. Commit with `chore(icons): regenerate from icon_master.svg`.

## Output

```
/generate-icons

Source: Seed/Resources/icon_master.svg
Renderer: qlmanage + sips (macOS-builtin)

✓ Seed/Assets.xcassets/AppIcon.appiconset — 7 icon variants rendered
  icon-1024.png      (1024×1024, App Store)
  icon-60@3x.png     (180×180, iPhone @3x)
  icon-60@2x.png     (120×120, iPhone @2x)
  icon-40@3x.png     (120×120, iPhone Spotlight @3x)
  icon-40@2x.png     (80×80,  iPhone Spotlight @2x)
  icon-76@2x.png     (152×152, iPad)
  icon-83.5@2x.png   (167×167, iPad Pro)

AppIconAssetTests: PASSED
```

## Forbidden

- Never hand-edit the generated PNGs — edit `icon_master.svg` and re-run.
- No pure `#000000` / `#FFFFFF` in the icon — use the palette's off-black / off-white from `Theme/AppTheme.swift`.
- Do NOT bypass `bin/generate-icons.sh` and run `sips`/`qlmanage` by hand — the alpha-strip step is easy to forget, and an alpha-bearing 1024.png is rejected by `actool` (the trap Phase 8 surfaced).
