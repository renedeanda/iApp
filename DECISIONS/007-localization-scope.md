# ADR 007 — Localization Scope

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** iApp
- **Authors:** iApp maintainers

## Context

Localization decisions made late are expensive. Every UI string baked in English first has to be re-extracted later, with semantic context often lost. The discipline this repo enforces: localize from day 1.

## Decision

**iApp repo: English-only.** Docs, ADRs, CLAUDE.md, recipes — all in English. The audience is developers reading code + docs; localizing docs is a different problem than localizing apps and outside iApp's scope.

**Portfolio-wide tier-1 locale set** (which every child app's template ships with day 1):

```
en  English        (default)
es  Spanish
de  German
fr  French
pt  Portuguese
ja  Japanese
zh-Hans  Chinese (Simplified)
```

That's **7 locales**. Used consistently across CLAUDE.md, PHILOSOPHY.md, HOUSEKEEPING.md, WIDGETS.md, PORTFOLIO.md, REUSE_INDEX.md.

The wizard asks before adding an 8th. One shipped app in the source portfolio carries 15 — that's a deliberate stretch, not the default.

### Child app ADR 007 shape

```markdown
# ADR 007 — Localization Scope

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Decision
Tier-1 locales day 1: en es de fr pt ja zh-Hans (default)
Additions beyond tier-1: <list, with justification>

xcstrings setup:
- Seed/Localizable.xcstrings (app strings)
- Widgets/Resources/Localizable.xcstrings (widget strings — the widget-bundle trap)
- Intents/Localizable.xcstrings (App Intent phrases — the same trap for intents)
- InfoPlist.xcstrings (display name + permission strings)

SWIFT_EMIT_LOC_STRINGS: true in project.yml

Translation workflow:
- /translate skill on each xcstrings file, language-by-language
- LocalizationParityTests verifies every key has a translation per tier-1 locale (or state: stale)
- WidgetLocalizationParityTests verifies widget xcstrings has every widget-surface string
```

## Options considered

- **Just English at launch, localize later** — rejected. A pattern lived through repeatedly: localizing late means re-extracting strings with lost context. Day-1 localization is harder for the first sprint, much cheaper over the app's life.
- **English + Spanish only** — rejected. Tier-1 means broadly tier-1 to App Store reach, not pick-favorites. The 7-locale set covers ~85% of paid App Store revenue worldwide.
- **Localize iApp docs themselves** — rejected. Audience is English-speaking developers. Localizing docs is a different discipline (technical writing translation, glossary management); out of scope.

## Consequences

- **Unlocks:** every template ships with 7-locale xcstrings stubs day 1. `/translate` skill fills them via a managed translation workflow.
- **Forecloses:** zero-locale or English-only apps. Even a single-locale app technically ships the 7 stubs (with English fallback) so adding a locale later is a stub-update, not a re-extraction.
- **Cost to revisit:** small — adding/removing locales from the tier-1 set is a doc update + a template stub update + an entry in RECENT_LEARNINGS.

## Verification

`LocalizationParityTests.swift` (template) checks every key has all 7 tier-1 translations.

`WidgetLocalizationParityTests.swift` (template) catches the widget-bundle trap.

## Addendum — App Store *graphics* localization scope

Distinct from app-UI localization (above). The screenshot-graphics engine
(`tools/app-store-graphics/`) localizes **caption copy** to a **uniform top-8
markets** — `en es fr de pt it ja ko zh-Hans` — for every app, **independent of
that app's UI locale set**. An individual app with a larger set of live markets
can stretch beyond 8 (one app in the source portfolio runs 12).

**Decision:** graphics do **not** mirror each app's full UI locales (which can
run to 30+). App Store screenshots fall back to the primary listing for any
locale without a dedicated set, and the top markets carry the bulk of
conversion — so a uniform top-8 is the right cost/reach point. Both outputs —
the **Studio** and the **Simple** page — carry the same per-app set. Revisiting
a *specific* app upward is cheap: add its locale to `i18n_data.py` and re-run —
a strings add, not a re-architecture.

**Caveat:** the machine-drafted market copy (terminology harvested from each
app's own `locales`) is **flagged for native-speaker review** before submission.

**Layout note:** the Simple page supports per-identity `simpleStyle` layouts
(warm-minimal riding the app's real in-app themes, minimal monochrome with
alternating icon variants, brutalist with a rounded screenshot well,
ink-on-paper, serif editorial); identities without a bespoke layout share the
emoji-caption default.

## Cross-references

- [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md) — the widget l10n trap; App Intents strings load from the intent's bundle
- [tools/app-store-graphics/README.md](../tools/app-store-graphics/README.md) — the graphics engine + per-app coverage
- [docs/WIDGETS.md](../docs/WIDGETS.md) rule 2 — widget extension has its own xcstrings
- [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) — `SWIFT_EMIT_LOC_STRINGS: true` + xcstrings seed
- [docs/APP_STORE_CHECKLIST.md](../docs/APP_STORE_CHECKLIST.md) — privacy permission strings localized
