# Naming

Naming is the first taste decision. The wizard's `/new-app` step 3 validates against these rules before any tech is chosen.

## Rules

### 1. One or two syllables, evocative

Names that pass: Drift, Cinder, Vellum, Haven, Marrow, Lumen. Three syllables can work when a contraction reads naturally.

Names that would not pass: *Daily Habit Helper* (three words, conversational tone — could be earned, but it's not a model), *iHabitTracker*-style names (engineering-flavored; see rule 3).

### 2. English-readable across tier-1 locales

The name must survive `es de fr pt ja zh-Hans` without becoming a pronunciation joke, a slur, or a brand collision. Quick checks:

- Google search the name in each language — page-1 results should be neutral or empty, not a competing product / unfortunate meaning.
- Type the name into Google Translate from English → each tier-1 → and back. Stable round-trip is good. Wild swings are a flag.
- Search the App Store in each storefront. Direct collisions kill the name.

### 3. No engineering flavor

❌ Bad: `TaskMaster`, `NoteKeeper`, `HabitTracker`, `BudgetBuddy`, anything with an `i` prefix + literal function. Pattern: literal+suffix. Reads as a tool, not a product.

✅ Good: Drift, Cinder, Marrow, Vellum, Haven. Pattern: a noun that *evokes* the mission, not one that describes the mechanism.

### 4. Domain-available, ASC-claimable, App Store-distinct

Before committing the name:

- `<name>.app` available, or `<name>app.com` at least.
- App Store Connect lets you reserve the bundle id `com.example.<name>` (substitute your own org prefix).
- Apple's app-name search returns nothing within the same category.
- Social handles available on at least one of: X, Threads, Bluesky.

### 5. Bundle-id rules

Pick one org prefix for your whole portfolio and never deviate (examples below use `com.example`):

- Always `com.example.<name>` — single org prefix for the portfolio.
- App Group: `group.com.example.<name>`.
- iCloud container: `iCloud.com.example.<name>`.
- Widget bundle: `com.example.<name>.widgets`.
- Intent extension (if used): `com.example.<name>.intents`.

The wizard's `scripts/rename-template.sh` substitutes all four atomically.

### 6. Capitalization

- Product name: title-case (Drift, Cinder, Vellum).
- Source repo: lowercase (`<owner>/drift`, `<owner>/cinder`).
- Bundle id: lowercase.
- Internal Swift identifiers: `DriftApp`, `CinderApp`, etc.

### 7. The rename precedent

Sometimes an app outgrows its name: it starts as a literal utility (`iTimerPro`) and evolves into a product with an emotional positioning that deserves a real name (`Drift`). Two lessons from apps that made this move in production:

| Situation | Rule |
|---|---|
| Product outgrows a literal-utility name | Rename the *product*. A name that reads as a developer tool is wrong once the app has a mission and an identity. |
| Repo carries the legacy name | **Repo name stays.** Renaming a GitHub repo breaks more than it fixes (incoming links, contributor history, CI hooks). |

In every such case:

- **Product name wins everywhere else.** [portfolio/PORTFOLIO.md](../portfolio/PORTFOLIO.md), `CLAUDE.md`, every recipe citation, every doc reference uses the product name.
- **Shorthand `repo:path` references in recipes use the repo name** because that matches the actual file system path. The product name appears in prose; the repo name appears in citations.

If one of your apps earns a similar promotion — from utility to product — apply the same precedent, and record it in your `PORTFOLIO.md`.

## How `/new-app` validates

```
$ /new-app --draft

> Mission (one sentence, ≤14 words):
A calm horizon for your day.

> Proposed name:
Drift

> Validating...
✓ Syllables: 1
✓ English-readable in es de fr pt ja zh-Hans
✓ No engineering flavor
✓ App Store category clear
✓ <name>.app domain available
✓ Bundle id com.example.drift claimable
✓ No clash with claimed portfolio names

Writing DECISIONS/006-naming-and-bundle-id.md...
```

A failure on any check surfaces immediately:

```
✗ Syllables: 4 (rule: 1–2)
✗ Engineering flavor: starts with "i" prefix (rule: avoid)

Suggestion: Drift, Cinder, Vellum, Haven, Marrow, Lumen.
Try another name, or override with `--allow-name-rules` (writes an ADR addendum).
```

## When to override

The rules are guidelines earned from shipped apps. If a name genuinely fits the mission and breaks a rule, the override path exists. Write the ADR addendum justifying it — a warm two-word name for a family-care app is exactly the kind of override that can be earned, not modeled.
