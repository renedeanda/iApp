# Visual Identities — Departure Points, Not Defaults

> An Apple-featured app feels new. Apps that feel new follow Apple HIG **and** declare a visual identity beyond the default SwiftUI styling. This doc catalogs the eight identities the wizard offers.

The wizard's `/pick-visual-identity` step asks every new app to pick one. The template ships **warm-minimal** as the default, but the default is a *starting point*, not a destination. Deviating is encouraged and earns no penalty — a brutalist commute app or a hand-drawn gratitude app has character precisely because it departed from the default.

## The eight identities

### 1. Brutalist

**Vocabulary:**
- Thick rules. Hard cuts. No soft shadows.
- Monospaced or condensed sans for everything except headings.
- Monochrome with one screaming accent (think concrete gray + a single saturated yellow).
- No animations on transitions — sheets snap, don't slide.
- Type-led hierarchy. Weight shifts replace color shifts.
- The grid is visible.

**When to pick:**
- Utility apps with a strong functional core (a transit engine, a calculator, a converter).
- Apps where "playful" would feel dishonest.
- Audiences that respect rigor (developer tools, working-people apps, productivity-first apps).

**When not to pick:**
- Apps about emotion, calm, or warmth. Brutalist would feel cold.
- Apps targeting children or families.

**Reference points:**
- The template's `Theme/SignatureMotion.swift` supports a hard-cut (motion-free) signature, and `Theme/_TypographySpecimens/` ships a mono-leaning specimen — the two files that carry most of a brutalist identity.
- Public-world touchstones: Teenage Engineering's product UI, classic Swiss-grid poster design.

### 2. Glassmorphic

**Vocabulary:**
- Liquid Glass material under floating chrome (toolbars, FABs, tab bars).
- Subtle vibrancy — content underneath ghosts through.
- Edge-light on glass elements.
- Soft shadows under glass.
- Background blur, never solid.

**When to pick:**
- Content-first apps where the chrome should disappear (the user's notes or photos are the star; the bars are vehicles).
- Apps with photography, art, or rich color content.
- Apps that want to feel "modern Apple."

**When not to pick:**
- Performance-sensitive apps (glass costs real GPU).
- Accessibility-first apps (glass + low-vision is tricky).

**Reference points:**
- Apple's own Liquid Glass system chrome is the canonical example; the pattern works under any palette.

### 3. Warm-minimal *(default)*

**Vocabulary:**
- Cream / sand / off-white surfaces. No `#FFF`.
- One warm accent (an ember orange, a soft pink-violet).
- Rounded SF Pro Rounded or similar.
- Generous padding. Single-column layouts.
- Soft, springy animations.
- Spacious. Quiet.

**When to pick:**
- Wellness, calm, mindfulness apps.
- Notes / journaling.
- Apps where the goal is "feels like home."

**When not to pick:**
- Apps with high information density (data tables, dashboards).
- Apps where edginess or punch is part of the brand.

**Reference points:**
- The template's default: `templates/swift/Seed/Theme/AppTheme.swift` ships a warm-minimal token set (cream surface, warm accent) out of the box.

### 4. Typographic-led

**Vocabulary:**
- Type is the primary visual element. No icons compete.
- Serif body, light/heavy weight contrast.
- Headings are dramatic — large, alone on a line, with space around them.
- Color is minimal; type weight does the work color usually does.
- Layouts feel like editorial design — magazine-like.

**When to pick:**
- Apps about words: quotes, journaling, poetry, reading.
- Apps where the user wants to feel *read* (subscribed-to-a-serious-newsletter-level seriousness).

**When not to pick:**
- Apps with frequent state changes (animation feels foreign here).
- Apps with non-text primary content.

**Reference points:**
- Editorial apps like NYT Cooking's article surfaces, or classic reading apps where the typography *is* the interface. The template's serif specimen in `Theme/_TypographySpecimens/` is the starting point.

### 5. Hand-drawn

**Vocabulary:**
- Sketched edges (intentionally imperfect SVG strokes).
- Paper texture under content (subtle grain).
- Hand-lettered headings (or carefully chosen humanist sans).
- Margin doodles. Annotations that feel like writing.
- Slight rotation on stickers / cards (1–3° off-axis).
- Color palette inspired by colored pencils / watercolor.

**When to pick:**
- Apps for journaling, sketching, planning by hand.
- Apps targeting creative audiences.
- Apps that want to feel *yours* (the app), not corporate.

**When not to pick:**
- Productivity apps where polish signals trust.
- Apps that need to feel "premium" or "expensive."

### 6. Maximalist-collage

**Vocabulary:**
- Overlapping shapes. Layered cards. Asymmetric grids.
- Mixed media: photos + illustration + type + texture.
- Color riot, held by composition.
- Movement: things slide, stack, peek out from behind each other.
- Bold accents on multiple sides — not "one accent color," but a *system* of accents.

**When to pick:**
- Apps for collecting, curating, scrapbooking, mood-boarding.
- Apps that want to feel like a magazine.
- Apps where the user *adds* visual content (their content becomes part of the design).

**When not to pick:**
- Apps where clarity is paramount.
- Apps with screen-reader-first accessibility goals (maximalism is hard for VO).

### 7. Kinetic-type

**Vocabulary:**
- Animated headings. Type as motion.
- Letterform morphing on state changes (a number's weight shifts as its value changes).
- Type that responds to scroll position.
- Carefully tuned timing — kinetic type is wrong at 1 fps and wrong at 60 fps; usually 24–30 fps frame quantization feels right.
- Minimal non-type animation (the type does all the work).

**When to pick:**
- Apps about live data (stock, sports, news tickers).
- Apps with one or two "hero" numbers that change (a countdown, a departure timer).
- Apps that want to feel cinematic.

**When not to pick:**
- Accessibility-first apps (kinetic type + dyslexia is unforgiving).
- Apps with dense text content (kinetic type loses meaning when there's too much of it).

### 8. Monochrome-luxe

**Vocabulary:**
- Pure grayscale base. Black-to-white range, no chromatic color.
- One metal accent: gold, copper, steel, brass.
- Heavy weight contrast in type (300 → 800).
- Generous negative space.
- Subtle texture (paper grain, metal brushed).
- Precision in geometry — circles are perfectly round, rules are exactly the right thickness.

**When to pick:**
- Premium apps where the price tag is part of the value (subscription-only, $50+ tier).
- Apps for collectors, watch enthusiasts, audiophiles, etc.
- Apps targeting an audience that respects restraint.

**When not to pick:**
- Mass-market apps. Monochrome-luxe is a niche signal.
- Apps for users with photoreceptor sensitivity issues (pure grayscale on OLED can be harsh).

## How the wizard uses this doc

```
$ /new-app --draft
> ...
> Visual identity (declared up front — pick one):

  1. Brutalist
  2. Glassmorphic
  3. Warm-minimal          (default)
  4. Typographic-led
  5. Hand-drawn
  6. Maximalist-collage
  7. Kinetic-type
  8. Monochrome-luxe

> Selection: 1

> What about brutalism does this app embrace? (one sentence)
The grid is visible because the user's time is structured.

Writing DECISIONS/015-visual-identity.md...
```

The chosen identity affects every downstream wizard step:
- `/pick-palette` proposes seeds consistent with the identity (brutalist → monochrome + one accent; glassmorphic → palettes that work well under glass material; warm-minimal → cream-based; monochrome-luxe → grayscale + metal).
- `/pick-typography` filters specimens (brutalist favors mono/condensed; warm-minimal favors rounded; typographic-led favors serif).
- `/pick-signature-motion` filters motion principles (brutalist accepts hard-cut, rejects bloom; glassmorphic accepts ripple, rejects hard-cut).
- The template's launch screen style adapts.

## Mixing identities

In rare cases, an app uses two identities in different surfaces — e.g. glassmorphic in chrome (toolbars/FABs) but warm-minimal in body content. This is allowed but must be declared explicitly in the ADR:

```
Primary identity: warm-minimal
Chrome identity: glassmorphic (Liquid Glass on toolbars only)
```

The wizard tracks both and applies consistency rules to each surface independently.

## Adding a new identity

If a future app discovers an identity not on this list (industrial / sci-fi / botanical / etc.), the path is:

1. Ship the app.
2. Write a PR to this doc adding the new identity with the new app as proof.
3. Reference the specific files that embody the identity.
4. The PR description must justify why none of the existing eight fit.

Rules don't get added in a Slack thread.

## Forbidden anti-identities

These do not get slots in the wizard, no matter how trendy:

- **Skeuomorphic** — leather textures, paper-stitched UI, fake wood. Has its place in dedicated apps (calculators, calendars) but never as a portfolio default. iOS 7 ended the conversation.
- **Neumorphism** — soft inset/outset shadows everywhere. Accessibility nightmare. Trend-driven.
- **Generic Material Design** — Android-pattern on iOS. The platform deserves its own design language; using Material on iOS signals "we didn't care enough to design for iOS."
- **Dark-mode-only as identity** — dark mode is a *user choice*, not an identity. Every identity above ships light + dark variants.

If a user requests one of the above, the wizard rejects and offers the nearest acceptable identity.

## Portfolio-wide considerations

Visual identity is also a **portfolio-strategy decision**, not only a per-app one. The same logic that drives monetization diversification (see [DECISIONS/003-monetization.md](../DECISIONS/003-monetization.md) + [portfolio/MONETIZATION_MATRIX.md](../portfolio/MONETIZATION_MATRIX.md) "Diversification strategy") applies here: a portfolio where every app shares one identity reads as monotone; one with deliberate spread reads as a craft studio.

The current-distribution table + open-slot list lives in [DECISIONS/015-visual-identity.md](../DECISIONS/015-visual-identity.md) "Portfolio diversity check." `/pick-visual-identity` cross-references it after the per-app fit decision and surfaces a trade-off prompt when the picked identity is already crowded or when an open slot would fit the mission.
