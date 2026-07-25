# Architecture — How the Repo Fits Together

iApp has three interacting layers. This doc explains how they relate and how a fresh Claude session navigates them.

```
┌────────────────────────────────────────────────────────────────────┐
│  Portfolio brain  (knows what exists in YOUR portfolio)              │
│  ├── portfolio/PORTFOLIO.md          who shipped, when, what palette │
│  ├── portfolio/PALETTE_CATALOG.md    which palettes are unclaimed    │
│  ├── portfolio/MONETIZATION_MATRIX.md  per-app pricing decisions      │
│  ├── portfolio/REUSE_INDEX.md        feature → source-path map       │
│  └── portfolio/RECENT_LEARNINGS.md   cross-app lessons               │
│                                                                       │
│  DECISIONS/    (knows what to decide for every new app)              │
│  ├── 000-mission.md                  one sentence                    │
│  ├── 001-tech-choice.md              Swift vs RN                     │
│  ├── 002-palette.md                  seed + departure delta          │
│  ├── ...                                                              │
│  └── 015-visual-identity.md          brutalist / glassmorphic / ...  │
│                                                                       │
│  recipes/  (knows how to add a feature)                              │
│  ├── swift/add-cloudkit.md           When/When-not-to/How             │
│  ├── swift/add-live-activity.md                                       │
│  ├── ...                                                              │
│  └── rn/icloud-bridge.md                                              │
│                                                                       │
│  templates/  (the runnable scaffolds)                                │
│  ├── swift/  XcodeGen + SwiftUI + 20+ services in _Disabled/         │
│  └── rn/     Expo SDK 54 + native widget bridge + i18next            │
│                                                                       │
│  .claude/  (the wizard)                                              │
│  └── skills/                                                          │
│      ├── new-app/         multi-step interview → renders templates   │
│      ├── pick-tech/       Swift vs RN decision tree                   │
│      ├── pick-palette/    ΔE2000 clash check + departure delta       │
│      ├── pick-visual-identity/                                        │
│      ├── pick-delight-moments/                                        │
│      ├── reliability-check/  blocks harvest from WIP sources          │
│      ├── sync-from-portfolio/  diffs template vs upstream             │
│      └── validate-template/                                           │
└────────────────────────────────────────────────────────────────────┘
```

## How the layers interact

### Top-down — a new app

```
mission (sentence)
   └─→ DECISIONS/000-mission.md
         └─→ positioning-check against portfolio/PORTFOLIO.md
               └─→ if clear, proceed; if clash, surface and ask
                     └─→ visual identity → palette → typography → motion → delight → haptics
                           └─→ tech choice → monetization → feature toggles
                                 └─→ reliability-check (is the harvest source production-grade?)
                                       └─→ render templates with substitutions
                                             └─→ git push + PR back to iApp (claim palette, add portfolio row)
```

### Bottom-up — adding a feature to an existing app

```
"I want to add a widget"
   └─→ recipes/swift/add-widget.md
         ├── When to use: glanceable state, lock-screen value, etc.
         ├── When NOT to use: just-launches-the-app, requires user action in widget
         └── How:
               ├── source: templates/swift/SeedWidgets/  (the gold-standard widget scaffold)
               ├── steps: copy SeedWidget.swift, register in WidgetBundle, edit project.yml
               └── verify: xcodebuild + WidgetLocalizationParityTests + WidgetEdgeToEdgeTests
```

### Sideways — evolving iApp itself

```
new pattern proven in a child app
   └─→ /sync-from-portfolio
         ├── diffs the child's file against the template version
         ├── shows the delta as a PR to iApp
         └── on merge, the next /new-app inherits the improvement
```

## The three boundaries

### 1. Templates ↔ Children

Templates are *forks-by-copy*, not *forks-by-symlink*. When `/new-app --commit` renders the Swift template, it copies the file tree into the new repo with name/bundle/palette substitutions. There is no runtime dependency from the child back to iApp.

This means:

- Children can diverge from the template without breaking. Each app evolves its own way.
- iApp evolving the template does *not* automatically update children. Sync happens via `/sync-from-portfolio`, which is explicit and reviewable.
- Each templated file ships with a `// SOURCE: <template path>@<sha>` header comment so `git diff` against the original is one command.

### 2. Portfolio brain ↔ DECISIONS

The portfolio docs describe *what exists*. The DECISIONS docs describe *what to decide*. They cross-reference:

- `PORTFOLIO.md` lists every app in your portfolio + its key DECISIONS values (palette, monetization, signature motion, visual identity, delight moments). Single source of truth for "what does app X look like?"
- `PALETTE_CATALOG.md` is the unclaimed list. The "claimed" list lives in PORTFOLIO.md.
- `REUSE_INDEX.md` answers "where do I copy from?"
- `RECENT_LEARNINGS.md` is the changelog of taste decisions.

When a new app finishes `/new-app --commit`, three files get updated in iApp via a PR:

1. `PORTFOLIO.md` — new row.
2. `PALETTE_CATALOG.md` — chosen seed marked claimed (with departure delta linked).
3. `MONETIZATION_MATRIX.md` — new row.

### 3. Skills ↔ Docs

Skills (`.claude/skills/*`) are the operationalization of docs. Each skill SHOULD reference the doc(s) it enforces:

| Skill | Reads doc(s) |
|---|---|
| `pick-visual-identity` | `docs/VISUAL_IDENTITIES.md` |
| `pick-delight-moments` | `docs/DELIGHT_REEL.md` |
| `pick-palette` | `portfolio/PALETTE_CATALOG.md`, `portfolio/PORTFOLIO.md` (claimed list) |
| `pick-haptic-vocabulary` | the 24-pattern reference in `templates/swift/Seed/Utilities/_HapticVocabulary/` |
| `pick-tech` | `recipes/swift/`, `recipes/rn/` (compares feature surface area) |
| `positioning-check` | `portfolio/PORTFOLIO.md` (mission column) |
| `reliability-check` | `portfolio/REUSE_INDEX.md` reliability matrix |
| `new-app` | orchestrates all of the above |
| `sync-from-portfolio` | reads `templates/` + the source repo, produces a diff |

If a doc changes, the skill behavior changes the next time it runs. No code-gen, no compile step.

## Decision flow for a new feature

When a user asks "can we add X to my app?", the agent's decision flow:

```
1. Is X in docs/NOT_FOR.md (the hard list)?
   └─→ Yes: surface NOT_FOR + ask user to clarify intent
   └─→ No: continue

2. Is X also in docs/WHATS_ALLOWED.md with a positive framing?
   └─→ Yes: surface the distinction, build the positive framing
   └─→ No: continue

3. Is there a recipe in recipes/swift/ or recipes/rn/?
   └─→ Yes: follow it (mind the "When NOT to use")
   └─→ No: continue

4. Is the gold-standard source in portfolio/REUSE_INDEX.md?
   └─→ Yes: harvest from the named source, write a new recipe afterward
   └─→ No: this is novel — write an ADR, then implement, then write the recipe
```

## When this architecture breaks

If a new pattern doesn't fit any of the layers above:

- **A new visual identity** — add to `docs/VISUAL_IDENTITIES.md`.
- **A new monetization model** — add to `portfolio/MONETIZATION_MATRIX.md`.
- **A new feature category** — add a recipe to `recipes/swift/` or `recipes/rn/`.
- **A new wizard step** — add a skill to `.claude/skills/` and a corresponding doc.
- **A new portfolio app** — add to `PORTFOLIO.md` row + update `PALETTE_CATALOG.md` claim + update `MONETIZATION_MATRIX.md` row.
- **A new taste rule that doesn't fit anywhere** — write a PR adding a new doc. The architecture is allowed to grow; "we put it in the wrong doc" is not allowed.

## Why this architecture works

1. **Templates are thick on disk but thin by default.** Discipline lives in the wizard, not in the file tree. Every reusable service is available; only the chosen ones are active.

2. **Docs and skills are paired.** A skill without a doc is opaque; a doc without a skill is decoration. Every taste rule has both.

3. **Children diverge freely.** Once a new app ships, it owns its file tree. Sync is opt-in via `/sync-from-portfolio`, which produces a reviewable PR — not an automated overwrite.

4. **The portfolio is the single source of truth.** "What palette does app X use?" has one answer, in one file. "What's the gold-standard for Live Activities?" has one answer, in one file. Drift is impossible.

5. **Sleep is built in.** The wizard refuses to scaffold and ship in a single session. Every new app gets at least one night between decision and commit.

If any of these break, the architecture has failed. Fix the doc, the skill, or the boundary — don't paper over with one-off scripts.
