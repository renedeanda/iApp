# ADR 006 — Naming and Bundle ID

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

The name **Kindling** breaks one of the NAMING.md rules ("no engineering flavor — avoid `i*` prefix"). This ADR is the explicit override + the worked example for child apps.

## Decision

**Product name:** Kindling
**Source repo:** `<owner>/Kindling`
**Bundle ID:** N/A — Kindling is not an App Store product

### Why the rule override

NAMING.md rule 3 ("no engineering flavor") explicitly rejects `i*`-prefixed literal names for products. So why does Kindling get a pass?

Because Kindling **isn't a product, it's infrastructure for developers**. The audience reading "Kindling" is the same developer who reads `git`, `npm`, `xcodegen`, `swiftlint` — names that *are* engineering-flavored and that's correct for their audience. NAMING.md rule 7 (the rename precedent) applies when "the app earns a product positioning"; Kindling is never going to earn a non-developer product positioning.

The `i*` prefix specifically signals "iOS dev tool" here, which is honest.

If this rationale ever stops applying (Kindling becomes a published product targeting non-developers), the rename precedent kicks in: keep the repo name, pick a new product name.

### Child app ADR 006 shape

```markdown
# ADR 006 — Naming and Bundle ID

- Status: Accepted
- Date: YYYY-MM-DD
- App: <product name>

## Decision
Product name: <Name>
Source repo: <owner>/<reponame>
Bundle ID: com.example.<name>
App Group: group.com.example.<name>
iCloud container: iCloud.com.example.<name>
Widget bundle: com.example.<name>.widgets

## Validation (run by /new-app wizard)
- Syllables: <1-2>
- English-readable in es de fr pt ja zh-Hans: ✓
- No engineering flavor: ✓ (or: ✗ — override justified below)
- App Store category clear: ✓
- <name>.app domain available: ✓
- Bundle ID com.example.<name> claimable: ✓
- No clash with claimed portfolio names: ✓

## Override (if any rule fails)
<one paragraph justifying why the failed rules are acceptable for this app,
e.g. "the two-word conversational name is core to the mission">
```

## Options considered

- **Rename Kindling to something neutral** ("Lattice", "Marrow", "Vellum") — rejected. Would lose the "this is iOS dev infra" signal. The repo URL is the most-used reference; renaming makes incoming links break.
- **Keep the repo private** — rejected. MIT license + public repo is the value (per ADR 003).
- **Accept the rule violation silently** (no override ADR) — rejected. Rules without exceptions become folklore; rules with documented exceptions are infrastructure.

## Consequences

- **Unlocks:** any future infrastructure repo in your portfolio can use the same precedent (engineering-flavored is fine when the audience *is* engineers).
- **Forecloses:** if Kindling ever pivots to a product for non-developers, this ADR gets superseded and the rename precedent kicks in.
- **Cost to revisit:** small.

## Cross-references

- [docs/NAMING.md](../docs/NAMING.md) — full naming rules, especially rule 7 (the rename precedent)
- [portfolio/PORTFOLIO.md](../portfolio/PORTFOLIO.md) — claimed names/bundle ids table
