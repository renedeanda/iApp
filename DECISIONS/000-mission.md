# ADR 000 — Mission

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Kindling exists because every new app in a growing portfolio tends to be hand-forked from whichever neighbor is closest. App B forks from App A, App C forks from App B, App D forks from App C. Drift accumulates. Design rules diverge. The same `SubscriptionManager.swift` ends up existing in four mildly-different versions across the portfolio.

## Decision

**Kindling is the planning hub and thick starter scaffold that every future iOS app idea boots from.**

The mission, in one sentence (14 words max, per CLAUDE.md taste rule 1):

> *"The thick scaffold every new app boots from, with design discipline built in."*

## Options considered

- **Mission as a brand statement** ("Kindling is the iOS app studio's design system.") — rejected: vague, doesn't tell anyone what to cut.
- **Mission as a tech statement** ("Kindling is an XcodeGen + Expo monorepo.") — rejected: describes the *what*, not the *why*. The tech can change; the mission shouldn't.
- **Mission as a feature list** ("Kindling provides templates, ADRs, recipes, and slash commands.") — rejected: that's the architecture, not the mission.

## Consequences

- **Unlocks:** every other ADR in this repo derives from this sentence. Anything that doesn't serve "thick scaffold + design discipline" doesn't ship here.
- **Forecloses:** Kindling is *not* a published library and *not* a multi-tenant tool. It's an opinionated system for building your own portfolio of apps — fork it, make it yours.
- **Cost to revisit:** large. Changing the mission means re-justifying every other ADR.

## Cross-references

- [docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md) — operating principles derived from this mission
- [README.md](../README.md) — public-facing version of the same idea
- [CLAUDE.md](../CLAUDE.md) — taste rules that enforce the mission
