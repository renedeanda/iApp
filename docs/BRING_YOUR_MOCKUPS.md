# Bring Your Mockups — Designs Drive the Wizard

Already designed your app — in Figma, Sketch, Canva, Keynote, or a notebook? Wonderful: you're ahead, not off-path. AI coding agents can **look at images**, so your existing mockups can drive the wizard's design decisions instead of starting from prose. This guide is how to bring them in, from any tool.

## The one universal step

Export each screen as a **PNG (or JPG) image file** and put the files in your draft folder:

```
drafts/<app-name>/mockups/
├── 01-home.png
├── 02-add-item.png
├── 03-detail.png
├── 04-settings.png
└── flow-overview.png      # optional: the whole flow on one canvas
```

Two conventions that do real work:

- **Number the files in the order a new user meets the screens.** The sequence *is* your first-sixty-seconds story — the wizard reads it that way.
- **One screen per image, phone-shaped.** Export at 2x if the tool offers it; text in the mockups should be readable.

That's it. Everything else below is per-tool detail and what happens next.

## Exporting from each tool

| Tool | How to get PNGs |
|---|---|
| **Figma** | Select a frame → right panel **Export** → PNG, 2x → Export. Repeat per screen (or select multiple frames and export all at once). A view-only share link is a nice *supplement* for your session notes, but export the PNGs anyway — files in the repo beat links an agent may not be able to open. |
| **Sketch** | Select artboard → **Export** in the inspector → PNG 2x. |
| **Canva** | Share → **Download** → PNG, select the pages → Download. |
| **Keynote / PowerPoint** | File → Export To → Images → PNG (one per slide). |
| **Play / interactive prototype tools** | Export stills of each screen; note interactions in your worksheet or session chat ("tapping the card flips it"). |
| **Paper sketches** | Photograph each page straight-on in good light — genuinely good enough. Agents read hand-drawn wireframes happily. Label each photo's filename with the screen name. |

## What the wizard does with them

When `drafts/<app-name>/mockups/` exists, the `/new-app` wizard **views the images before the design steps** and uses them as evidence:

| Wizard step | What your mockups feed it |
|---|---|
| Visual identity | Classifies which of the eight identities your designs are already speaking (or flags that they're speaking two). |
| Palette | Extracts your dominant colors, proposes the nearest catalog seed, and records your actual hexes as the departure delta — your palette, made systematic. |
| Typography | Matches your type feel (rounded / serif / mono-leaning) to the closest shipped specimen. |
| First sixty seconds | Your file ordering becomes the draft flow narration — the wizard asks you to confirm it screen by screen. |
| Navigation & screens | Sheet-vs-push structure, tab count, and the screens list in the spec come from what you drew, not from guesses. |
| Delight moments | Anything your mockups *imply* moves (a celebratory state, an empty-state illustration) becomes a candidate — you still pick the 3–5. |

**Mockups inform; taste rules still gate.** The wizard will honor your design's *intent* but may propose small deltas where a rule demands it: text/background pairs below AAA contrast get nudged, pure `#000`/`#FFF` surfaces get offset, and motion/haptics (which mockups can't show) still get asked as questions. Every delta is surfaced to you — nothing is silently "corrected."

## No mockups? Also fine

The wizard's questions produce the design decisions from words. Mockups are an accelerator, not an entry requirement — don't delay a session to make them. A napkin photo of the home screen is worth bringing; a week of Figma polish before you've validated the mission is the wrong order.

## Tips for the session

- Say which tool the mockups came from and how final they are ("directional, colors not decided" vs "pixel-final") — it changes how literally the wizard reads them.
- If screens exist for features you've cut, delete those exports first; agents will faithfully design for what they see.
- Keep the mockups folder in the draft — when `/new-app --commit` renders the app, the folder rides along as the design record referenced by your ADRs.
