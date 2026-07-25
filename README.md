# iApp

**An open-source planning hub + starter scaffolds for shipping polished iOS apps quickly — design-first, AI-first, covering both Swift and React Native.**

iApp is the system behind a real portfolio of shipped App Store apps, generalized so anyone can use it. It is two things in one repo:

1. **A planning brain.** Decision-doc templates, a palette catalog, a monetization ladder, a reuse index, and a changelog of hard-won lessons — the discipline that keeps a growing portfolio of apps coherent instead of chaotic.
2. **Two runnable starter templates.** A Swift/SwiftUI scaffold and an Expo/React Native scaffold, each pre-wired with production-grade services — CloudKit sync, StoreKit 2, App Intents, widgets, Live Activities, Apple Intelligence, notifications, haptics, analytics, biometrics — all shipped **off by default** so each new app opts in deliberately.

It is **AI-first**: open this repo in a [Claude Code](https://claude.com/claude-code) session and run `/new-app`, and the wizard walks your idea from a one-sentence mission through palette, motion, typography, haptics, and delight moments to a pushed, buildable scaffold — without letting you skip a design decision. But nothing here *requires* AI: every template builds standalone, every recipe is a plain Markdown guide, every decision doc is a form you can fill in by hand.

---

## Table of contents

- [Why iApp exists](#why-iapp-exists)
- [What makes it different](#what-makes-it-different)
- [Quick tour of the repo](#quick-tour-of-the-repo)
- [Complete beginner? Start here](#complete-beginner-start-here)
- [Getting started — the AI-first path](#getting-started--the-ai-first-path)
- [Getting started — the manual path](#getting-started--the-manual-path)
- [Choosing Swift vs React Native](#choosing-swift-vs-react-native)
- [The design-first wizard, step by step](#the-design-first-wizard-step-by-step)
- [Adding features with recipes](#adding-features-with-recipes)
- [The portfolio layer](#the-portfolio-layer)
- [The philosophy: what we don't build](#the-philosophy-what-we-dont-build)
- [Shipping to the App Store](#shipping-to-the-app-store)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## Why iApp exists

Most app ideas die in one of two ways:

- **Death by blank project.** You open Xcode, stare at `ContentView.swift`, wire up the same settings screen, paywall, and dark mode you've built five times before, and run out of steam before the interesting part.
- **Death by drift.** Your second app forks your first, your third forks your second, and soon the same `SubscriptionManager` exists in four mildly-different broken versions and none of your apps feel related.

iApp fixes both. Every new app starts from the same thick, tested scaffold — and every new app goes through the same short set of *design* decisions first, so it ships with a mission, a distinct visual identity, and restraint built in.

## What makes it different

- **Design decisions precede tech.** Mission, anti-list, visual identity, palette, icon, signature motion, delight moments, first-sixty-seconds, typography, haptic vocabulary — all written down *before* anyone asks "Swift or React Native?"
- **Restraint is a feature.** The scaffold ships thick on disk but defaults thin. Services live in `Services/_Disabled/` until explicitly enabled. Haptics start at 3 patterns (of 24 available). Delight moments cap at 5 per app.
- **Palettes are departure points, not picks.** The catalog offers 10 seeds; your chosen palette is always a bespoke delta from a seed, recorded in a decision doc. A ΔE2000 color-distance check warns when a new app's palette drifts too close to one you've already shipped.
- **Accessibility is enforced, not aspirational.** AAA contrast is tested in CI. Every animation respects Reduce Motion. Every haptic respects a reduce-haptics setting. Layouts are tested at the largest Dynamic Type sizes.
- **Localization from day 1.** Seven tier-1 locales ship in the templates, with tests that catch the classic trap of widget/extension strings silently falling back to raw keys.
- **Sleep is built in.** The wizard writes your decision docs and *stops*. It refuses to scaffold the app until you've slept on the decisions at least one night. This sounds cute; it has killed more bad apps than any code review.
- **Every lesson is encoded, not just remembered.** The templates carry tests for mistakes that were shipped and paid for once: the 64-notification ceiling, the extension-bundle localization trap, privacy manifests that silently miss the bundle, screenshot rules that trigger App Review rejections. See [portfolio/RECENT_LEARNINGS.md](portfolio/RECENT_LEARNINGS.md).

## Quick tour of the repo

```
iApp/
├── CLAUDE.md            # the constitution — taste rules, design philosophy, code rules
├── DECISIONS/           # numbered ADR (decision doc) library, copied into every child app
├── portfolio/           # YOUR portfolio's memory (starter state: fill in as you ship)
│   ├── PORTFOLIO.md         # your shipped apps, claimed palettes, claimed motions
│   ├── PALETTE_CATALOG.md   # 10 palette seeds with AAA-checked tokens
│   ├── MONETIZATION_MATRIX.md  # the 5-tier pricing ladder + market data
│   ├── REUSE_INDEX.md       # feature → gold-standard source map
│   └── RECENT_LEARNINGS.md  # dated lesson changelog (pre-seeded)
├── recipes/             # feature add-on guides — swift/ and rn/ — each with "When NOT to use"
├── templates/
│   ├── swift/           # XcodeGen + SwiftUI + SwiftData + StoreKit 2 + widgets + tests
│   └── rn/              # Expo + Expo Router + i18next + EAS + native-module bridges
├── tools/
│   └── app-store-graphics/  # localized App Store screenshot generator
├── scripts/             # template verification (run in CI)
├── .claude/             # AI skills: /new-app, /pick-palette, /earn-haptic, /review, ...
└── docs/                # PHILOSOPHY, NOT_FOR, WHATS_ALLOWED, WIDGETS, VISUAL_IDENTITIES, ...
```

---

## Complete beginner? Start here

Never built an iOS app before? You can still use this repo — it's arguably *most* useful before habits form. Two companions were written specifically for you:

- **[docs/BRING_YOUR_IDEA.md](docs/BRING_YOUR_IDEA.md)** — a plain-English worksheet to fill in *before you touch a computer*: what your app is, who it's for, how it should feel. Send it to a friend with an app idea; a filled worksheet makes their first session twice as productive.
- **[docs/FIRST_APP_TUTORIAL.md](docs/FIRST_APP_TUTORIAL.md)** — a complete walkthrough from clone to your own renamed, re-themed app running on the Simulator (60–90 min, zero experience assumed).
- **[docs/GLOSSARY.md](docs/GLOSSARY.md)** — every piece of iOS jargon you'll meet, decoded.

And if you're in an AI session, just run **`/start`** — it asks where you are and walks you down the right path interactively.

Here's the honest on-ramp.

### What you need

| Thing | Why | Cost |
|---|---|---|
| **A Mac** | Xcode (Apple's IDE) only runs on macOS. Any Apple-silicon Mac works. | — |
| **Xcode** (Mac App Store) | Compiles apps, runs the iPhone Simulator. Install it and launch once so it installs its tools. | Free |
| **An Apple ID** | Lets you run your app on the Simulator and your own device. | Free |
| **Apple Developer Program** | Only needed when you're ready to put an app on the App Store or TestFlight. Skip it for now. | $99/yr |
| **Node.js** (only for the RN path) | Runs the React Native toolchain. Install the LTS version from nodejs.org. | Free |
| **[Claude Code](https://claude.com/claude-code)** (optional but recommended) | The AI wizard that walks you through this repo's flow. | Varies |

You do **not** need: a paid developer account to learn, an iPhone (the Simulator is fine), or prior Swift/TypeScript experience — the templates are heavily commented and the recipes explain the *why*, not just the *what*.

### Your first hour

1. **Clone this repo** (install [git](https://git-scm.com) if you don't have it):
   ```sh
   git clone https://github.com/<owner>/iApp.git
   cd iApp
   ```
2. **Pick a lane.** If you want to learn Apple's native stack (recommended if you only care about iOS), take the Swift template. If you know some JavaScript or want Android later, take the React Native template. See [Choosing Swift vs React Native](#choosing-swift-vs-react-native).
3. **Make the Swift template run:**
   ```sh
   cd templates/swift
   brew install xcodegen        # installs the project generator (get Homebrew from brew.sh)
   xcodegen generate            # creates the Xcode project from project.yml
   open Seed.xcodeproj          # opens in Xcode — press ⌘R to run in the Simulator
   ```
   (When you're ready to make it *yours*, use `make bootstrap NAME=YourApp BUNDLE=com.example.yourapp` instead — it renames every `Seed` token first. See `templates/swift/README.md`.)
   You should see a themed, dark-mode-aware starter app with onboarding, settings, and a paywall — all running locally.
4. **Or make the RN template run:**
   ```sh
   cd templates/rn
   npm install
   npx expo start               # press "i" to open the iOS Simulator
   ```
5. **Read [`CLAUDE.md`](CLAUDE.md).** It's short and it is the whole philosophy. Even if you never use AI, it's the best "how to think about a small quality app" document in the repo.

### Learning the underlying platforms

iApp gives you a working app to *modify*, which is the fastest way to learn — but pair it with real fundamentals:

- **Swift path:** Apple's free [Develop in Swift](https://developer.apple.com/tutorials/develop-in-swift) tutorials, then [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui) (free, community favorite).
- **RN path:** the official [React Native docs](https://reactnative.dev/docs/getting-started) and [Expo docs](https://docs.expo.dev) — Expo's own tutorial is genuinely good.
- When a file in the template confuses you, ask an AI assistant to explain it — every service here is small and single-purpose on purpose, so explanations stay digestible.

---

## Getting started — the AI-first path

This is the intended flow. You need [Claude Code](https://claude.com/claude-code) (CLI, desktop, or web).

```sh
git clone <this repo>
cd iApp
claude   # open a Claude Code session in the repo
```

Then, inside the session:

```
/new-app --draft
```

The wizard asks **21 design-first questions** — starting with what job your app does and for whom (spec/JTBD intake), then mission, anti-list, visual identity, palette, typography, signature motion, haptics, delight moments, monetization tier, native-feature checklist, localization scope, naming, and more. It writes **17 numbered decision docs** into `drafts/<app-name>/`. Then it stops and tells you to sleep.

Next day:

```
/new-app --commit <app-name>
```

The wizard verifies you actually slept (it checks file timestamps), renders your chosen template with your decisions substituted, generates an app icon from your SVG seed, wires your signature motion and delight moments into the first screen, runs the template's test suite, and pushes the new repo. Your app starts life buildable, tested, localized, dark-mode-correct, and opinionated.

Other skills you'll use over an app's life:

| Skill | What it does |
|---|---|
| `/start` | The front door — asks your experience level and routes you (tutorial, wizard, recipes, or shipping) |
| `/pick-palette` | Proposes 3 seeds matching your visual identity; checks color distance against your shipped apps |
| `/earn-haptic` | Unlocks a 4th+ haptic pattern — with a written justification |
| `/wire-first-screen` | Applies your motion + delight decisions as real code on the first screen |
| `/review` | Auto-healing code review across a dozen quality categories |
| `/reliability-check` | Refuses harvesting from sources flagged ⚠️ in the reuse index |
| `/analytics-audit` | Audits analytics wiring, opt-out behavior, privacy manifest readiness |
| `/apple-app-review` | Pre-submission audit against Apple's current review guidelines |
| `/sync-from-portfolio` | Folds an improvement from one of your shipped apps back into the template |

## Getting started — the manual path

No AI required. The system is files, not magic:

1. **Copy the decision templates.** `DECISIONS/TEMPLATE.md` and the numbered worked examples show the form. Create `drafts/<your-app>/` and fill in 000 (mission) through 016 (spec) honestly. The questions are the value; the wizard is just a nag.
2. **Render a template by hand.**
   - Swift: copy `templates/swift/`, then run `bin/rename-template.sh <YourAppName>` to rename the `Seed` project, targets, and bundle IDs; then `xcodegen generate`.
   - RN: copy `templates/rn/`, update `app.json` (name, slug, bundle identifier), and `npm install`.
3. **Enable services deliberately.** Each file in `Services/_Disabled/` has a one-line header explaining how to enable it (usually: move it up one directory, uncomment the imports, add the entitlement it names).
4. **Pick your palette from the catalog**, write down your departure delta in `DECISIONS/002-palette.md`, and put the final tokens in `Theme/AppTheme.swift` (Swift) or `theme/AppTheme.ts` (RN).
5. **Run the tests.** Both templates ship housekeeping tests that will fail if you break contrast, localization parity, privacy manifests, or motion wiring. They are your guardrails — keep them green.

## Choosing Swift vs React Native

The repo covers both because both are legitimate. The honest decision guide (the full version is the `/pick-tech` skill):

| Choose **Swift/SwiftUI** when… | Choose **Expo/React Native** when… |
|---|---|
| The app leans on native surfaces: widgets, Live Activities, App Intents, Apple Intelligence, Control Center | The app is mostly screens, lists, and forms |
| You want the deepest platform feel and performance | You want Android from the same codebase later |
| You're iOS-only and happy about it | You (or your team) already think in JavaScript/TypeScript |
| SwiftData/CloudKit sync is core | Your sync is simple key-value iCloud (the template ships a clean bridge) |
| You'll live in Xcode anyway | You want OTA updates via EAS for fast iteration |

Rule of thumb from shipping both: **utilities and deep-native experiences go Swift; content-and-reminder style apps do great in RN.** Both templates enforce the same design system, i18n discipline, and taste rules — the philosophy doesn't care which renderer you pick.

## The design-first wizard, step by step

Whether AI-driven or manual, the sequence is the same, and the ordering is the point — **the design checkpoints come before any tech question**:

1. **Spec / JTBD intake** — who is this for, what job does it do, what's the evidence anyone needs it? (Source-grounding rule: no evidence, no app.) This step also classifies the idea's **ambition rung** — solo → synced → shared-with-invited-people → competitive → strangers-and-feeds — and if the idea needs a real backend, surfaces the true cost of that path first ([docs/AMBITIOUS_APPS.md](docs/AMBITIOUS_APPS.md)).
2. **Mission** — one sentence, ≤14 words. Everything else derives from it.
3. **Anti-list** — what this app will *never* do, written before feature brainstorms make you sentimental.
4. **Visual identity** — one of eight: brutalist / glassmorphic / warm-minimal / typographic-led / hand-drawn / maximalist-collage / kinetic-type / monochrome-luxe. Declared, not defaulted.
5. **Palette** — a seed from the catalog + your bespoke departure delta. Checked for AAA contrast and distance from your other apps.
6. **Signature motion** — the *one* motion principle the app is known by, with timing curve and Reduce Motion fallback.
7. **First sixty seconds** — script the new user's first minute, screen by screen. Permissions are requested at the moment of intent, never up front.
8. **Delight moments** — pick 3–5 specific micro-joys tied to specific user actions. Capped, because delight dilutes.
9. **Typography** — one specimen (rounded / serif / mono-leaning), applied through a token API, never ad-hoc font calls.
10. **Haptic vocabulary** — 3 starter patterns from a 24-pattern reference. More are earned later, one ADR at a time.
11. **Icon SVG seed** — a real `icon_master.svg` generated before tech, so the app has a face early.
12. …then and only then: **tech choice, monetization tier, native-feature checklist, data model, localization scope, naming, launch readiness, and the full spec.**

Each step writes a numbered decision doc. The docs are short. Their power is that they exist, they're honest, and the next contributor (or the next you, six months later) can read *why*.

## Adding features with recipes

`recipes/` is a cookbook of 50+ feature guides — including the ingredients idea-stage apps most often need (photo capture, structured collections, timers, sharing/export) — each with the same skeleton: **What it adds → When to use → When NOT to use → How (harvest / wire / verify) → Gotchas.**

The "When NOT to use" section is always first-class. A few examples:

- `swift/add-widgets.md` — don't build a widget that's just a launch button; widget strings must live in the widget's own string catalog.
- `swift/add-live-activity.md` — a Live Activity for something that isn't genuinely live is notification spam with extra steps.
- `swift/add-storekit-paywall.md` — the paywall always has a visible dismiss path and Restore Purchases; the core mission stays free.
- `rn/add-rn-notifications.md` — respect the 64-scheduled-notification ceiling with a rolling window; anything else silently drops reminders.
- `swift/add-apple-intelligence.md` — on-device AI ships only with a deterministic fallback path; availability is checked at runtime, not assumed.

Each recipe cites its gold-standard source — usually a path inside this repo's templates, verified by CI.

## The portfolio layer

This is the part most starter kits don't have: iApp assumes you'll ship **more than one app**, and gives your portfolio a memory.

- [`portfolio/PORTFOLIO.md`](portfolio/PORTFOLIO.md) — your shipped apps: mission, tech, identity, claimed palette, claimed motion. Skills read this to keep new apps *distinct* (no palette clashes, no mission overlaps, no identity monoculture).
- [`portfolio/MONETIZATION_MATRIX.md`](portfolio/MONETIZATION_MATRIX.md) — a 5-tier pricing ladder (pure-free gift → small lifetime IAP → standard IAP → subscription with lifetime escape → premium upfront) with the market data behind it, and a portfolio-mix check so you don't end up with five subscriptions and no funnel.
- [`portfolio/REUSE_INDEX.md`](portfolio/REUSE_INDEX.md) — which source is gold-standard for each feature. Starts as "the templates"; evolves as your own apps earn flags.
- [`portfolio/RECENT_LEARNINGS.md`](portfolio/RECENT_LEARNINGS.md) — a dated lesson log, pre-seeded with the app-agnostic lessons that shaped these templates.

When one of your apps improves on a template pattern, the `sync-from-portfolio` skill diffs your app's version against the template and prepares the PR that folds it back. That's the flywheel: every app you ship makes the next one start further ahead.

## The philosophy: what we don't build

iApp is opinionated. The templates and wizard will actively resist:

- Ads and ad-mediation SDKs
- Infinite scroll and engagement-maximizing notification strategies
- Shame-driven streaks ("you broke your streak 😢")
- Dark-pattern paywalls, fake urgency, pre-checked upsells
- Social graphs bolted onto tools

…and is explicitly *for* streaks-as-celebration, reminders that serve the user, rich notifications, honest paywalls, and gamification framed as care. The line between the two lists is the whole game — [docs/NOT_FOR.md](docs/NOT_FOR.md) and [docs/WHATS_ALLOWED.md](docs/WHATS_ALLOWED.md) draw it with worked examples so features don't get vetoed (or approved) by vibes.

## Shipping to the App Store

The repo carries release muscle, not just build muscle:

- **Checklists:** [docs/APP_STORE_CHECKLIST.md](docs/APP_STORE_CHECKLIST.md) and [docs/LAUNCH_AUDIT_CHECKLIST.md](docs/LAUNCH_AUDIT_CHECKLIST.md) cover metadata, privacy nutrition labels, screenshots, reviewer notes, and the fiddly Info.plist declarations that save you a rejection cycle.
- **Graphics:** `tools/app-store-graphics/` generates localized, exact-size App Store screenshots from real app captures.
- **Metadata conventions:** listing copy lives as JSON at `Marketing/AppStoreMetadata/<app>-app-store-metadata.json` (schema in `docs/schemas/`), within Apple's field limits (name 30 / subtitle 30 / keywords 100 bytes / description 4000).
- **Pre-flight:** the `apple-app-review` skill audits your archive and metadata against Apple's *current* review guidelines before you submit; templates ship `PrivacyInfo.xcprivacy` per target with tests that they actually land in the bundle.
- **Archiving:** `make archive` (Swift) / `npm run archive` (RN) produce the store-ready build; each template's `RELEASE.md` documents the app's release context.

## FAQ

**Do I need Claude/AI to use this?**
No. The AI skills are accelerators. Every artifact they produce is a plain file you can write by hand, and the templates build with standard tooling.

**Does it work with agents other than Claude Code?**
Yes. Claude Code reads `CLAUDE.md` natively; Codex and other AGENTS.md-reading agents get the same constitution via [`AGENTS.md`](AGENTS.md), and the skills are plain Markdown contracts any capable agent can execute (mirrored at `.agents/skills/`).

**Can I use just the template and ignore the planning system?**
Yes — `templates/swift` and `templates/rn` are self-contained. But try the decision docs once; the 30 minutes of writing routinely kills weeks of building the wrong thing.

**Is this only for solo developers?**
It's built from solo-developer experience, but the discipline (ADRs, reuse index, taste rules in CLAUDE.md) is exactly what keeps small teams from drifting too.

**Why are all the services disabled by default?**
Because every service you enable is a promise: an entitlement, a privacy disclosure, a maintenance surface. Opting in deliberately keeps the app honest about what it needs.

**What if my idea needs accounts, a backend, or multiplayer?**
Read [docs/AMBITIOUS_APPS.md](docs/AMBITIOUS_APPS.md) before you commit to that. Short version: Apple's built-in services (CloudKit sharing, Game Center, SharePlay) cover far more "multiplayer" than people expect — sharing with invited people, competing with friends — with zero servers and zero monthly bill. A true backend (strangers, feeds, realtime chat) is absolutely buildable, but it's a permanent commitment: accounts with in-app deletion, hosting bills that scale with success, content moderation, and privacy obligations. The wizard's intake step now classifies your idea's "ambition rung" and asks the money question early, not after you've built it.

**iOS only?**
The Swift template targets iOS (with Mac Catalyst opt-in). The RN template is iOS-first but Expo keeps the Android door open. The *planning* system is platform-agnostic.

**What iOS/tooling versions?**
The Swift template assumes current-generation Xcode and a recent iOS minimum; the RN template tracks a recent Expo SDK. Check each template's README for the exact pins.

## Contributing

Contributions are welcome — especially new recipes with honest "When NOT to use" sections, new palette seeds (with AAA-verified tokens), new visual identities (with proof), and lessons for the learnings log. Read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) first; the short version is that this repo values restraint, receipts, and taste over feature count. If a rule must hold, contribute the *test or script that enforces it*, not just the prose.

## License

[MIT](LICENSE). Build something people love.
