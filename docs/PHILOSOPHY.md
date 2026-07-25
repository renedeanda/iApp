# Philosophy

The shared values across every app built from this repo. Per-app values live in `DECISIONS/000-mission.md` and `DECISIONS/015-visual-identity.md`. This doc is the floor; per-app docs raise it.

## Five operating principles

### 1. The mission fits in one sentence

If the mission needs a paragraph, it isn't a mission yet — it's a wish list. The wizard's first ADR (`000-mission.md`) caps at 14 words. Examples of the shape:

- *"A warm notes app that respects your time."*
- *"A 90-second nervous-system reset, anytime."*
- *"A calm horizon for your day."*
- *"Commute companion that respects working people's time."*
- *"Gentle reminders for the things that matter."*

Each one tells you what to cut. If a proposed feature doesn't serve the sentence, it doesn't ship.

### 2. Restraint over feature count

Thick scaffolds, thin defaults. The Swift template ships 20+ services on disk; a typical new app enables 4–6. Haptics: 24 patterns available, 3 picked. Delight moments: ~18 catalogued in the reel, 3–5 picked per app. Localized: 7 tier-1 locales day one, the wizard asks before adding an 8th.

Every unused capability is a sign the architect didn't trust the mission. Cut it.

### 3. Reliability is per-feature, not per-repo

No portfolio is uniformly polished. One app nails widgets and Live Activities; another's widget l10n is still WIP; a third perfected haptics and nobody else caught up. The [REUSE_INDEX](../portfolio/REUSE_INDEX.md) names a gold-standard source per capability and a WIP-warning list. The `/reliability-check` skill enforces this on every harvest.

**Rule:** when a capability has a single gold-standard source row, the wizard does not offer a WIP alternative. No exceptions.

### 4. Visual identity is a first-class decision

Apple features apps that feel new. Apps that feel new follow Apple HIG *and* declare a visual identity beyond "looks like the default SwiftUI styling." The wizard's `/pick-visual-identity` step asks every new app to pick from:

- **Brutalist** — thick rules, hard cuts, raw type, monochrome with one screaming accent
- **Glassmorphic** — Liquid Glass under floating bars
- **Warm-minimal** — gentle defaults; the safe and tasteful starting point
- **Typographic-led** — type as the primary visual element; serif body, light/heavy contrast
- **Hand-drawn** — sketched edges, paper textures, imperfect lines
- **Maximalist-collage** — overlapping shapes, mixed media, color riot held by composition
- **Kinetic-type** — animated headings, type-as-motion
- **Monochrome-luxe** — pure grayscale + one metal accent (gold, copper, steel)

Pick one. Commit to it. The wizard writes `DECISIONS/015-visual-identity.md` and every subsequent component decision references it. The default ships warm-minimal; deviating is encouraged, not penalized.

### 5. Sleep is a feature

`/new-app --draft` writes 17 decision docs locally and stops. Spec/JTBDs, mission, anti-list, palette, motion, delight, typography, haptics — all written, none committed. The wizard refuses to render templates or push code until at least one night has passed and `/new-app --commit <name>` is invoked.

The product taste curve looks like this: at 8 PM the idea sounds brilliant; at 8 AM you can see what was vanity. The repo bakes in that 12 hours.

## Code-level expectations

### Swift

- **No `#000` or `#FFF`.** Use the chosen palette's `Surface`, `OnSurface`, `Primary`, `Accent` tokens.
- **No `.system(size:)` in views.** Use the typography protocol (`Typography.title`, `Typography.body`, etc.).
- **`motionSafeAnimation()` everywhere.** Wraps a `withAnimation` call and short-circuits to identity when `UIAccessibility.isReduceMotionEnabled`.
- **AAA contrast on primary pairs.** Verified by `ThemeContrastTests.swift`.
- **Pure Sendable domain logic.** No `import SwiftUI` in engines. A pattern proven in a shipped brutalist utility app.
- **Single-screen + sheets navigation.** No `NavigationStack` push trees deeper than 1. Sheets for everything else. The template's `NavigationRouter.swift` ships this pattern.
- **`@Observable` services on `@MainActor`.** No `ObservableObject`. No `@StateObject`. Modern only.
- **Swift Testing for new code.** `@Test`, `#expect`. XCTest only when extending existing suites.
- **App Intents shortcuts have localized phrases.** Strings live in the intent's bundle, not the app's.

### React Native

- **Expo SDK 54+.** EAS Build only, no bare workflow.
- **TypeScript strict.** `noUncheckedIndexedAccess: true`.
- **Expo Router for navigation.** Tabs at the root, modals via `presentation: 'modal'`.
- **i18next + expo-localization.** Tier-1 locales day one. No hardcoded English in JSX.
- **Native widgets via Expo modules.** The template's `modules/icloud-bridge` and `modules/widget-bridge` — a TS shim wraps a real Swift widget extension. Never fake widgets in JS.
- **Notifications use the rolling 64-limit pattern** (iOS caps scheduled notifications at 64). `setHours/setMinutes` not `setTime` for iOS compatibility. Auto-reschedule on receive. Ships in the RN template's notification service.

## Universal forbidden list

(Mirrored in each child app's CLAUDE.md.)

- No `#000` / `#FFF`
- No force-unwraps
- No hardcoded UI strings
- No `NavigationStack` deeper than 1
- No `ObservableObject` / `@StateObject` (Swift)
- No bare RN
- No new analytics SDKs without ADR (TelemetryDeck + Sentry pre-approved)
- No engagement-maximizing notifications (see [NOT_FOR.md](NOT_FOR.md))
- No shame-driven streaks (see [WHATS_ALLOWED.md](WHATS_ALLOWED.md) for the positive framing)
- No harvesting widget l10n / Live Activity / Control Center code from a WIP source — the template's widget scaffold is the gold standard
- No 4th haptic without `/earn-haptic`
- No 6th delight moment without ADR addendum

## When a rule is wrong

Every rule above was earned by getting it wrong in a previous app. If a new app discovers a counter-example, the right move is:

1. Note it in [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md) with date + one-sentence summary.
2. Open a PR to this doc proposing the rule change.
3. The PR description must name the specific feature in the specific app that proved the rule wrong.

Rules don't get changed in a Slack thread.
