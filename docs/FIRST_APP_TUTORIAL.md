# Your First App — A Complete Walkthrough

This tutorial takes you from "I cloned the repo" to "my own renamed app is running on the Simulator with my own accent color" — with zero prior iOS experience assumed. Budget 60–90 minutes including downloads.

Jargon is decoded in the [Glossary](GLOSSARY.md) — keep it open in a tab.

> **Using an AI agent?** Open this repo in a Claude Code or Codex session and run `/start` — the agent will walk you through this same path interactively and fix hiccups as they happen. This document is the manual version of that experience.

## Part 0 — Setup (one-time)

1. **Install Xcode** from the Mac App Store. It's big (~10 GB). While it downloads, keep reading.
2. **Launch Xcode once.** Accept the license and let it install its components. When asked about platforms, make sure **iOS** is selected.
3. **Install Homebrew** (the Mac package manager) if you don't have it — instructions at [brew.sh](https://brew.sh).
4. **Install XcodeGen:**
   ```sh
   brew install xcodegen
   ```
5. Optional, for the React Native path: install **Node.js LTS** from [nodejs.org](https://nodejs.org).

## Part 1 — Run the template as-is (10 minutes)

Prove your toolchain works before personalizing anything.

```sh
git clone <this-repo-url> Kindling
cd Kindling/templates/swift
xcodegen generate
open Seed.xcodeproj
```

In Xcode:

1. In the toolbar's device menu (top center), pick any iPhone Simulator (e.g. "iPhone 17 Pro").
2. Press **⌘R** (Product → Run).

First build takes a couple of minutes. Then a Simulator boots and you should see the **Seed** starter app: an onboarding flow, a home screen, and a Settings screen with appearance options and a (sandbox) paywall.

**Poke around before moving on.** Toggle dark mode inside the app's Settings — notice the whole palette flips (that's the `dynamic(light:dark:)` token system). Open the paywall — notice Restore Purchases is visible and dismissing is obvious. This is the taste baked in.

> **Something failed?**
> - `xcodegen: command not found` → Homebrew's bin isn't on your PATH; restart the terminal.
> - Signing errors → select the `Seed` target → *Signing & Capabilities* → check "Automatically manage signing" and select your (free) Apple ID team.
> - Simulator missing → Xcode → Settings → Platforms → download an iOS runtime.

## Part 2 — Make it yours (10 minutes)

Never build a real app on the `Seed` name — and never build *inside* the Kindling repo. Your app gets its own folder (and its own repo) next to Kindling ([why](YOUR_OWN_REPO.md)). Copy the template out and rename it in one step:

```sh
cd ../..                          # back to the Kindling repo root
cp -r templates/swift ../my-first-app
cd ../my-first-app
make bootstrap NAME=Sprout BUNDLE=com.yourname.sprout
open Sprout.xcodeproj
```

(Substitute your own app name and reverse-DNS bundle ID. No spaces in NAME.)

`make bootstrap` runs `bin/rename-template.sh`, which rewrites every `Seed` token — file names, target names, bundle IDs, App Group, iCloud container, strings — then regenerates the project. Press **⌘R** again: same app, now called **Sprout**, yours.

Make it a real repo of its own (create a blank **private** repo on GitHub first, then):

```sh
git init && git add -A && git commit -m "Sprout: initial scaffold from Kindling"
git remote add origin git@github.com:<you>/my-first-app.git
git push -u origin main
```

## Part 3 — Your first real change: the palette (15 minutes)

1. Open `Sprout/Theme/AppTheme.swift`. You'll see tokens like:
   ```swift
   static let surface = dynamic(light: 0xF7F2EA, dark: 0x1B1712)
   ```
   Colors are hex *integers*: a catalog value like `#EAEBE0` becomes `0xEAEBE0`.
2. Pick a seed from [`portfolio/PALETTE_CATALOG.md`](../portfolio/PALETTE_CATALOG.md) (back in the Kindling repo) — say **Sage**.
3. Replace the accent and surface tokens with the seed's values (light *and* dark — every token carries both), then *change something on purpose* — nudge the accent's saturation or hue. That's the "departure delta" habit: the catalog proposes, you decide.
4. **⌘R.** The whole app re-skins — buttons, links, onboarding — because every view reads tokens instead of hardcoding colors.
5. Run the tests: **⌘U** (Product → Test). `ThemeContrastTests` will *fail your build* if your new text/background pairing dropped below AAA contrast. If it fails, darken the text token or lighten the surface until it passes. This is the guardrail system working for you.

Write down what you picked and why — two sentences is plenty. The template copy doesn't include a `DECISIONS/` folder (the wizard normally creates it), so make one: copy `DECISIONS/002-palette.md` from the Kindling repo into your app's `DECISIONS/` folder and fill in your values. Future-you will thank you.

## Part 4 — Turn on your first service (10 minutes)

Everything optional ships dormant in `Sprout/Services/_Disabled/`. Example — haptics:

1. Move `HapticManager.swift` from `Services/_Disabled/` up into `Services/`.
2. Open it and follow the one-line header comment (uncomment the import if noted).
3. Run `xcodegen generate` if you moved files outside Xcode, then **⌘R**.
4. Call a pattern from a button action, e.g. `HapticManager.shared.play(.completionRing)` (the 3 starter patterns are `bloomOpen`, `completionRing`, `reminderSoft`) — run on a **real iPhone** to feel it (Simulator can't do haptics).

The same move-up-and-enable ritual applies to notifications, CloudKit, analytics, biometrics — each names the entitlement or Info.plist key it needs. Enable only what your app's mission demands.

## Part 5 — The React Native path (alternative)

If JavaScript is home, the same first hour looks like:

```sh
cd Kindling/templates/rn
npm install
npx expo start          # press "i" for the iOS Simulator
```

Then personalize: edit `app.json` (name, slug, `bundleIdentifier`), restart Expo, and change the palette in `theme/AppTheme.ts` — the theme context re-skins every screen. Run `npm test` and the same class of guardrails (contrast, localization parity, the 64-notification limit) checks your work.

## Part 6 — Where to go next

- **Put it on your actual iPhone** — free, ten minutes, and the single most motivating step: [ON_YOUR_IPHONE.md](ON_YOUR_IPHONE.md). (Stuck on tooling or accounts at any point? [SETUP.md](SETUP.md) is the full environment guide.)
- **Have an app idea?** Go back to the Kindling repo and run the wizard — `/new-app --draft` in an AI session, or fill in `DECISIONS/` by hand (start at `000-mission.md`). The design questions are the highest-value hour in this repo.
- **Want a feature?** Find it in [`recipes/`](../recipes/) — widgets, iCloud sync, paywall, notifications, App Intents — and read its "When NOT to use" first.
- **Ready to ship?** [`docs/APP_STORE_CHECKLIST.md`](APP_STORE_CHECKLIST.md) is the path from working app to submitted app.
- **Learning Swift properly?** Apple's [Develop in Swift](https://developer.apple.com/tutorials/develop-in-swift) then [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui).

You now have a running, renamed, re-themed app with tests protecting your taste. That's further than most side projects ever get.
