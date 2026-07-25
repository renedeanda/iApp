# Run a portfolio accessibility sweep

> **Source:** each app's own a11y scan (the template's `/review` skill, shipped in both templates' `.claude/skills/`, covers the mechanical categories) is the executor; this recipe is the **portfolio-level pattern** — proven in a production sweep across eight shipped apps. Confirm app-side conventions against each app's CLAUDE.md.
> **Platform:** Both (Swift + React Native)
> **Reliability:** ✅ gold-standard — the mechanical fixes below are the same in every app; the conventions are codified in every CLAUDE.md.

## What it adds

A repeatable accessibility pass over a shipping app: VoiceOver labels, button traits, decorative-icon hiding, and reduce-motion gating. Most of it is **mechanical** (deterministic, auto-fixable); a smaller set needs **judgment** (touch targets, what VoiceOver should announce, chart values). This recipe names which is which so a sweep fixes the mechanical 90% fast and flags the judgment 10% for a human, instead of leaving every app's a11y to per-app memory.

## When to use

- Pre-submission readiness pass on an app, or a portfolio-wide sweep before a launch wave.
- After building a feature with new buttons / icon-only controls / animations.
- A `/review` surfaced a11y findings and you want the full mechanical checklist, not a one-off fix.

## When NOT to use

- **Don't auto-add `.accessibilityAddTraits(.isButton)` to a `NavigationLink` or other already-semantic control.** The trait is for `.buttonStyle(.plain)` elements VoiceOver can't infer are buttons. A NavigationLink already announces as a link — adding `.isButton` *fights* its link semantics. Only the plain-styled, gesture-driven controls need the trait.
- **Don't bulk-relabel where the system label is already correct.** Adding a redundant `.accessibilityLabel` to a `Button("Save")` (whose title is already the label) just creates a maintenance liability and can override a good default. Label the *icon-only* and *ambiguous* controls, not every control.
- **Don't treat "no static findings" as done.** Touch-target size, VoiceOver announcement order, and chart `accessibilityValue` are judgment calls the mechanical scan can't see. A clean auto-fix pass is necessary, not sufficient.
- **Don't `.accessibilityHidden(true)` an icon that is the sole conveyor of meaning.** Hiding is for *decorative* SF Symbols beside a text label — never for an icon-only button (that one needs a *label*, not hiding).

## How

### 1. The mechanical checklist (auto-fixable)

**Swift / SwiftUI:**

| Fix | When | Why |
|---|---|---|
| `.accessibilityAddTraits(.isButton)` | on every `.buttonStyle(.plain)` control (that isn't already a link) | plain style strips the button trait; VoiceOver otherwise reads it as static text |
| `.accessibilityLabel("…")` | on **icon-only** buttons (an SF Symbol with no visible title) | VoiceOver has nothing to read otherwise — it announces "button" with no name |
| `.accessibilityHidden(true)` | on **decorative** SF Symbols sitting next to a text label | stops VoiceOver double-reading the glyph + the label |
| `motionSafeAnimation()` (never a bare `.animation()`) | on every hero/signature motion | gates the animation behind Reduce Motion — the portfolio rule |

**React Native:**

| Fix | When | Why |
|---|---|---|
| `accessibilityRole="button"` | on `Pressable`/`TouchableOpacity` acting as a button | gives the element button semantics for the screen reader |
| `accessibilityRole="summary"` | on a grouped data-viz / stat block read as one unit | the reader announces the group as a summary, not N stray numbers |
| `accessibilityState={{ … }}` | on toggles/selected/disabled controls | announces selected/checked/disabled state |
| reduce-motion gate (read the OS reduce-motion flag; pass `null` instead of the animation) | on every animated transition | parity with the Swift `motionSafeAnimation()` rule |

Run each app's own a11y scan (the template's `/review` skill covers these categories) — it scans for the above and auto-fixes the trivial ones, exactly these patterns.

### 2. The judgment list (flag, don't auto-fix)

- **Touch targets** — controls below the 44×44pt minimum. Enlarging changes layout; a human decides.
- **VoiceOver announcement order / custom announcements** — does the screen read in a sensible order? Does a state change need an announcement? Not inferable mechanically.
- **Chart / data-viz `accessibilityValue`** — a heatmap or orbit view needs a spoken value ("5 of 7 days logged"), which is content the scan can't author.
- **Color-only meaning** — state conveyed by color alone (overdue red / drifting amber) needs a non-color cue too.

### 3. Verify

```sh
# Swift — plain buttons that still lack the trait (should be empty after the sweep):
grep -rn "buttonStyle(.plain)" <app>/ -A3 | grep -B3 -L "accessibilityAddTraits"
```

Then **run the app with VoiceOver** (or the RN screen reader) on the changed screens — the mechanical scan is necessary, the live pass is what catches the judgment items.

Expected: every plain button reads with a name + "button"; decorative glyphs are silent; animations respect Reduce Motion; grouped stats read as one summary.

## Gotchas

- **`.buttonStyle(.plain)` + label vs. trait is a common mix-up.** Icon-only button → needs a **label**. Plain-styled button that VoiceOver thinks is text → needs the **trait**. Many controls need both.
- **The per-app skill is the executor; this recipe is the map.** Don't re-implement the scan here — point each app at its own a11y scan skill, which already knows that app's component conventions.
- **RN `accessibilityRole="summary"` is the one most teams miss** — a stat row of three numbers reads as three disconnected announcements without it.
