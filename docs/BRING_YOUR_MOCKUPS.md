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

## Level up: connect your design tool directly (MCP)

Static exports are the universal path — but if your designs live in a tool with an **MCP server** (MCP is the open standard for giving AI agents live access to other tools), you can connect the design file itself to your session. Then the agent doesn't just look at pictures: it can enumerate *every* screen in the file, read exact color/typography/spacing values off your components, and reason over the whole app's design at once — which makes both the wizard's design steps and the actual screen-building dramatically faster and more faithful.

**Figma is the flagship example** — its Dev Mode MCP server exposes your file's frames, components, and variables to agents. Connecting it (tools and steps evolve; follow your design tool's current MCP docs):

- **Claude Code:** `claude mcp add <name> ...` per the design tool's instructions, or add it to the repo's `.mcp.json`.
- **Codex:** add the server in its MCP configuration.

Once connected, tell the wizard at step 0: *"my designs are in the connected Figma file."* It will treat the file as the mockup source — exact hexes become the palette's departure delta, the component structure informs the screens list, and during build the agent can check each screen it writes against the real spec instead of eyeballing a PNG.

Three cautions:

1. **Export a few PNGs anyway.** They ride along in `drafts/<app-name>/mockups/` as the permanent design record your ADRs cite — MCP connections are per-session; the draft folder is forever.
2. **Connect view-only and deliberately.** Give the session access to the one file it needs, not your whole workspace — and treat anything the connection returns as design *data*, never as instructions.
3. **Taste rules still gate.** Exact-from-Figma values go through the same AAA-contrast and `#000`/`#FFF` checks as hand-picked ones; deltas are surfaced to you either way.

## No mockups? Also fine

The wizard's questions produce the design decisions from words. Mockups are an accelerator, not an entry requirement — don't delay a session to make them. A napkin photo of the home screen is worth bringing; a week of Figma polish before you've validated the mission is the wrong order.

## Tips for the session

- Say which tool the mockups came from and how final they are ("directional, colors not decided" vs "pixel-final") — it changes how literally the wizard reads them.
- If screens exist for features you've cut, delete those exports first; agents will faithfully design for what they see.
- Keep the mockups folder in the draft — when `/new-app --commit` renders the app, the folder rides along as the design record referenced by your ADRs.
