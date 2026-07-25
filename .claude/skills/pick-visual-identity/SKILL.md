---
name: pick-visual-identity
description: Pick one of the eight canonical visual identities for the new app. Considers per-app fit (mission) and portfolio-wide diversity (current distribution). Cascades into palette/typography/motion filtering. Writes DECISIONS/015-visual-identity.md.
---

# /pick-visual-identity

Identity is a **portfolio-strategy decision** parallel to monetization (per [DECISIONS/015](../../../DECISIONS/015-visual-identity.md)). Mission-fit + portfolio-mix both inform the pick.

## When to use

- During `/new-app --draft` step 6, after the mission and anti-list are written.
- Re-deriving identity if the mission shifts substantially mid-draft.

## When NOT to use

- For an existing app's visual evolution — that's an ADR addendum.

## The eight canonical identities

(Per [docs/VISUAL_IDENTITIES.md](../../../docs/VISUAL_IDENTITIES.md).)

| Identity | Your portfolio |
|---|---|
| **Brutalist** | (open slot) |
| **Glassmorphic** | (open slot) |
| **Warm-minimal** *(template default)* | (open slot) |
| **Typographic-led** | (open slot) |
| **Hand-drawn** | (open slot) |
| **Maximalist-collage** | (open slot) |
| **Kinetic-type** | (open slot) |
| **Monochrome-luxe** | (open slot) |

Every slot starts open — as you ship, fill this column from your own PORTFOLIO.md so the diversity math has real data. Plus a **Hybrid** option (e.g., a warm-minimal body + glassmorphic chrome) requiring an addendum, and a **Ninth-identity** path requiring a PR to VISUAL_IDENTITIES.md citing a shipped portfolio app as proof.

## Forbidden anti-identities (rejected up-front)

- Skeuomorphic (leather, fake wood)
- Neumorphism
- Generic Material Design on iOS
- Dark-mode-only as identity

## Forbidden agent behavior

**Never pick the visual identity on the user's behalf when this skill runs inside `/new-app`.** Even when the mission + portfolio mix produce a single obvious answer, the user picks via `AskUserQuestion`. The agent's job is to filter and recommend; the user's job is to commit.

## Steps with the user

1. Read the mission (`DECISIONS/000-mission.md`), anti-list (`013-anti-list.md`), and spec (`016-spec.md`).
2. Read current portfolio identity distribution from PORTFOLIO.md (fall back to the snapshot in [DECISIONS/015](../../../DECISIONS/015-visual-identity.md)).
3. Filter the 8 canonical identities by mission-fit. Compute the current portfolio mix.

4. **`AskUserQuestion` — Identity pick.**
   - Question: *"Pick the visual identity. Mission-fit and portfolio diversity shown per option. Recommended: <X> because <reason>."*
   - Options: up to 4 options chosen from the 8 canonical + (if relevant) Hybrid:
     - Top recommendation first, label includes "(Recommended)"
     - 2–3 strong alternatives, each labeled with mission-fit + portfolio status (e.g., "fills open slot" or "would push warm-minimal to 3/7")
     - Anti-identities are NOT presented as options — they're filtered out per the Forbidden Anti-Identities section
   - Each option's `description` includes: portfolio status, one-line mission-fit rationale, and downstream implication (e.g., "Cascades to monochrome/serif palettes only").

5. If user picks "Other" and proposes a 9th identity: require a PR to VISUAL_IDENTITIES.md citing a shipped portfolio app as proof. Wizard refuses to proceed without that prerequisite — surface the requirement and ask to fall back to an existing identity.

6. **`AskUserQuestion` — One-sentence rationale.**
   - Question: *"In one sentence, why this identity for this app's mission? (Free-form via Other; 2 example chips seed thinking.)"*
   - Options: 2 example sentences drawn from your prior apps' 015 ADRs (or generic examples if the portfolio is empty) + "Other" for free-form.

7. Write `DECISIONS/015-visual-identity.md`:
   - Chosen identity
   - User's one-sentence why
   - Downstream implications (which palette seeds + typography specimens + signature motions become available/unavailable)
   - Trade-off acknowledged (if mission supported an open-slot alternative that wasn't picked)

8. Cascade: `/pick-palette`, `/pick-typography`, `/pick-signature-motion` all read this ADR to filter their options.

## Cross-references

- [docs/VISUAL_IDENTITIES.md](../../../docs/VISUAL_IDENTITIES.md) — full identity catalog
- [DECISIONS/015-visual-identity.md](../../../DECISIONS/015-visual-identity.md) — portfolio diversity logic
- [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md) — parallel diversification framework
- [portfolio/PORTFOLIO.md](../../../portfolio/PORTFOLIO.md) — current identity distribution
- [CLAUDE.md](../../../CLAUDE.md) taste rule 4 — novelty is a feature
