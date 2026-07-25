# DECISIONS/NNN-<slug>.md — Template

> Copy this file to a numbered ADR (`000-mission.md`, `001-tech-choice.md`, etc.) and fill in the sections.

ADRs in this folder are **the receipts for taste choices**. Each one captures what the choice was, what we considered, and why we picked what we picked. Never delete an ADR — supersede it with a later-numbered one if a decision changes.

iApp's own ADRs (000–016 in this folder) are also the **worked examples** every child app starts from. The `/new-app --commit` skill copies the template into each new app's repo with the values substituted.

---

## Required header

```markdown
# ADR NNN — <One-line title>

- **Status:** Accepted | Superseded by NNN | Draft
- **Date:** YYYY-MM-DD
- **App:** <app name> | iApp
- **Authors:** <who decided>
- **Wizard step (if applicable):** /new-app step N — <step name>
```

## Required sections

### Context

What is the situation that demands a decision? Two to four sentences max. Avoid restating the entire codebase; assume the reader has [CLAUDE.md](../CLAUDE.md) loaded.

### Decision

What did we decide? One paragraph. Be specific. "We picked Sage" is not enough — say which exact hex values, which exact specimens, which exact services. If the decision is a *delta* from a catalog seed (palette, typography), describe the delta inline.

### Options considered

The serious candidates and why each lost. At least two alternatives. For each:

- **Option name** — one-line summary
  - Pros: ...
  - Cons: ...
  - Rejected because: ...

If only one option was ever considered, this section reads "We didn't consider alternatives because X" with a defensible X. Don't fake alternatives — fewer ADRs of higher quality is the goal.

### Consequences

What does this decision unlock and what does it foreclose?

- **Unlocks:** ...
- **Forecloses:** ...
- **Cost to revisit:** small / medium / large

If "cost to revisit: large," you're committing the portfolio to this answer for years. Make sure the decision earns it.

### Cross-references

Links to related ADRs, docs, files. Format:

- ADRs: `[ADR 000](000-mission.md)`
- Docs: `[docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md)`
- Portfolio: `[portfolio/PORTFOLIO.md](../portfolio/PORTFOLIO.md)`
- Code (after templates land): `templates/swift/Seed/Theme/AppTheme.swift:42`

---

## Optional sections

Add only when the decision warrants. Don't pad an ADR with empty sections.

### Departure delta *(palette / typography / motion ADRs only)*

When the decision is a *delta* from a catalog seed:

```
Seed: <name>
Delta:
- <one bullet per change from the seed>

Final:
- <token / value pairs>
```

### Verification

How will we know we made the right call? Test that exists, metric tracked, deadline to revisit.

### Open questions

Things deliberately left undecided. Each open question must include a deadline ("decide by YYYY-MM-DD") or a trigger ("decide when we ship X").

### Forbidden patterns

Things ruled out by this decision. Short list, no prose.

---

## What good ADRs look like

- **000-mission.md** — one sentence. Crisp. Tells you what to cut.
- **002-palette.md** — names the seed, shows the delta, shows the final hex tokens.
- **009-signature-motion.md** — one principle, where it fires, what it doesn't apply to.
- **015-visual-identity.md** — pick one of the eight, justify in one sentence.

## What bad ADRs look like

- Multi-page essays. Cut.
- "Pros: it's nice. Cons: maybe not." Cut.
- ADRs that don't actually decide anything ("we'll evaluate further"). Either decide or don't open the ADR yet.
- Three ADRs covering the same decision. Pick the one that's right, mark the others Superseded.
- ADRs without consequences. Every decision forecloses something; if you can't say what, you haven't decided.

## File naming

`NNN-<kebab-slug>.md` where:

- `NNN` is 3 digits, zero-padded. The iApp canonical set is 000–016. Children may add 017+ for app-specific decisions.
- `<kebab-slug>` is short, descriptive, lowercase, hyphen-separated. Aim for ≤4 words.

Never reuse a number. If 002 is superseded, the new ADR is 017 (or later); 002 stays in place with `Status: Superseded by 017`.

## Status lifecycle

- `Draft` — the ADR is being written. The decision isn't binding yet.
- `Accepted` — the decision is in effect.
- `Superseded by NNN` — a later ADR replaces this one. The superseding ADR's "Context" should explain why.
- (No "Rejected" status — if an option is rejected, it lives in the surviving ADR's "Options considered" section, not as its own ADR.)
