# CLAUDE.md — iApp

> Read this first, every session.

## What iApp is

iApp is a planning hub + two runnable starter scaffolds (Swift, React Native) for building a portfolio of opinionated, polished iOS apps. It exists so that every new app idea inherits gold-standard services, taste rules, and decision discipline from day one — instead of being hand-forked from whichever previous project is closest.

It was distilled from shipping a real portfolio of iOS apps (native and RN, free and paid, minimal and deep) and open-sourced so anyone can bootstrap with the same system.

## Your portfolio at a glance

Your shipped apps live in [portfolio/PORTFOLIO.md](portfolio/PORTFOLIO.md) — iApp ships it as a starter table you fill in as apps ship. Several skills read it: palette clash checks, mission positioning checks, visual-identity diversity checks, and monetization mix all key off that file. Keep it current; it is the portfolio's memory.

## Taste rules — non-negotiable

These rules apply to every app generated from this repo. The `/new-app` wizard refuses to push code until they're respected.

1. **Services default off.** Every reusable service lands on disk under `Services/_Disabled/` with commented `import` lines and a one-line header explaining how to enable it. The wizard makes each service an explicit yes.

2. **Haptics are *earned*.** A full 24-pattern haptic vocabulary (distilled from a shipped production app) ships under `Utilities/_HapticVocabulary/HapticPatterns.full.swift` as a reference. The wizard picks **3 starter haptics** for each new app. Earning a 4th, 5th, 6th, etc., is a deliberate later action via `/earn-haptic` (which writes an ADR addendum justifying the unlock). Soft cap of 8.

3. **Six design-first checkpoints precede tech.** Mission → visual identity → signature motion → first-sixty-seconds → delight moments → icon SVG seed. The wizard will not ask "Swift or RN?" until all six are written down. (The first five are decision ADRs; the icon is a generated artifact.)

4. **Visual identity novelty is a feature.** The wizard's `/pick-visual-identity` step asks every new app to declare what makes it visually distinct: brutalist / glassmorphic / warm-minimal / typographic-led / hand-drawn / maximalist-collage / kinetic-type / monochrome-luxe. Templates ship a warm-minimal default but the default is a starting point, not a destination. See [docs/VISUAL_IDENTITIES.md](docs/VISUAL_IDENTITIES.md).

5. **Palettes are departure points, not picks.** [`portfolio/PALETTE_CATALOG.md`](portfolio/PALETTE_CATALOG.md) lists 10 seeds. The chosen palette is always the bespoke delta from a seed, captured in `DECISIONS/002-palette.md`. ΔE2000 distance < 15 from any palette *claimed in your portfolio* triggers a clash warning.

6. **Sleep is required.** `/new-app --draft` writes 17 decision docs (000–016) locally and stops. `/new-app --commit <name>` resumes after at least one night, and refuses if `016-spec.md` is missing or unfilled.

7. **NOT_FOR rejects manipulative patterns, not engagement.** Streaks, reminders, notifications, gamification are welcome when framed as celebration / utility / care. Read both [docs/NOT_FOR.md](docs/NOT_FOR.md) and [docs/WHATS_ALLOWED.md](docs/WHATS_ALLOWED.md) before refusing any feature. Worked examples in both docs.

8. **Source-grounding for new app picks.** Every new app candidate must trace to specific evidence — a real user, a real workflow you've observed, a data structure or page in a project you already run. Picks that fill a slot ("we need a Tier 2 app") but have no evidence behind them are cut, not invented.

## Maturity matrix — what enforces what

iApp has three layers, and each layer has a different enforcement guarantee. Knowing which layer you're looking at tells you what trusts what.

| Layer | What it is | Enforcement strength | Examples |
|---|---|---|---|
| ✅ **Templates** | Files on disk under `templates/swift/` and `templates/rn/` that get rendered into child apps. Compiled, tested, CI-verified. | **Hard.** Tests in CI catch regressions. If a template ships a bug, the next child app inherits it — so verify-* scripts run on every push. | `templates/swift/Seed/`, `templates/swift/bin/rename-template.sh`, the housekeeping/feature tests |
| 🟡 **Skills** | LLM contracts in `.claude/skills/*/SKILL.md`. Prompts that tell the agent how to walk the user through a decision. | **Soft.** A skill says "use `AskUserQuestion`," but the agent is what actually does or does not call it. A skill is only as good as the agent's adherence. | `new-app/SKILL.md`, `pick-palette/SKILL.md`, `reliability-check/SKILL.md` |
| ⬜ **Automation** | Auditable artifacts that the wizard *checks for* before proceeding (mtime, file presence, regex matches). Mechanical scripts (`init-claude-md.sh`, `generate-icons.sh`, `check-draft-mtime.sh`) belong here. | **Hard.** The check is in code; the script either exits 0 or it doesn't. Where a skill would be ignorable, automation is not. | `bin/check-draft-mtime.sh`, `--commit`'s 016-spec.md presence check, `WidgetLocalizationParityTests.swift` |

**Implication for SKILL.md authors:** if a rule *must* hold, it cannot live solely in a SKILL.md prompt. It needs an artifact (a file that must exist, a script that runs in CI, a test that fails) that backs it up. SKILL.md prompts are the *guidance*; the artifact is the *enforcer*.

**Implication for agents:** when reading a SKILL.md, treat the steps as a contract you are *expected* to honor, not optional flavor. The user trusts the wizard because the wizard says it will ask. If you skip an `AskUserQuestion` call to "save time," you have broken the contract — and the user has no audit trail to notice.

## Design philosophy

(Distilled from the CLAUDE.md files of multiple shipped production apps.)

- **No pure `#000` or `#FFF`.** Use the palette's surface tokens. Warm palettes are the most common default but not required — a well-executed brutalist or cool direction can earn its place.
- **Typography is environment-driven.** The Swift template ships one chosen specimen at `Theme/Typography.swift` (rounded-system, serif, or mono-leaning) and the other two as swappable references at `Theme/_TypographySpecimens/`. Never use `.system(size:)` directly in views — go through the chosen typography protocol.
- **Respect Reduce Motion + Reduce Haptics.** Every motion animation uses `motionSafeAnimation()`. Every haptic checks `UIAccessibility.isReduceMotionEnabled` *or* a dedicated `reduceHaptics` setting.
- **AAA contrast on primary text/background pairs, in both light and dark.** Enforced by `ThemeContrastTests.swift` in every template.
- **Dark mode + a spacing scale are template defaults.** `AppTheme` tokens resolve a light/dark hex pair via `dynamic(light:dark:)`; `Theme/Spacing.swift` ships a 4-based scale alongside `Typography`. A generated app has a working dark appearance from its first build — never light surfaces leaking under dark system chrome.
- **Signature motion and delight moments ship as code, not just an ADR.** `Theme/SignatureMotion.swift` carries a working default (Breathing); `/wire-first-screen` rewrites it per `DECISIONS/009` and applies `.signatureMotion()` to the first screen. `Theme/DelightMoments.swift` carries the reusable delight patterns; `/wire-first-screen` applies the `DECISIONS/014` picks the same way. An ADR that produces no code is a gap — and `SignatureMotionWiredTests` fails the build when a motion ADR has no `.signatureMotion()` call site.
- **Pure Sendable domain logic.** Engines (recommendation, compliance, cost — whatever your domain needs) are value types with no UI imports. UI talks to them via `@Observable` services on `@MainActor`. Proven in a shipped production app; see `recipes/swift/add-sendable-engine.md`.
- **Apple Intelligence is Pro-gated, availability-checked, and always has a deterministic fallback.** `#if canImport(FoundationModels)` + runtime `LanguageModel.isAvailable` + a `nil` return path that the caller handles. See `Services/_Disabled/OnDeviceAIService.swift`.
- **StoreKit 2 only.** No third-party billing SDK. The template's `SubscriptionManager.swift` is the baseline.
- **i18n from day 1.** Tier-1 locales: `en es de fr pt ja zh-Hans`. Strings live in `Localizable.xcstrings`. Widget extensions ship their *own* `Localizable.xcstrings` because Live Activity / widget runtimes load strings from the extension's bundle, not the host app's. **This is a trap that shipped broken once — hence the rule.** Verified by `WidgetLocalizationParityTests.swift` in every template.
- **Metered Apple APIs require explicit cost-modeling.** Apps using WeatherKit (500k calls/mo free per developer account, $49/100k thereafter) must include a cost-modeling section in their planning card: modeled call volume at 1k and 10k MAU, free-quota headroom, and a fallback ladder if quota is approached. See [portfolio/MONETIZATION_MATRIX.md](portfolio/MONETIZATION_MATRIX.md).

## What we don't build

Pointer to [docs/NOT_FOR.md](docs/NOT_FOR.md). Short version: no ads, no social graphs, no infinite scroll, no engagement-maximizing notifications, no dark patterns, no shame-driven streaks. Read it alongside [docs/WHATS_ALLOWED.md](docs/WHATS_ALLOWED.md) so engagement features themselves aren't accidentally vetoed.

## Code-quality rules

(Universal subset — every child app's `CLAUDE.md` inherits these.)

- **No force-unwraps in production code.** Use `guard let`, `if let`, or `??`.
- **All UI strings go through `Localizable.xcstrings` / `i18next`.** Never hardcode English in a `Text(...)` or `<Text>`.
- **Swift Testing for new code.** XCTest only when extending existing XCTest suites.
- **Views ≤300 lines.** Hard limit. Extract subviews when it grows.
- **One `@Observable` per concern.** `DataController` doesn't own subscription state; `SubscriptionManager` does.
- **No new third-party deps without an ADR.** Add `DECISIONS/NNN-dependency-<name>.md` explaining the tradeoff. TelemetryDeck and Sentry SDK are the only pre-approved analytics deps.
- **Reliability discipline.** Before harvesting a service, check [portfolio/REUSE_INDEX.md](portfolio/REUSE_INDEX.md) for the gold-standard source for that capability. In the starter state that's the templates themselves; as your apps ship, the index evolves with them.

## How to use this repo

### To start a new app

1. `/new-app --draft` — answer the 21 design-first questions (starting with spec/JTBD intake), write 17 ADRs (000–016) into `drafts/<app-name>/`. Sleep on it.
2. Next day: `/new-app --commit <app-name>` — wizard renders templates, generates app icon + first-pass App Store graphics, creates a GitHub repo, pushes the initial branch, and opens a PR back to iApp that claims the palette and adds the new app to `PORTFOLIO.md`.

### To add a feature to an existing app

1. Find the feature in [recipes/](recipes/). Every recipe has a `When NOT to use` section — read it first.
2. The recipe cites the gold-standard source (usually a template path in this repo) — open it, adapt it, validate it.
3. If the feature lives in a `Services/_Disabled/` file in the current app, move it up and uncomment imports.

### To evolve iApp itself

- New service pattern proven in one of your child apps → propose via the `sync-from-portfolio` skill, which diffs the child file against the template version and prepares a PR.
- New visual identity discovered → add to [docs/VISUAL_IDENTITIES.md](docs/VISUAL_IDENTITIES.md).
- New delight moment shipped → add to [docs/DELIGHT_REEL.md](docs/DELIGHT_REEL.md) with file path.
- New lesson learned → add to [portfolio/RECENT_LEARNINGS.md](portfolio/RECENT_LEARNINGS.md) with date and one-sentence summary.

## Where to find each module

See [portfolio/REUSE_INDEX.md](portfolio/REUSE_INDEX.md) for the full feature → source map. Quick examples:

- Native widgets, Live Activities → `templates/swift/SeedWidgets/`
- Haptic vocabulary (24 patterns) → `templates/swift/Seed/Utilities/_HapticVocabulary/`
- Pure Sendable engines → `recipes/swift/add-sendable-engine.md`
- Apple Intelligence gating → `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift`
- RN iCloud bridge → `templates/rn/modules/icloud-sync/`
- RN notifications (64-limit rolling window) → `templates/rn/src/services/NotificationService.ts`
- RN widgets → `recipes/rn/add-rn-widgets.md`
- SwiftUI interactive onboarding + About replay → `recipes/swift/add-interactive-onboarding.md`

## Forbidden

- Never commit secrets (`.env`, App Store Connect API keys, signing certs).
- Never force-push `main`.
- Never edit files outside the task scope. If you discover something tangential, write it down — don't fix it in the same PR.
- Never create stray `*.md` reports, plan files, or status docs in the repo root. Work from conversation context.
- Never harvest a feature from a source flagged ⚠️ in [portfolio/REUSE_INDEX.md](portfolio/REUSE_INDEX.md). `/reliability-check` enforces this.
- Never ship a 4th haptic without `/earn-haptic`. Never ship a 6th delight moment without an ADR addendum.
- **Never propose a new app pick without source-grounding.** Per taste rule 8.

## When in doubt

The five things that matter, in order:
1. **Mission** — can you state it in one sentence?
2. **Restraint** — does this feature earn its weight?
3. **Reliability** — is the source you're harvesting from production-grade?
4. **Taste** — would Jobs/Ive approve of the seam being invisible?
5. **Sleep** — have you slept on the decision before committing?

If any answer is no, stop. Open a draft ADR. Come back tomorrow.
