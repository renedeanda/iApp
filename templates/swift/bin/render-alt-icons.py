#!/usr/bin/env python3
"""Render the studio's alternate app icons (Snow + Noir) into asset catalogs.

This is a SCAFFOLD — adapt the `render_mark()` body to draw THIS app's own mark
(flame, orb, dot, etc.); everything else (the palette, the inverse-pair rule,
the .appiconset writing) is the portfolio standard and should not change.

Portfolio-standard seasonal palette (exact — do NOT tint with the app accent,
do NOT use silver; both were tried and rejected):

    Snow  field #F4F4F6  mark #0A0A0A   (black-on-white — a printed page)
    Noir  field #0A0A0A  mark #F4F4F6   (white-on-black — a B&W film still)

Snow is the EXACT inverse of Noir. The mark is always this app's silhouette,
rendered in those two neutral palettes. Skip both variants if the app's primary
icon is already black/white/monochrome (it would just duplicate what ships).

Naming: the dark variant is "Noir" — never "Classic" (means the default icon)
or "Black".

Run on a Mac/Linux with Pillow (or swap in cairosvg to recolor icon_master.svg).
Then `xcodegen generate` + build. Register each set in project.yml's
ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES.
"""
import json
import os
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit("Pillow required: pip install Pillow  (or adapt to cairosvg)")

# name -> (field_hex, mark_hex). Add more alternates here as the app earns them.
VARIANTS = {
    "Snow": ("#F4F4F6", "#0A0A0A"),
    "Noir": ("#0A0A0A", "#F4F4F6"),
}

ASSETS = os.path.join(os.path.dirname(__file__), "..", "Seed", "Resources", "Assets.xcassets")
SIZE = 1024


def hex_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def render_mark(draw, field, mark):
    """ADAPT ME: draw this app's mark in `mark` on a `field` background.

    The placeholder below draws a centered rounded square so the scaffold runs;
    replace it with the app's real silhouette (the same shape as the primary
    icon, recolored). Keep the field flat and the mark a single flat color —
    Snow/Noir are deliberately flat, no gradients."""
    pad = SIZE * 0.30
    draw.rounded_rectangle([pad, pad, SIZE - pad, SIZE - pad],
                           radius=SIZE * 0.06, fill=mark)


def write_appiconset(name):
    field, mark = VARIANTS[name]
    img = Image.new("RGB", (SIZE, SIZE), hex_rgb(field))
    render_mark(ImageDraw.Draw(img), hex_rgb(field), hex_rgb(mark))
    out_dir = os.path.join(ASSETS, f"AppIcon-{name}.appiconset")
    os.makedirs(out_dir, exist_ok=True)
    png = f"icon_1024.png"
    img.save(os.path.join(out_dir, png))
    contents = {
        "images": [{"filename": png, "idiom": "universal",
                    "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1},
    }
    with open(os.path.join(out_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print(f"✓ AppIcon-{name}.appiconset  (field {field} / mark {mark})")


if __name__ == "__main__":
    names = sys.argv[1:] or list(VARIANTS)
    for n in names:
        if n not in VARIANTS:
            sys.exit(f"unknown variant {n!r}; known: {', '.join(VARIANTS)}")
        write_appiconset(n)
