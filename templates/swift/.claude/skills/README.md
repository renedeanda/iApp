# `.claude/skills/` — Swift template skill set

Eleven skills ship with this template — the same core set the RN template ships, retargeted to Swift / Xcode / xcstrings:

| Skill | Purpose |
|---|---|
| `roadmap` | Session starter — what's next |
| `session-continue` | Resume after a limit hit / restart |
| `review` | Auto-healing audit (14 SwiftUI/SwiftData categories) |
| `analytics-audit` | Product analytics funnel, opt-out, privacy manifest, and ASC Product Interaction release audit |
| `build` | `xcodegen generate` + `xcodebuild` (iOS + macOS) |
| `test` | `xcodebuild test` — includes the 8 housekeeping tests |
| `translate` | Fill missing `Localizable.xcstrings` locales |
| `generate-icons` | Render `AppIcon.appiconset` from `icon_master.svg` |
| `app-store-graphics` | Render the App Store screenshot set |
| `earn-haptic` | Graduate a 4th+ haptic from `_HapticVocabulary/` with an ADR addendum |
| `init` | Re-seed `CLAUDE.md` if `{{PLACEHOLDERS}}` leaked through |

## Provenance

Each `SKILL.md` carries a `> SOURCE:` line noting the Kindling-root skill it was adapted from. When Kindling's master skill evolves, run `sync-from-portfolio` from Kindling to propagate the change — children never silently inherit template changes.

## What's NOT here (and why)

The wizard-only skills (`new-app`, `pick-*`, `design-icon`, `positioning-check`, `reliability-check`, `sync-from-portfolio`, `validate-template`) live in the Kindling root only — they only make sense before this app exists.

The fuller Pass-B Swift kit (`theme-check`, `a11y-audit`, `platform-check`, `l10n-audit`, `pbxproj-check`, `design-audit`, `add-widget`, `plan-status`, `deferred-check`) is deferred to a later harvest pass — their categories are covered at a coarser grain by `review` until the standalone RN-and-Swift-flavored implementations are proven in a child app. This matches the RN template's skill scope, so the two stay consistent.
