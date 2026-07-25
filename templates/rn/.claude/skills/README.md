# `.claude/skills/` — RN template skill set

Eleven skills ship with this template. They cover the most common session-level operations a child RN app needs:

| Skill | Purpose |
|---|---|
| `roadmap` | Session starter — what's next |
| `session-continue` | Resume after a limit hit / restart |
| `review` | Auto-healing audit (RN-flavored 12 categories) |
| `analytics-audit` | Product analytics funnel, opt-out, privacy manifest, and ASC Product Interaction release audit |
| `build` | `npm run prebuild` + `npm run ios|android` |
| `test` | `jest` with optional filter |
| `translate` | Fill missing i18next locale JSON |
| `generate-icons` | Render every icon variant from `assets/icon_master.svg` |
| `app-store-graphics` | Render App Store screenshot set from i18n + theme |
| `earn-haptic` | Unlock a 4th+ haptic with an ADR addendum |
| `init` | Re-seed `CLAUDE.md` if `{{PLACEHOLDERS}}` leaked through |

## Provenance

Each `SKILL.md` carries a `> SOURCE:` line near the top noting which iApp-root skill it was adapted from. When iApp's master skill evolves, run `sync-from-portfolio` from iApp to propagate the change here — children never silently inherit template changes.

## What's NOT here (and why)

The wizard-only skills (`new-app`, `pick-*`, `design-icon`, `positioning-check`, `reliability-check`, `sync-from-portfolio`, `validate-template`) live in iApp-root only — they only make sense before this app exists.

Swift-only skills (`pbxproj-check`, `platform-check`, `add-widget` Swift flavor, `dev-premium-toggle`, `haptic-check`) are intentionally omitted — they don't apply to an Expo/RN app.

The cross-cutting auditor skills (`l10n-audit`, `theme-check`, `a11y-audit`, `plan-status`) are deferred to a later harvest pass once their RN-flavored implementations have been proven in a child app. Until then, `review` covers their categories at a coarser grain.
