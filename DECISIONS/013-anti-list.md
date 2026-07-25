# ADR 013 — Anti-List

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Per CLAUDE.md taste rule 7: NOT_FOR.md rejects **manipulative implementations**, not engagement itself. WHATS_ALLOWED.md describes the positive framings. Both are portfolio-wide. This ADR is each app's **specific** anti-list — the 3-5 things THIS app refuses to be, beyond the portfolio-wide rejections.

## Decision

**Kindling's anti-list (what this repo refuses to be):**

1. **Not a SaaS.** No backend, no signup, no per-user state. The git repo is the state. (See ADR 003, ADR 008.)
2. **Not multi-tenant.** Kindling is a brain for *one* portfolio at a time — yours. Fork it and make it your own; it isn't built to serve N portfolios from one instance.
3. **Not a public-product-style starter.** No "deploy to Vercel" button, no auto-generated landing page, no "share your app idea with Twitter" feature. The wizard is for the developer's own use first.
4. **Not a comprehensive iOS template.** Opinions are encoded — no AdMob, no infinite scroll, no shame-driven streaks (NOT_FOR.md). Developers who want those need a different template.
5. **Not finished.** Kindling evolves with each new app in your portfolio via `/sync-from-portfolio`. The current state is always a snapshot.

### Child app ADR 013 shape

```markdown
# ADR 013 — Anti-List

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## What this app refuses to be (3-5 entries)

1. **Not <X>.** <one sentence explaining the rejection. Specific. Not generic ("not a bad app" doesn't count).>
2. **Not <Y>.** ...
3. **Not <Z>.** ...

## Inherits from portfolio-wide NOT_FOR.md

All 12 anti-patterns apply (see docs/NOT_FOR.md):
- Shame-driven streaks
- Infinite scroll for attention extraction
- Dark-pattern paywalls
- Ad-mediated monetization
- Engagement-maximizing notifications
- Social graphs / leaderboards
- Tracking + ad-targeting identifiers
- Dark-pattern review prompts
- Forced onboarding metadata
- Notification spam disguised as features
- Auto-renewing subscriptions without proportional value
- Hidden data sharing

## Per-app overrides (rare)

If THIS app deliberately deviates from a portfolio anti-pattern (e.g., a leaderboard
that genuinely serves the mission), write the override here:

- Anti-pattern: <name from NOT_FOR.md>
- Why this app overrides: <one paragraph>
- Mitigations: <list>
- Reviewer: <who signed off>

Most apps will have ZERO overrides. The wizard refuses to write the override
without explicit user confirmation.

## What this app embraces (cross-check WHATS_ALLOWED.md)

For each portfolio anti-pattern, confirm the positive framing this app uses:
- Engagement: <calendar-style reminders for explicit user intent>
- Milestones: <internal-only celebration, not public>
- Notifications: <deferred permission ask tied to concrete user action>
- (etc., per WHATS_ALLOWED.md sections)
```

## Options considered

For Kindling itself:

- **Skip this ADR for Kindling** — rejected. The ADR isn't optional in the child-app sequence, and writing Kindling's own version (anti-SaaS, anti-multi-tenant, anti-generic-starter) forces useful framing for what Kindling is *deliberately not*.
- **Combine 013 with 000 (mission)** — rejected. Mission says what an app IS in one sentence; anti-list says what it ISN'T in 3-5 bullets. Different scopes, different reviews.

## Consequences

- **Unlocks:** every child app writes a specific anti-list. Wizard's `/new-app` step 5 reads NOT_FOR + WHATS_ALLOWED to pre-load defaults; user adds 3-5 app-specific anti-patterns.
- **Forecloses:** vague anti-lists. ("Not bad" / "Not boring" / "Not slow" don't count.) The wizard rejects them.
- **Cost to revisit:** small.

## Cross-references

- [docs/NOT_FOR.md](../docs/NOT_FOR.md) — portfolio-wide anti-patterns
- [docs/WHATS_ALLOWED.md](../docs/WHATS_ALLOWED.md) — positive framings of the same mechanics
- [CLAUDE.md](../CLAUDE.md) taste rule 7 — read both before refusing
- ADR 000 (mission) — what this app IS, paired with what it ISN'T
