---
name: new-app
description: The main wizard — walk a new app idea from spec/JTBD intake through 21 design-first steps to a pushed scaffold. Two-phase flow with mandatory overnight pause between draft and commit. Use --draft to capture decisions; --commit to render templates after sleeping on it.
---

# /new-app

The orchestrator. Walks the user through **21 design-first steps** — starting with a structured spec/JTBD intake (step 0, the front door), then all six CLAUDE.md taste-rule-3 checkpoints (mission → visual identity → signature motion → first-sixty-seconds → delight moments → icon SVG seed) plus the supporting decisions — that culminate in a new portfolio app. The wizard refuses to push code in a single session. Sleep-required is structural.

## When to use

- Starting a new portfolio app idea.
- Resuming a draft from yesterday with `/new-app --commit <name>`.

## When NOT to use

- Adding a feature to an existing app — use the relevant recipe instead.
- Hypothesizing without intent to build — write a one-paragraph thought, don't run the wizard.
- Building a one-off outside your portfolio conventions — iApp is opinionated for a coherent portfolio; a throwaway prototype doesn't need the full wizard.

## Usage

```
/new-app --draft              # interactive: pick a name, walk the 21 steps, write ADRs locally
/new-app --commit <app-name>  # after sleeping: render templates, create GitHub repo, push, open back-PR
```

## Agent discipline — non-negotiable

An earlier version of this wizard failed at the interactive UX because the agent drove every decision silently and wrote ADRs from inferred content. **Do not repeat that.**

- For **every user-facing design choice** in any step below — mission, name, palette seed, identity, motion, typography, haptics, tech, monetization, native features, delight moments, anti-list, locales, JTBDs, success signal, anti-vision — **invoke `AskUserQuestion`**.
- Mechanical work (hex derivation, ΔE2000 math, AAA contrast checks, specimen file moves, locale lists, haptic validation) is agent-derived but **shown back to the user** for confirmation before being written to an ADR.
- **Forbidden:** picking an option on the user's behalf "because it's a sensible default." If the answer is not in the conversation, the agent asks. If the user says "you pick," the agent presents 2–3 ranked candidates with one-line rationales and asks which.
- **Forbidden:** writing ADR content the user did not approve. Synthesis (e.g., deriving a draft mission from the spec) is allowed; the user confirms or edits before the ADR is written to disk.

The same discipline binds the pick-* skills the wizard delegates to.

## Phase A — Design-first (`/new-app --draft`)

Writes 17 ADRs (000–016) into `drafts/<app-name>/DECISIONS/` + a `seed-icon.svg`. **Does not push code.** Strict step order — spec precedes mission, mission and visual identity precede tech.

### The 21 steps

0. **Spec / JTBD intake** *(front door — new in v2)* — `AskUserQuestion`-driven, six fields per [DECISIONS/TEMPLATE-spec.md](../../../DECISIONS/TEMPLATE-spec.md):
   1. Problem (free-form via "Other" with 2 example chips)
   2. Target user (free-form via "Other" with 2 example chips)
   3. JTBD #1 — three sequential free-form questions, each in `When ___, I want to ___, so I ___` canonical form, with one example chip per slot to seed thinking
   4. JTBD #2 — same shape
   5. JTBD #3 — same shape
   6. Success signal (free-form via "Other" with 2 example chips)
   7. Out-of-scope — multiSelect from 4–6 plausible-for-this-domain bullets plus user adds via "Other"
   8. Anti-vision (free-form via "Other" with 2 example chips that name a realistic drift mode)

   Writes `DECISIONS/016-spec.md`.

   **Ambition check (part of step 0, before synthesis):** classify the idea's rung on the ladder in [docs/AMBITIOUS_APPS.md](../../../docs/AMBITIOUS_APPS.md) — solo → device-sync → invited-people sharing → Game Center-style competition → SharePlay → strangers/feeds. If the JTBDs imply *strangers seeing each other's content* (rung 6), the wizard must, via `AskUserQuestion`: (a) surface the guide's overhead list (accounts + in-app deletion, hosting bills that scale with success, UGC moderation, data-controller obligations, ops), and (b) ask **the downgrade question** — "does the promise survive with invited-people-only?" If the user confirms rung 6, the backend choice, modeled cost at 1k/10k MAU, account-deletion plan, and moderation plan are captured later in `DECISIONS/008-data-model-and-sync.md`, and `DECISIONS/003-monetization.md` must justify how the bill gets paid (Tier 3 pressure). Rungs 1–5 proceed normally — note the rung in `016-spec.md`.

   **Synthesis (before writing 016 to disk):** the wizard surfaces a draft `000-mission.md` sentence (≤14 words) derived from fields 1+2, and a draft `013-anti-list.md` of 3–5 entries derived from field 6 + portfolio-wide `docs/NOT_FOR.md`. User confirms or edits each via `AskUserQuestion`. These synthesized drafts are written to disk *after* user confirmation as part of steps 2 and 5 below (no re-elicitation — the synthesized drafts become the defaults the user can override).

1. **Pre-flight** — read `portfolio/PORTFOLIO.md` + `REUSE_INDEX.md` + `docs/NOT_FOR.md` + `docs/NAMING.md`.
2. **Mission** — confirm or edit the step-0 synthesized mission. One sentence, ≤14 words. Writes `DECISIONS/000-mission.md`.
3. **Naming check** — validate proposed name against `docs/NAMING.md` rules. Writes `DECISIONS/006-naming-and-bundle-id.md`.
4. **Positioning check** — runs `/positioning-check` skill against `PORTFOLIO.md` mission column. Flag clashes.
5. **Anti-list** — confirm or edit the step-0 synthesized anti-list. Cross-reference with `docs/NOT_FOR.md` + `docs/WHATS_ALLOWED.md`. Writes `DECISIONS/013-anti-list.md`.
6. **Visual identity** — runs `/pick-visual-identity` skill. Writes `DECISIONS/015-visual-identity.md`.
7. **Palette** — runs `/pick-palette` skill (3 seed proposals filtered by identity, ΔE2000 check, departure delta). Writes `DECISIONS/002-palette.md`.
8. **Icon** — runs `/design-icon` skill against identity + palette. Stores `seed-icon.svg`.
9. **Signature motion** — runs `/pick-signature-motion` skill (claimed motions removed from options). Writes `DECISIONS/009-signature-motion.md`.
10. **Delight moments** — runs `/pick-delight-moments` skill (reads `docs/DELIGHT_REEL.md`, user picks 3–5). Writes `DECISIONS/014-delight-moments.md`.
11. **First sixty seconds** — frame-by-frame narration. Writes `DECISIONS/010-first-sixty-seconds.md`.
12. **Typography** — runs `/pick-typography` skill. Writes `DECISIONS/011-typography.md`.
13. **Haptic vocabulary** — runs `/pick-haptic-vocabulary` skill (3 from the 24-pattern catalog). Writes `DECISIONS/012-haptic-vocabulary.md`.
14. **Sound** — yes/no on SoundService. Logged in `DECISIONS/004-native-feature-checklist.md`.
15. **Tech** — runs `/pick-tech` skill (Swift vs RN + Universal Purchase). Writes `DECISIONS/001-tech-choice.md`.
16. **Monetization** — runs `/pick-monetization` skill (5-tier pre-positioning + portfolio-mix check). Writes `DECISIONS/003-monetization.md`.
17. **Feature toggles + reliability check** — runs `/reliability-check` skill per enabled native feature. Writes `DECISIONS/004-native-feature-checklist.md`. **If analytics (TelemetryDeck) or monetization is enabled**, record the app's **App Store Connect App Privacy** answer here too: a TelemetryDeck app declares **Usage Data → Product Interaction**, *not linked / not tracking*, purpose Analytics, `NSPrivacyTracking=false`; a zero-analytics app declares **Data Not Collected**. Pointer only — the standard + the exact ASC steps live in [recipes/swift/app-privacy-declaration.md](../../../recipes/swift/app-privacy-declaration.md). This makes the submission obligation inherited at scaffold time, not discovered on submission day.
18. **Locales** — tier-1 default `en es de fr pt ja zh-Hans`. Writes `DECISIONS/007-localization-scope.md`.
19. **Data model sketch** — Writes `DECISIONS/008-data-model-and-sync.md`.
20. **Launch readiness stub** — Writes `DECISIONS/005-launch-readiness.md` with the spec field 4 (success signal) pre-filled, plus two pre-submission checklist items the app inherits: (a) **ASC App Privacy nutrition label set** to match `DECISIONS/004` (per [recipes/swift/app-privacy-declaration.md](../../../recipes/swift/app-privacy-declaration.md) — manual web-UI step, the ASC API can't set it); (b) **telemetry funnel wired** to the standard funnel if analytics is enabled — `app.launched`, `paywall.triggered/viewed/dismissed`, `purchase.started/completed/failed/restored`, `feature.firstUse`, `free.limit.hit`, `settings.*` (see [recipes/swift/add-analytics.md](../../../recipes/swift/add-analytics.md)).

**End of Phase A:** 17 ADRs (000–016) + `seed-icon.svg` in `drafts/<app-name>/`. **Stop. Sleep on it.** Wizard prints: *"Decisions captured. Re-run with `/new-app --commit <name>` after at least one night."*

## Phase B — Commit (`/new-app --commit <name>`)

Runs after at least one night.

### Step 0 — Refuse-if-spec-missing + overnight-pause (new in v2)

Before any rendering, the wizard validates:

1. `drafts/<name>/DECISIONS/016-spec.md` exists.
2. None of the six field headings is followed by literal placeholder text (`<...>`, `TBD`, `TODO`, or the example quotes from `TEMPLATE-spec.md`).
3. JTBDs match `When .+, I want to .+, so I .+`.
4. **Overnight-pause:** runs `templates/swift/bin/check-draft-mtime.sh drafts/<name>` (or `templates/rn/scripts/check-draft-mtime.sh` for RN apps). The script refuses if the draft's youngest-file mtime is < 12 hours old. To override, the wizard re-invokes with `--force` *after* writing an addendum to `016-spec.md` noting the reason (captured via `AskUserQuestion`).

Any failure → wizard prints the specific reason, points back to step 0 of Phase A, exits.

### Steps

1. **Render templates** — substitute `Seed` → app name, bundle id, App Group, iCloud container, palette hex tokens, typography specimen, 3 chosen haptics, signature motion, monetization tier. Services from `DECISIONS/004` move from `_Disabled/` into `Services/`. `bin/rename-template.sh` also fills the **release-context files** shipped in both templates — `.release.json` (appId, bundle id, commands, metadata/screenshot paths) and `RELEASE.md` (release context) — so every child app carries its launch-packet metadata from its first push. After rendering, update `RELEASE.md`'s Localization Scope and Human Gates from `DECISIONS/013` (locales) and `005` (launch readiness); the launch-packet schema is vendored at [docs/schemas/launch-packet.v1.schema.json](../../../docs/schemas/launch-packet.v1.schema.json).

   **CloudKit deletion is mandatory:** if CloudKit/SwiftData sync is enabled, `DataDeletionService.swift` and `DataDeletionSettingsSection.swift` graduate with it. See [docs/ICLOUD_DATA_DELETION.md](../../../docs/ICLOUD_DATA_DELETION.md).
2. **Wire first screen** — runs `/wire-first-screen` skill (reads `010-first-sixty-seconds.md` + `004-native-feature-checklist.md`, edits `SeedApp.swift` / `ContentView.swift` to gate onboarding and wire the first-screen pattern).
3. **App Store graphics** — run `app-store-graphics` skill against `seed-icon.svg` + palette tokens → 1024 icon, splash, first-pass hero screenshot. For listing *screenshots*, add the new app's config to `tools/app-store-graphics/generate.py` (palette from `DECISIONS/002`, typography from `DECISIONS/011`, feature copy from `016-spec.md`) and run it → writes `<app>/Marketing/app-store-graphics.html` and registers it in the portfolio `tools/app-store-graphics/index.html`. See [recipes/app-store-graphics.md](../../../recipes/app-store-graphics.md).
4. **Show diff** — present the rendered tree for user approval via `AskUserQuestion`.
5. **Create repo** — `mcp__github__create_repository` (visibility chosen via `AskUserQuestion`) → `mcp__github__create_branch` (`claude/initial-scaffold-XXXXX`) → `mcp__github__push_files`.
6. **Run validation** — `/validate-template` skill against the new repo (build green, all 12 housekeeping/feature tests pass).
7. **Open back-PR to iApp** — update `PORTFOLIO.md` (new app row), `PALETTE_CATALOG.md` (claim seed), `MONETIZATION_MATRIX.md` (new row), `RECENT_LEARNINGS.md` if anything novel surfaced.

## Cross-references

- All 17 DECISIONS templates: [DECISIONS/](../../../DECISIONS/) (TEMPLATE.md + TEMPLATE-spec.md + 000–016)
- Spec template: [DECISIONS/TEMPLATE-spec.md](../../../DECISIONS/TEMPLATE-spec.md)
- Portfolio strategy: [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md), [DECISIONS/015-visual-identity.md](../../../DECISIONS/015-visual-identity.md)
- Sleep-required rule: [CLAUDE.md](../../../CLAUDE.md) taste rule 6
- Maturity matrix (✅ Templates / 🟡 Skills / ⬜ Automation): [CLAUDE.md](../../../CLAUDE.md) — explains why SKILL.md is a soft contract, not an enforcer
- Reliability gates: [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md)
