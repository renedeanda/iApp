---
name: positioning-check
description: Similarity check between a proposed new app's mission and every shipped portfolio app's mission. Flags clashes before the wizard proceeds. Uses keyword overlap + thematic similarity heuristics (Foundation Models if available).
---

# /positioning-check

Catches a common failure mode: a new app idea that overlaps too much with an existing portfolio app's mission. The wizard surfaces the overlap so the user can pivot or proceed deliberately.

## When to use

- During `/new-app --draft` step 4, right after the mission is captured.
- Re-running if the mission is reworded mid-draft.

## When NOT to use

- For inspiration browsing — that's not a clash check, that's reading PORTFOLIO.md.

## How it works

1. Read the proposed mission from `DECISIONS/000-mission.md`.
2. Read every shipped app's mission from `portfolio/PORTFOLIO.md` "At a glance" table.
3. Score similarity per app:
   - **Keyword overlap** — share ≥2 substantive words (excluding stopwords + generic words like "app", "for", "your"). Quick heuristic; runs first.
   - **Thematic similarity** — if available, use on-device Foundation Models to score 0.0–1.0 semantic similarity. Otherwise fall back to keyword-only.
4. Threshold:
   - Keyword overlap ≥2 OR thematic ≥0.75 → **clash flagged**
   - Otherwise → **clear**
5. For each flagged clash, surface:
   - Conflicting app's mission
   - Specific overlap (which words / theme)
   - Pivot suggestion (one sentence on what would differentiate)

## Implementation note

v1 heuristic-only (keyword overlap + thematic-keyword bigrams).
v2: on-device Foundation Models semantic similarity when available, fallback to v1 otherwise. Pattern matches the AI-with-deterministic-fallback rule from CLAUDE.md.

## Forbidden agent behavior

**Never decide for the user whether to proceed past a flagged clash when this skill runs inside `/new-app`.** The math is deterministic; the judgment is not. The agent runs the similarity check and presents the result; the user decides via `AskUserQuestion` whether to proceed, pivot, or abandon.

## Steps with the user

1. Tokenize proposed mission (lowercase, strip stopwords).
2. For each portfolio mission: tokenize, compute keyword overlap.
3. If Foundation Models available: also compute thematic similarity.
4. Print the similarity report:
   ```
   Proposed: "<mission>"

   Clash check:
     Sample Notes  "A warm notes app that respects your time"   — no overlap ✓
     Sample Timer  "A calm 90-second breathing break"           — ⚠️ overlap: "calm" + thematic similarity 0.71 — pivot suggested
     <each app from your PORTFOLIO.md>                          — ...

   N clashes flagged.
   ```

5. **If 0 clashes:** print "Clear — no positioning conflicts" and return. No question needed.

6. **If ≥1 clash: `AskUserQuestion` — Resolution path.**
   - Question: *"Positioning clash with <closest-conflict-app>: shared <words/themes>. How to proceed?"*
   - Options: "Proceed anyway with explicit acknowledgment" / "Pivot the mission to emphasize the differentiator" / "Abandon the idea" / "Show the clash detail again"
   - If "Pivot": follow up with a free-form `AskUserQuestion` capturing the revised mission, re-run the clash check.
   - If "Abandon": the wizard ends gracefully with no ADRs written.
   - If "Proceed": the agent writes the clash + the user's acknowledgment into the working `DECISIONS/000-mission.md` "Options considered" section.

7. The result (clear / pivoted / proceeded-with-acknowledgment) is captured in the mission ADR for future review.

## Cross-references

- [portfolio/PORTFOLIO.md](../../../portfolio/PORTFOLIO.md) — mission column
- [DECISIONS/000-mission.md](../../../DECISIONS/000-mission.md) — captured mission
- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — mission discipline
