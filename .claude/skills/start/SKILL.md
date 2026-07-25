---
name: start
description: The front door for a fresh session. Greets the user, asks their experience level and whether they have an app idea yet, then routes them — novice → the first-app tutorial, idea-ready → /new-app --draft, feature-adder → recipes, shipper → release skills. Use when a user seems new to the repo, asks "where do I start?", or invokes /start.
---

# /start

The concierge. Kindling serves everyone from "never opened Xcode" to "shipping my ninth app" — this skill's job is to find out who's here and hand them the right next step, without overwhelming them with the whole repo at once.

## When to use

- A fresh session where the user hasn't stated a goal, or greets you with some form of "help me build an iOS app."
- The user explicitly runs `/start` or asks "where do I begin?"

## When NOT to use

- The user arrived with a specific request ("add widgets", "review my palette") — just do that.
- Mid-wizard — `/new-app` owns its own flow.

## Steps

1. **Read the room first.** Check for signals before asking anything: does `drafts/` contain a draft app? Does `portfolio/PORTFOLIO.md` have real entries? Is this a rendered child app rather than the Kindling hub? If a draft exists, offer to resume it (`/new-app --commit <name>` if slept-on) instead of starting over.

2. **Ask, using `AskUserQuestion`** (one question, four options — this is the contract, don't infer silently):

   > "Welcome to Kindling. What best describes you right now?"
   >
   > - **New to iOS development** — "I want to learn by building."
   > - **I have an app idea** — "I know roughly what I want to build."
   > - **I have an app already** — "I want to add a feature or improve quality."
   > - **I'm ready to ship** — "Help me get to the App Store."

3. **Route.**

   **New to iOS →** Walk them through [docs/FIRST_APP_TUTORIAL.md](../../../docs/FIRST_APP_TUTORIAL.md) *interactively*: run the commands for them where possible, explain each artifact as it appears, and decode terms via [docs/GLOSSARY.md](../../../docs/GLOSSARY.md) as they come up rather than up front. Pace: one part per session-chunk; celebrate the first successful ⌘R. When the template runs, ask if an idea is forming — if yes, graduate them to the idea path.

   **Idea-ready →** First confirm the two-repo layout from [docs/YOUR_OWN_REPO.md](../../../docs/YOUR_OWN_REPO.md) — the user should create a blank **private** repo for their app and clone it beside Kindling before `--commit` day (help them do it now if they haven't). Then give a two-sentence preview of the deal ("21 design questions before any tech choice; you sleep on it before code renders — that's deliberate") and hand off to [`/new-app --draft`](../new-app/SKILL.md). If they arrive with a filled [docs/BRING_YOUR_IDEA.md](../../../docs/BRING_YOUR_IDEA.md) worksheet, treat it as context that speeds the wizard — but still ask every wizard question; the worksheet informs answers, it doesn't replace them. If they mention existing designs or mockups, walk them through the export step in [docs/BRING_YOUR_MOCKUPS.md](../../../docs/BRING_YOUR_MOCKUPS.md) *before* entering the wizard, so the images are in `drafts/<app-name>/mockups/` when the design steps need them. Do not pre-answer any wizard question for them.

   **Feature-adder →** Ask what feature; find the matching recipe in [recipes/](../../../recipes/) and read them its "When NOT to use" section *before* implementing. If the feature lives in `Services/_Disabled/`, follow the enable ritual. If no recipe fits, check [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md).

   **Shipper →** Sequence: `/review` (quality pass) → [docs/APP_STORE_CHECKLIST.md](../../../docs/APP_STORE_CHECKLIST.md) → `/analytics-audit` if analytics are wired → `/apple-app-review` for the pre-submission audit → `tools/app-store-graphics/` for screenshots → `/app-store-aso` for listing copy.

4. **Always end with one concrete next action**, not a menu. The user should leave the exchange knowing exactly what happens next and who does it (them or you).

## Tone

Encouraging, concrete, zero gatekeeping. Novices get plain language and small wins; experts get out of their way. Never dump the full repo map on a beginner — the tutorial reveals structure as it's needed.

## Cross-references

- [docs/FIRST_APP_TUTORIAL.md](../../../docs/FIRST_APP_TUTORIAL.md) — the novice path this skill narrates
- [docs/GLOSSARY.md](../../../docs/GLOSSARY.md) — decode jargon on demand
- [new-app/SKILL.md](../new-app/SKILL.md) — the wizard this skill feeds
- [CLAUDE.md](../../../CLAUDE.md) — the constitution (agents read it regardless of route)
