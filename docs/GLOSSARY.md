# Glossary — iOS Development, Decoded

New to iOS development? This page decodes the jargon you'll meet in this repo, in Xcode, and in Apple's docs. Terms are grouped by when you'll first bump into them.

## Getting started

| Term | What it actually means |
|---|---|
| **Xcode** | Apple's IDE (editor + compiler + simulator + device tools in one app). The only officially supported way to build iOS apps. Free on the Mac App Store; huge download; launch it once after installing so it finishes setup. |
| **Simulator** | A fake iPhone/iPad that runs on your Mac. Good enough for 90% of development. Things it can't do: haptics, real camera, push notifications from Apple's servers, true performance numbers. |
| **SwiftUI** | Apple's modern UI framework — you describe what the screen should look like and it keeps it up to date. The Swift template is 100% SwiftUI. |
| **Swift** | Apple's programming language. Not related to Taylor. |
| **React Native (RN)** | A framework for building native apps in JavaScript/TypeScript. **Expo** is the toolchain that makes RN dramatically easier (builds, updates, modules). The RN template uses Expo. |
| **XcodeGen** | A tool that generates the Xcode project file (`.xcodeproj`) from a readable `project.yml`. Why: `.xcodeproj` files are merge-conflict nightmares; `project.yml` is reviewable text. Run `xcodegen generate` after changing it. |
| **Bundle ID** | Your app's globally-unique identifier, written in reverse-DNS style: `com.yourname.yourapp`. Placeholder in this repo is `com.example.seed` — you'll replace it. Pick one and never change it after shipping. |

## Building and running

| Term | What it actually means |
|---|---|
| **Target** | One buildable thing in a project. Your app is a target; its widget extension is another target; its tests are a third. |
| **Scheme** | A named recipe for building/running targets (which target, debug vs release). The template ships one scheme named after the app. |
| **Entitlements** | A signed list of special permissions your app claims (iCloud, App Groups, push). Lives in `.entitlements` files. Wrong entitlements = features silently fail. |
| **App Group** | A shared storage container that lets your app and its widget read the same data (`group.com.example.yourapp`). Widgets can't read the app's normal storage — this is the bridge. |
| **Info.plist** | The app's metadata manifest: display name, permission-prompt texts, supported orientations, and declarations like `ITSAppUsesNonExemptEncryption`. |
| **SwiftData / CloudKit** | Apple's local database layer (SwiftData) and its iCloud sync backend (CloudKit). Together: data that persists and follows the user across devices, using *their* iCloud storage — you run no servers. |
| **Widget extension** | A separate mini-program bundled inside your app that renders Home/Lock Screen widgets. Separate target, separate bundle — which is why it needs its **own** string catalog (a classic trap this repo tests for). |
| **Live Activity** | The live-updating card on the Lock Screen / Dynamic Island (delivery tracking, timers). Built with WidgetKit. |
| **Localizable.xcstrings** | Xcode's string catalog — every piece of UI text lives here with its translations. Never hardcode English in views; the templates' tests enforce this. |

## Money and accounts

| Term | What it actually means |
|---|---|
| **Apple ID vs Developer Program** | An Apple ID (free) lets you build and run on the Simulator and your own device. The Apple Developer Program ($99/yr) is required to ship on TestFlight or the App Store. Don't pay until you're ready to ship. |
| **Team ID** | A 10-character identifier for your developer account (visible in your Apple Developer membership page). The templates use the placeholder `YOURTEAMID`. |
| **StoreKit 2** | Apple's modern in-app-purchase framework. The template's `SubscriptionManager.swift` wraps it; the `.storekit` file lets you test purchases in the Simulator without real money or a paid account. |
| **IAP** | In-App Purchase. "Lifetime IAP" = pay once, own forever — this repo's default recommendation over subscriptions unless you have real server costs. |
| **Restore Purchases** | The button that re-grants prior purchases on a new device. Apple requires it to be findable; this repo requires it to be *visible*. |

## Shipping

| Term | What it actually means |
|---|---|
| **Provisioning profile** | A signed file tying your app + your certificates + (for dev builds) specific devices together. Xcode's "Automatically manage signing" handles this — leave it on until you have a reason not to. |
| **Archive** | The release build you upload to Apple (`make archive` in the templates). Produces an `.xcarchive`, which Xcode's Organizer uploads. |
| **TestFlight** | Apple's beta-distribution service: up to 100 internal / 10,000 external testers, builds expire after 90 days. |
| **App Store Connect (ASC)** | The web dashboard where you create your app record, fill in metadata, upload screenshots, answer the privacy questionnaire, and submit for review. |
| **App Review** | Apple's human + automated review of every submission, typically 24–48h. The `apple-app-review` skill in this repo audits your build against the current guidelines *before* you submit. |
| **Privacy nutrition label** | The "App Privacy" section on your store page, declared in ASC. Backed in code by `PrivacyInfo.xcprivacy` files — one per target, and the templates' tests verify they actually ship. |
| **App Store metadata** | Name (30 chars), subtitle (30), keywords (100 bytes), description (4,000). This repo stores it as JSON under `Marketing/AppStoreMetadata/` — see `docs/schemas/launch-packet.v1.schema.json`. |

## This repo's own vocabulary

| Term | What it actually means |
|---|---|
| **ADR / decision doc** | Architecture Decision Record — a short numbered Markdown file (000–016) capturing one decision and *why*. The wizard writes them into `drafts/<app>/`; they ship with the app. |
| **The wizard** | The `/new-app` skill: 21 design-first questions → 17 ADRs → sleep → rendered app. |
| **Seed** | The placeholder app name inside both templates. `make bootstrap NAME=YourApp` (Swift) / editing `app.json` (RN) renames it everywhere. |
| **`Services/_Disabled/`** | Production-ready services shipped dormant. Enabling one is a deliberate act: move it up a directory, uncomment its imports, add the entitlement it names. |
| **Signature motion** | The *one* motion principle your app is known by, chosen in ADR 009 and wired as real code in `Theme/SignatureMotion.swift`. |
| **Delight moment** | A specific micro-animation tied to a specific user action (max 5 per app). Catalog in [DELIGHT_REEL.md](DELIGHT_REEL.md). |
| **Earned haptic** | Apps start with 3 haptic patterns; each additional one requires a written justification via `/earn-haptic`. |
| **Palette seed / departure delta** | You never ship a catalog palette verbatim — you pick a seed and record your bespoke changes (the delta) in ADR 002. |
| **Launch packet** | The conventions for release artifacts (metadata JSON, screenshot directories, reviewer notes) that make shipping repeatable. |
| **Reuse index** | [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — the map of which source is gold-standard for each feature, so you never harvest from a known-broken source. |

Something missing? PRs that add a term a beginner actually stumbled on are very welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
