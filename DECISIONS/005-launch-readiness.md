# ADR 005 — Launch Readiness

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Every child app eventually reaches "ready for TestFlight," then "ready for App Store submission," then "ready for first-week feedback." Without an explicit ADR per app, these milestones blur into "we shipped something." That blur is how features ship half-finished.

Kindling itself doesn't go to TestFlight — its launch criterion is an end-to-end smoke test where it generates a child app. This ADR captures Kindling's *own* launch criteria (when is the wizard trustworthy for new apps?) and templates the shape for child apps.

## Decision

**Kindling is "launch-ready" when every layer lands green, ending with an end-to-end smoke test.** Specifically:

- [x] **Foundations**: CLAUDE.md, docs/, root config
- [x] **Portfolio brain**: PORTFOLIO, PALETTE_CATALOG, MONETIZATION_MATRIX, REUSE_INDEX, RECENT_LEARNINGS starter scaffolds
- [x] **DECISIONS**: this folder, 000–016 + TEMPLATE
- [x] **Skills**: `.claude/skills/` (the wizard skills + settings.json + session-start hook)
- [x] **Swift template**: XcodeGen scaffold, every service in `_Disabled/`, housekeeping tests, template CLAUDE.md
- [x] **RN template**: Expo SDK 54 scaffold, iCloud bridge module, NotificationService, template CLAUDE.md
- [x] **Recipes**: Swift + RN + cross-cutting, each with a mandatory "When NOT to use" section; recipe-accuracy CI step
- [x] **Smoke test**: `/new-app --draft` then `/new-app --commit` on a throwaway app produced a repo that builds clean for iOS + macOS with all housekeeping/feature tests passing (the widget tests running non-trivially against an enabled widget target), and `/reliability-check` correctly refused a WIP harvest source. The smoke test surfaced 13 latent template bugs — all fixed in `templates/swift/` (see the smoke-test lessons below).

Until the smoke test passes, the repo is "in development" — the slash commands aren't reliable enough to run new apps through.

Child app ADR 005 follows this shape, replacing the build layers with App Store milestones:

- [ ] All `Pre-submission tests (block PR merge)` from APP_STORE_CHECKLIST passing in CI
- [ ] App icon generated from `seed-icon.svg` via `/generate-icons`, all required sizes present (AppIconAssetTests)
- [ ] Screenshots produced for 6.7" + 6.5" iPhone (+ iPad if supported) via `/app-store-graphics`
- [ ] Privacy Policy + Support URLs published (GitHub Pages or your studio domain)
- [ ] **ASC App Privacy nutrition label set** (web UI — the API can't) to match `DECISIONS/004`: TelemetryDeck app → Usage Data / Product Interaction, not linked / not tracking; zero-analytics app → Data Not Collected. Standard in [recipes/swift/app-privacy-declaration.md](../recipes/swift/app-privacy-declaration.md)
- [ ] **Telemetry funnel wired** to the standard taxonomy (if analytics enabled): `app.launched`, `paywall.triggered/viewed/dismissed`, `purchase.started/completed/failed/restored`, `feature.firstUse`, `free.limit.hit`, `settings.*` — see [recipes/swift/add-analytics.md](../recipes/swift/add-analytics.md)
- [ ] Reviewer notes filled in (`docs/REVIEWER_NOTES.md`)
- [ ] First-week feedback plan: who reads TestFlight feedback, what's the cadence for fixes
- [ ] Submission-day questionnaire pre-decided (see APP_STORE_CHECKLIST.md)

## Smoke-test lessons (kept because they generalize)

Rendering and compiling a child app end-to-end for the first time surfaced latent template bugs worth remembering — each is the kind of bug any template repo will grow if nothing compiles the output:

1. **Rename scripts must cover the whole tree.** `rename-template.sh` originally substituted only the app source dirs and `project.yml`; every root-level config file (`.swiftlint.yml`, CI workflows, `Makefile`, `fastlane/*`, skills, `CLAUDE.md`, `README.md`) kept its seed-name/bundle-id references post-rename.
2. **Pre-commit hooks go stale when paths move.** The hook referenced a config path that had been moved — hooks need the same CI verification as everything else.
3. **Swift 6 strict concurrency bites stored-actor patterns.** An `await activity?.update(...)` tripped "sending 'activity'" — fixed with a fire-and-forget `Task {}` pattern.
4. **Pin `CFBundleShortVersionString` / `CFBundleVersion` to build settings.** XcodeGen defaulted them to `1.0`/`1`, mismatching the embedded widget extension and failing validation.
5. **Widget extension Info.plist needs `CFBundleExecutable` + `CFBundlePackageType`.** Without them the `.appex` fails to install ("missing or invalid CFBundleExecutable").
6. **The 1024 App Store icon entry must not carry `"scale": "1x"`.** `actool` rejects it in the modern single-icon format.
7. **Cross-target types (e.g. `ActivityAttributes`) should be pre-extracted** into the widget target's tree with a documented uncomment path in `project.yml`, so wizard runs follow a comment block instead of re-deriving the wiring.
8. **Wire the scaffold views.** A rendered app whose onboarding and first screen aren't gated/wired is a demo, not a start — hence the `/wire-first-screen` skill as an explicit commit-phase step.

Deliberate non-gaps, also worth recording:

- **The Swift `SeedWidgets/` target ships gated** (commented in `project.yml`) — taste rule 1: features off until the wizard enables them.
- **RN `eas.json` / `.easignore` are recipe-driven, not template files** — EAS profiles + credentials are account-specific; `recipes/rn/add-rn-eas.md` covers adding them.
- **Placeholder localization is English-only.** `/translate <lang>` fills the other 6 tier-1 locales — a per-child pre-submission step, not a template defect.
- **A few recipes are ⚠️ pattern-only** (`add-share-extension`, `add-quicklook`, `add-mac-catalyst`) — no shipped source yet. The first child app to ship one writes the canonical version back via `/sync-from-portfolio`.

## Options considered

- **One single "shipped"/"not shipped" status** — rejected. Erases the milestones that matter (TestFlight ≠ App Store; App Store ≠ first-week-feedback-incorporated).
- **A checklist in PORTFOLIO.md instead of per-app ADR** — rejected. PORTFOLIO is a snapshot of *what exists*; ADRs are the receipts for decisions. Launch readiness is a decision (when do we judge this done?), not a snapshot.

## Consequences

- **Unlocks:** clear criterion for "Kindling is open for business" (= the smoke test passes). Child apps inherit the same discipline.
- **Forecloses:** launching prematurely. The wizard will refuse to run `/new-app` against a state where this ADR's checklist is incomplete.
- **Cost to revisit:** small.

## Verification

When the smoke test passes on your fork:

1. Update the checkboxes above.
2. Keep Status as Accepted.
3. Add a dated "launched" entry to RECENT_LEARNINGS.

## Cross-references

- [docs/APP_STORE_CHECKLIST.md](../docs/APP_STORE_CHECKLIST.md) — child app submission checklist
- [docs/CONTRIBUTING.md](../docs/CONTRIBUTING.md) — commit conventions
- [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md) — where the launch entry will land
