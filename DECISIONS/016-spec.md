# ADR 016 — Spec

- **Status:** Accepted
- **Date:** 2026-05-19
- **App:** iApp
- **Authors:** iApp maintainers
- **Wizard step:** /new-app step 0 — Spec intake

> iApp's own spec, written retroactively as the worked example child apps copy from. The numbered ADRs 000–015 were drafted before this template existed; 016 is the front-door spec the wizard will elicit *first* for every future app. For iApp itself, the answers are derived from [README.md](../README.md), [000-mission.md](000-mission.md), and [013-anti-list.md](013-anti-list.md).

## 1. Problem

Every new app in a growing portfolio has historically been hand-forked from whichever neighbor was closest. Drift accumulated: the same `SubscriptionManager.swift` ends up in four mildly-different versions across a portfolio, design rules diverge, and the gold-standard pattern for each feature (widgets, Live Activities, haptics, App Intents) becomes hard to locate when starting the next app. The cost of starting *well* keeps rising.

## 2. Target user

The maintainer of a personal app portfolio — and any collaborator — who walks a new app idea from sentence-on-a-napkin to pushed scaffold. Specifically: someone who has (or is building) a design taste for their portfolio and wants the *next* app to inherit that taste without re-deriving it.

## 3. The 3 JTBDs

```
When I have a new iOS app idea worth building,
I want to walk it through 21 design-first checkpoints before I write a line of code,
so I commit to its identity (mission, palette, motion, anti-list) deliberately rather than by accident.
```

```
When I'm about to harvest a service (CloudKit, StoreKit, App Intents) from an existing app,
I want to be told which source is gold-standard for that capability and which is WIP,
so I don't repeat a shipped bug like the widget-localization bundle trap.
```

```
When I finish drafting a new app's 17 ADRs at midnight,
I want the wizard to refuse to render templates until I've slept on it,
so the irreversible decisions (palette claim, repo creation, portfolio PR) survive a night of reconsideration.
```

## 4. Success signal

Within six months of adopting the wizard: at least two apps have shipped via the wizard from `/new-app --draft` to App Store submission with their full 17-ADR set intact, and at least one shipped lesson has flowed back into `templates/` via `/sync-from-portfolio`. If neither happens, the wizard isn't earning its weight and the question becomes whether to keep iterating or fold it back into per-app cloning.

## 5. Out-of-scope

- **Not a SaaS.** No backend, no signup, no per-user state. Repeated from 013 because the temptation to add "the wizard remembers you" recurs every few months — it stays out.
- **Not multi-tenant.** iApp is one portfolio's brain at a time. Fork it and make it yours; it isn't *built* to serve N portfolios from one instance.
- **No web UI.** Slash commands and ADRs only. The day there's a "wizard frontend" is the day it stops being AI-first.
- **No telemetry on the wizard itself.** Child apps ship TelemetryDeck; iApp does not phone home. The maintainer reads the git log to understand usage.
- **No supporting third-party AI APIs.** Foundation Models for the on-device gating pattern, Claude as the wizard runner. No OpenAI/Cohere/etc. — anti-vendor-sprawl.

## 6. Anti-vision

iApp is **not** a published library-with-a-release-cycle, **not** a SaaS, **not** a multi-tenant parameterized template, and **not** something with a marketing site. The drift mode to fear: seeing the wizard work end-to-end and thinking "let's add a CLI installer, a docs site, a Discord." The day iApp has a Discord is the day it has stopped serving the work and started serving an audience. The mission is the portfolio. The MIT license and public repo are for honesty and reuse — fork it, don't wait for a roadmap.

## Cross-references

- [TEMPLATE-spec.md](TEMPLATE-spec.md) — the shape this ADR follows
- [000-mission.md](000-mission.md) — the one-sentence distillation of fields 1+2
- [013-anti-list.md](013-anti-list.md) — the ethical/taste rejections, paired with field 6
- [005-launch-readiness.md](005-launch-readiness.md) — measures against field 4
- [README.md](../README.md) — public-facing version of the same spec, in marketing voice
- [portfolio/PORTFOLIO.md](../portfolio/PORTFOLIO.md) — where the apps the wizard produces get recorded
