# ADR 015 — Visual Identity

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Per docs/VISUAL_IDENTITIES.md + CLAUDE.md taste rule 4: visual identity is novelty-encouraged. The wizard offers eight canonical identities (brutalist / glassmorphic / warm-minimal / typographic-led / hand-drawn / maximalist-collage / kinetic-type / monochrome-luxe). Templates default to warm-minimal but the default is a starting point, not a destination.

Kindling is a docs repo. Identity still matters — the felt-quality of browsing the README + docs.

## Decision

**Kindling's visual identity is *infrastructural-clean*** — which isn't one of the eight, and that's deliberate. The eight are for *products*; Kindling is *infrastructure*.

Concretely, "infrastructural-clean" means:

- **Markdown-rendered, GitHub-default styling.** No custom CSS. Audience reads on GitHub.
- **Tables and code fences over prose paragraphs** where structured information is involved (REUSE_INDEX matrix, MONETIZATION_MATRIX ladder).
- **Cross-references over duplication.** Every concept lives in one canonical file; other files link.
- **One-sentence declarations over multi-paragraph framings.** Mission is one sentence. Anti-list is bullets. ADRs cap sections deliberately.
- **No decorative visuals.** No banners, no animated SVGs, no GIF demos. The text is the product.

If Kindling ever publishes a GitHub Pages site (deferred per ADR 010), that site uses the template's warm-minimal palette — matching what the scaffold ships, not claiming a unique identity.

### Why not one of the eight

| Identity | Why Kindling isn't this |
|---|---|
| Brutalist | Closest fit (utilitarian, type-led), but Kindling doesn't reject softness as a *principle* — it just doesn't have UI to apply softness to. |
| Glassmorphic | No chrome to apply Liquid Glass to. |
| Warm-minimal | Borrowed for hypothetical GitHub Pages; not Kindling's primary identity. |
| Typographic-led | Tempting (docs are text) but typographic-led is about *expressive* typography (serif drama, light/heavy contrast). Kindling's text is functional, not expressive. |
| Hand-drawn | Wrong audience. |
| Maximalist-collage | Wrong everything. |
| Kinetic-type | No type animation; this is static Markdown. |
| Monochrome-luxe | Wrong audience (developers don't pay $50 for utility infrastructure). |

The eight identities are validated by *shipping product apps with the identity*. Kindling is not a product. Forcing one of the eight would be cosmetic.

### Child app ADR 015 shape

```markdown
# ADR 015 — Visual Identity

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Decision

Identity: <one of the eight canonical, OR a justified ninth>
- ☐ Brutalist
- ☐ Glassmorphic
- ☐ Warm-minimal (template default — deviating is encouraged)
- ☐ Typographic-led
- ☐ Hand-drawn
- ☐ Maximalist-collage
- ☐ Kinetic-type
- ☐ Monochrome-luxe
- ☐ Hybrid (write addendum — e.g., "warm-minimal body + glassmorphic chrome")
- ☐ Ninth identity (PR to VISUAL_IDENTITIES.md required; cite a shipped app as proof)

## What this identity means for THIS app

<one sentence — must tie back to mission in ADR 000>
e.g., "The brutalism honors working people's time by stripping decoration."
e.g., "The warm-minimal honors the nervous-system reset by feeling like a held breath."

## Downstream implications

- /pick-palette filters seeds to those matching this identity
- /pick-typography filters specimens (brutalist → mono/condensed; warm-minimal → rounded)
- /pick-signature-motion filters principles (brutalist → hard-cut; glassmorphic → ripple)
- Launch screen style:
  - Warm-minimal → soft logo + breathing fade-in (Soft)
  - Dark → instant palette wash (Instant)
  - Brutalist → plain palette wash, no logo (Plain)

## Forbidden deviations

Per VISUAL_IDENTITIES.md "Forbidden anti-identities":
- Skeuomorphic (leather, fake wood)
- Neumorphism
- Generic Material Design
- Dark-mode-only as identity

## Portfolio diversity check

Like monetization (ADR 003), visual identity is a portfolio-wide concern, not just
a per-app choice. A portfolio where 5/7 apps are warm-minimal reads as monotone;
one where each app claims a distinct identity reads as a varied craft studio.

Keep a live distribution table in your PORTFOLIO.md. Worked example with a
fictional 7-app portfolio:

| Identity | Apps | % of portfolio |
|---|---|---|
| Brutalist | Ledger | 1/7 |
| Glassmorphic (chrome only — body is warm-minimal) | Quill | 1/7 hybrid |
| Warm-minimal | Pause, Quill body | 2/7 |
| Dark-minimal *(legacy, predates framework)* | Horizon | 1/7 |
| Playful-pastel *(legacy)* | Sprig | 1/7 |
| Warm-utilitarian *(legacy)* | Petal | 1/7 |
| Customizable | Dots | 1/7 |
| **Typographic-led** | — | 0/7 — *open slot* |
| **Hand-drawn** | — | 0/7 — *open slot* |
| **Maximalist-collage** | — | 0/7 — *open slot* |
| **Kinetic-type** | — | 0/7 — *open slot* |
| **Monochrome-luxe** | — | 0/7 — *open slot* |

The wizard surfaces this distribution when /pick-visual-identity runs. If a new
app's mission could plausibly fit multiple identities, the wizard prefers the
underrepresented one — without ever overriding mission fit.

Trade-off acknowledgment shape:
- "Recommended: warm-minimal. Portfolio already has 2/7 on warm-minimal. Mission
  supports either warm-minimal or hand-drawn — picking hand-drawn would fill an
  open slot. Proceed with warm-minimal anyway?"
- "Recommended: brutalist. Portfolio currently has 1/7 brutalist. A second
  brutalist app would dilute the first one's distinctness. Consider a
  'brutalist-adjacent' palette on a non-brutalist identity?"

Mission always wins. The mix is a tie-breaker.
```

## Options considered

For Kindling itself:

- **Force into brutalist** — rejected. Brutalist belongs to product apps that ship it. Claiming it for infrastructure dilutes the proof.
- **Force into warm-minimal** — rejected. Warm-minimal is the template default for *apps*; Kindling isn't an app.
- **Force into typographic-led** — rejected (see table above).
- **Claim "infrastructural-clean" as a ninth identity** — rejected. Adding to VISUAL_IDENTITIES.md requires a shipped *product* app as proof. Kindling is infrastructure, doesn't qualify. The honest answer is "this identity is for products only; Kindling doesn't claim one."

## Consequences

- **Unlocks:** the eight-identity list stays clean — only product apps with shipped proof appear there.
- **Forecloses:** Kindling claiming visual primacy. Cleanly demarcates "this is infrastructure, not a product."
- **Cost to revisit:** small. If Kindling ever becomes a product (unlikely), this ADR gets superseded.

## Cross-references

- [docs/VISUAL_IDENTITIES.md](../docs/VISUAL_IDENTITIES.md) — the canonical eight
- [docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md) — visual identity as first-class decision
- [CLAUDE.md](../CLAUDE.md) taste rule 4 — novelty is a feature
- ADR 000 (mission) — infrastructure, not product, justifies the non-eight choice
- ADR 002 (palette) — warm-minimal borrowed for hypothetical GitHub Pages
- ADR 010 (first 60 seconds) — developer's GitHub-landing experience
- [ADR 003](003-monetization.md) — parallel portfolio-diversity logic for monetization
