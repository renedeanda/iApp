# ADR 010 — First Sixty Seconds

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

The first sixty seconds of an app determine retention more than any feature that comes after. A new user's experience between "tap launch icon" and "I get what this is" is the product. Every app's mission has to be felt in that window.

Kindling has no first-launch experience (it's a docs repo). But child apps absolutely need this ADR, and it has to be written *before* tech is picked — because the felt-quality of those 60 seconds shapes what the app *is*, not what framework renders it.

## Decision

**Kindling's "first sixty seconds" equivalent is the first sixty seconds of a developer landing on the GitHub repo.** That experience:

- Second 0-5: README.md hero — "The thick scaffold every new app boots from, with design discipline built in"
- Second 5-15: Quick tour tree → reader sees PORTFOLIO/DECISIONS/recipes/templates/.claude/docs and can navigate
- Second 15-30: "What makes it different" bullets convey opinion + restraint
- Second 30-45: Either CLAUDE.md or the templates themselves
- Second 45-60: Reader knows whether to fork, contribute, or move on

That's the developer's onboarding to Kindling. No surprises. README.md is calibrated for it.

For child apps, this ADR is the screen-by-screen narration:

### Child app ADR 010 shape

```markdown
# ADR 010 — First Sixty Seconds

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Decision

Frame-by-frame narration:

00:00 — Launch icon tapped
00:00.6 — Launch screen renders (palette wash + optional logo fade per HOUSEKEEPING three launch styles)
00:00.8 — Launch screen dismisses, App.swift onAppear fires
00:01.0 — <first visible screen content>

00:05 — User has done <first interactive thing>
00:15 — User has experienced <core moment of the mission>
00:30 — User has reached <natural pause point>
00:60 — User <retains the app | bounces | engages with onboarding>

## Onboarding decisions

- Permission asks: which, when, why
- Sign-in: required? Optional? Not at all?
- Empty state: what does the user see before they have any data?
- First "win" moment: what is it, how soon does it fire?

## Constraints

- The mission (ADR 000) must be felt by 00:30 or the mission isn't really the mission
- No required metadata collection (per NOT_FOR §9)
- Notification permission deferred until there's a concrete trigger (per WHATS_ALLOWED)
- Reduce Motion + Dark Mode both tested first-launch
```

## Options considered

For Kindling's own first-sixty-seconds:

- **Polish a GitHub Pages / marketing site instead** — rejected for now. Kindling's audience lands on GitHub, not on a marketing site. README does the work.
- **A getting-started GIF / video at the top of README** — rejected. The "60 seconds" here is reading, not watching. Static, fast, indexable.
- **Skip this ADR for Kindling (it has no first-launch)** — rejected. The ADR isn't optional in the child-app sequence, and writing Kindling's own version forced a useful framing (the developer's first 60 seconds on the GitHub page).

## Consequences

- **Unlocks:** every child app commits to a felt-quality target before writing any code.
- **Forecloses:** apps where first-launch is "show splash, navigate to home, present empty state." That's not a designed experience; it's a default. The ADR forces opinion.
- **Cost to revisit:** small per-app (one ADR rewrite, possibly triggers UI changes if onboarding shifts).

## Cross-references

- [README.md](../README.md) — Kindling's actual "first 60 seconds" surface
- [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) — three launch styles (Soft / Instant / Plain)
- [docs/NOT_FOR.md](../docs/NOT_FOR.md) §9 — forced onboarding metadata
- [docs/WHATS_ALLOWED.md](../docs/WHATS_ALLOWED.md) — notification permission timing
- ADR 000 (mission) — what must be felt in the 60 seconds
- ADR 009 (signature motion) — how transitions feel during those 60 seconds
