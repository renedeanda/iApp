# Palette Catalog — Departure Points

> Palettes are *seeds*, not picks. `/pick-palette` proposes 3 seeds matching the chosen visual identity; you capture the bespoke delta from the seed in `DECISIONS/002-palette.md`. No two apps in your portfolio should ship with identical palettes.

This doc lists 10 seeds. As your apps ship, record each claimed palette in [PORTFOLIO.md](PORTFOLIO.md) — the `/pick-palette` skill checks new picks against *your* claims. The skill enforces:

1. **No `#000` or `#FFF`** — primary surface and primary text are always offset toward warm or cool.
2. **AAA contrast** between primary surface and primary text. WCAG 21:1 hard limit; AAA ≥7:1 for body text, ≥4.5:1 for large text.
3. **ΔE2000 ≥ 15** between the chosen palette and every claimed palette in PORTFOLIO.md. Lower triggers a clash warning.
4. **Visual-identity consistency** — brutalist apps don't pick a hand-drawn-coded seed; glassmorphic apps don't pick a brutalist accent. The skill cross-references [docs/VISUAL_IDENTITIES.md](../docs/VISUAL_IDENTITIES.md).

---

## The 10 catalogued seeds

Hex values are anchor points. Departure deltas captured in the app's ADR are the real palette.

### 1. Sage

**Mood:** quiet competence. Earthy without being earnest.
**Identity match:** warm-minimal, typographic-led, hand-drawn.

| Token | Hex | Role |
|---|---|---|
| Surface | `#EAEBE0` | primary background — pale sage |
| Surface secondary | `#DCDED1` | cards, sheets |
| OnSurface | `#23271F` | body text (contrast 11.4:1 ✓ AAA) |
| OnSurface muted | `#5A6051` | secondary text (contrast 4.9:1 ✓ AAA large) |
| Accent | `#7A9B6E` | primary actions — moss |
| Accent contrast | `#FFFFFF` *use OnAccent token, not pure white* | text on accent |

### 2. Cardamom

**Mood:** spiced and grounding. A more saturated cousin of Driftwood.
**Identity match:** warm-minimal, typographic-led.

| Token | Hex | Role |
|---|---|---|
| Surface | `#F2E9D8` | warm cream |
| Surface secondary | `#E8DCC2` | cards |
| OnSurface | `#2E2317` | body (contrast 11.7:1 ✓) |
| OnSurface muted | `#6F5A40` | secondary (contrast 4.8:1 ✓ large) |
| Accent | `#B4753A` | warm copper |

### 3. Marigold

**Mood:** confident. A warm yellow used as *surface*, not just accent.
**Identity match:** warm-minimal, maximalist-collage.

| Token | Hex | Role |
|---|---|---|
| Surface | `#FCEAB2` | soft marigold |
| Surface secondary | `#F7DC8C` | cards |
| OnSurface | `#2C2406` | body (contrast 11.9:1 ✓) |
| OnSurface muted | `#736127` | secondary (contrast 4.7:1 ✓ large) |
| Accent | `#A0541C` | rust |

### 4. Plum

**Mood:** evening, considered, slightly luxurious.
**Identity match:** monochrome-luxe, typographic-led, dark variants of warm-minimal.

| Token | Hex | Role |
|---|---|---|
| Surface | `#2A1E2C` | deep plum (dark mode native) |
| Surface secondary | `#3D2D40` | cards |
| OnSurface | `#F0E6F2` | body (contrast 13.2:1 ✓) |
| OnSurface muted | `#B2A0B6` | secondary (contrast 6.4:1 ✓) |
| Accent | `#C898D9` | soft lavender |

### 5. Lavender Frost

**Mood:** cool calm. The analytical cousin of a warm pink-violet.
**Identity match:** warm-minimal (cool variant), glassmorphic (light backgrounds).

| Token | Hex | Role |
|---|---|---|
| Surface | `#ECE9F2` | pale lavender |
| Surface secondary | `#DBD7E4` | cards |
| OnSurface | `#221F2E` | body (contrast 12.5:1 ✓) |
| OnSurface muted | `#5F5A75` | secondary (contrast 5.6:1 ✓) |
| Accent | `#7E6EB8` | iris |

### 6. Copper Dawn

**Mood:** sunrise on metal. Light + warm + a little industrial.
**Identity match:** monochrome-luxe (light variant), kinetic-type, warm-minimal.

| Token | Hex | Role |
|---|---|---|
| Surface | `#F8E8D8` | warm bone |
| Surface secondary | `#EDD6BD` | cards |
| OnSurface | `#2F1F12` | body (contrast 12.9:1 ✓) |
| OnSurface muted | `#7B5A3F` | secondary (contrast 4.9:1 ✓ large) |
| Accent | `#B8703A` | copper |

### 7. Driftwood

**Mood:** weathered warmth. Calm neutrals with a woody backbone.
**Identity match:** warm-minimal, typographic-led, hand-drawn.

| Token | Hex | Role |
|---|---|---|
| Surface | `#F0E9DE` | warm sand |
| Surface secondary | `#E3D8C8` | cards |
| OnSurface | `#2A241B` | body (contrast 12.2:1 ✓) |
| OnSurface muted | `#6B5F4E` | secondary (contrast 5.0:1 ✓) |
| Accent | `#7B5E3B` | driftwood brown |

### 8. Slate Sky

**Mood:** overcast morning. Calm, cool, productive.
**Identity match:** brutalist (light variant), warm-minimal (cool variant), kinetic-type.

| Token | Hex | Role |
|---|---|---|
| Surface | `#E2E4E8` | pale slate |
| Surface secondary | `#CFD2D8` | cards |
| OnSurface | `#1B1F26` | body (contrast 12.1:1 ✓) |
| OnSurface muted | `#54596A` | secondary (contrast 6.1:1 ✓) |
| Accent | `#3D6E96` | slate blue *(if AA Large fails on your departed surface, deepen toward `#345F86`)* |

### 9. Fern

**Mood:** alive. Greener than Sage; less earthy, more vibrant.
**Identity match:** maximalist-collage, hand-drawn, warm-minimal.

| Token | Hex | Role |
|---|---|---|
| Surface | `#EFF5E8` | pale fern |
| Surface secondary | `#DDE9CF` | cards |
| OnSurface | `#1F2A18` | body (contrast 12.6:1 ✓) |
| OnSurface muted | `#536644` | secondary (contrast 5.4:1 ✓) |
| Accent | `#5B8A3D` | fern green |

### 10. Terracotta

**Mood:** autumn, considered, slightly bookish.
**Identity match:** typographic-led, hand-drawn, maximalist-collage.

| Token | Hex | Role |
|---|---|---|
| Surface | `#F2DDD0` | warm beige |
| Surface secondary | `#E5C6B3` | cards |
| OnSurface | `#2E1C12` | body (contrast 12.4:1 ✓) |
| OnSurface muted | `#7B4D38` | secondary (contrast 4.7:1 ✓ large) |
| Accent | `#A03A24` | rust |

> A seed can be departed more than once across a portfolio — but each departure must clear ΔE2000 ≥ 15 against **every** previously claimed accent, not just the seed. Typical open directions when a warm seed is already claimed: rotate the accent hue ≥15°, go darker/bookish, or push chroma up. Record the direction you took (and the directions you foreclosed for future apps) in the claim note in PORTFOLIO.md.

---

## ΔE2000 distances vs claimed palettes

There is no precomputed distance table here — distances depend on *your* claims. The `/pick-palette` skill computes ΔE2000 (D65 illuminant, 2° observer; implementation in `pick-palette/SKILL.md`) between the candidate accent and **every** claimed palette in your PORTFOLIO.md at runtime, and shows the full distance matrix when any value falls below 15. Trust the runtime computation, not any snapshot.

Rules of thumb while choosing:

- Two accents in the same hue family at similar lightness usually land around ΔE2000 ≈ 10–14 — a clash. Depart by rotating hue or dropping saturation.
- Distances ≥ 15 are safe; 15–18 is worth eyeballing side-by-side anyway.
- Seeds with no claimed neighbor in their color region (e.g. nothing green claimed yet) are automatically safe.

---

## Departure-delta discipline

The wizard *never* ships a child app with the seed values verbatim. The chosen palette is always the bespoke delta:

```
DECISIONS/002-palette.md

Seed: Sage
Departure delta:
- Surface shifted 6° toward blue (cooler, less earthy than seed)
- Accent saturation reduced 12% (less assertive than seed moss)
- Added "Surface tertiary" token for sheet headers (not in catalog spec)

Final palette:
  Surface           #E8EBE3
  Surface secondary #DADFD2
  Surface tertiary  #C8CFC0
  OnSurface         #21261E
  OnSurface muted   #5A6051
  Accent            #7A9270  (less saturated than seed)
```

The delta lives in the ADR. The token values live in `Seed/Theme/AppTheme.swift`. The seed name lands in `PORTFOLIO.md`'s "Claimed palette names" table after the app ships.

## Adding a new seed

If a new app discovers a color region not represented in the catalog, the path is:

1. Ship the app.
2. Open a PR to this doc adding the new seed in the same form as the ten above.
3. Compute ΔE2000 against every claimed accent in your portfolio; include the table.
4. The PR description must justify why none of the existing ten covered the use case.

The catalog grows. The rule: every seed must serve at least two of the eight visual identities; single-purpose seeds belong in the child app's ADR, not here.

## Forbidden palette patterns

- **Pure `#000` or `#FFF` anywhere.** Period. Not even as a token labeled "pure white" or "true black."
- **Single-accent system.** Every palette ships at minimum: Surface, Surface-secondary, OnSurface, OnSurface-muted, Accent. Anything thinner can't honor the design rules.
- **Accent that fails AAA on the chosen surface.** The `pick-palette` skill computes this and refuses the seed if the user's departure delta crosses the threshold.
- **Dark mode as an afterthought.** Every seed has both light and dark token sets. The PORTFOLIO entry must show both anchors.
