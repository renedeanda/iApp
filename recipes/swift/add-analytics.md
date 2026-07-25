# Add analytics (TelemetryDeck)

> **Source:** `templates/swift/Seed/Services/_Disabled/AnalyticsService.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — the signal taxonomy is production-proven and worth preserving.

## What it adds

An `AnalyticsService` wrapping TelemetryDeck: a privacy-respecting, anonymous, aggregate-only analytics layer. The app sends named signals at meaningful moments; the service centralizes the signal taxonomy so naming stays consistent.

## When to use

- You need to know **whether a feature is used** to decide if it earns its weight.
- The signals are **aggregate and anonymous** — counts and funnels, not user tracking.
- The app already has a TelemetryDeck app ID (or will get one before launch — the wizard leaves a `// TODO(telemetry): set app id` marker).

## When NOT to use

- **Any other analytics SDK without an ADR.** TelemetryDeck and Sentry are the *only* pre-approved analytics deps. Anything else needs `DECISIONS/NNN-dependency-<name>.md`.
- **Per-user tracking, identifiers, or PII.** TelemetryDeck is anonymous-by-design — don't fight that. No emails, no user IDs, no precise locations in signals.
- **Vanity signals.** "app_opened" with no follow-through question is noise. Every signal should answer a question you'll actually act on.
- **Signals on a hot path.** Don't fire a signal inside a scroll handler or a per-frame callback.
- **Blocking on the network.** Signal sends are fire-and-forget; never `await` one in a user-facing flow.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/AnalyticsService.swift` — read it for the `send(_:parameters:)` shape, the `markFirstUseAndShouldSend(_:)` once-per-install guard, the `paywallTriggered(_:)` convenience, and the pseudonymous-ID + opt-out plumbing.
- Copy into: `<App>/Services/AnalyticsService.swift`. Ships in `Services/_Disabled/` — graduate when the wizard says yes.
- **Naming convention:** signal names are `<noun>.<verb>` strings (e.g. `note.created`, `paywall.triggered`, `purchase.completed`) — domain-first so they group cleanly on a dashboard. Parameters are a `[String: String]` of low-cardinality enums/buckets/bools/counts only. (The reference implementation uses strings, not a Swift enum — keep them few and stable; renaming a signal breaks that metric's continuity.)

### 2. Wire

- **App ID:** set the TelemetryDeck app ID. The wizard leaves `// TODO(telemetry): set app id` — replace it, and add the launch-readiness checkbox.
- **Signal enum:** all signal names live in one enum/namespace — no string literals at call sites. This is the taxonomy discipline.
- **Call sites:** `AnalyticsService.shared.send(.feature_export_used)` — one line, fire-and-forget.
- **Opt-out:** if the app exposes an analytics toggle in Settings, the service checks it before sending. Settings-configurable means actually respected.
- **DEBUG:** the service no-ops (or logs to console only) in DEBUG builds so dev runs don't pollute production data.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
grep -rn 'TelemetryDeck.signal\|\.send(' <App>/ | grep -v AnalyticsService.swift
```

Expected: build green; the second command returns **nothing** — every signal goes through `AnalyticsService`, no raw `TelemetryDeck.signal(...)` calls scattered in views.

## The standard funnel (the bar)

An app is **well-instrumented** when it answers the questions that actually drive product + monetization decisions — not just "did it launch." Wire this canonical set (adapt the core-action noun to the app's domain):

| Group | Signals | Notes |
|---|---|---|
| **Lifecycle** | `app.launched` (+ `app.openedFromURL` / `.fromSpotlight` / `.fromWidget` where relevant) | one launch signal, with a `platform` param on multiplatform apps |
| **Onboarding** | `onboarding.started`, `onboarding.completed` | the activation funnel — where you lose people |
| **Core action** | the app's primary verb: `note.created` / `habit.logged` / `card.created` / `dayLogged` | fire at the **single source of truth** (the model/service method), not per-view |
| **Feature adoption** | `feature.firstUse` (param `feature`) | guarded by `markFirstUseAndShouldSend(_:)` so it fires once per install — tells you which features get discovered |
| **Paywall funnel** | `paywall.triggered` (param `trigger`) → `paywall.viewed` → `paywall.dismissed` | the `trigger` names which gated feature/limit opened it — this is the attribution that tells you *what sells* |
| **Purchase funnel** | `purchase.started` → `purchase.completed` / `.failed` / `.cancelled` / `.restored` | fire all of these from `SubscriptionManager`; `completed` alone can't compute conversion |
| **Limits** | `free.limit.hit` (param `limit`) | the moment a free user hits a wall — the strongest upgrade signal |
| **Settings** | `settings.theme.changed`, `settings.appIcon.changed`, `settings.icloud.toggled` | cheap, and tells you which cosmetics are worth the build cost |

**Coverage tiers (from a portfolio-wide instrumentation audit):**
- **well-instrumented** — the full funnel above is wired.
- **half-wired** — SDK + some events, but the paywall trigger and/or purchase funnel are missing. This is the most expensive blind spot — you can't see what converts — and the most common one an audit finds.
- **init-only** — SDK configured + opt-out UI present but only `app.launched` fires. Infrastructure with no signal.

The cheapest high-value fix is almost always the **paywall + purchase funnel** — wire it first.

## Silent-by-design variants (privacy-first apps)

An app can ship without transmitting for a launch — but **keep the full taxonomy wired** so flipping transmission on later is a one-function change. Two sanctioned holding patterns:

- **OSLog-only / DEBUG-gated**: the full taxonomy is defined and called, but `send()` writes to `os.Logger` only, `#if DEBUG`. No third-party SDK. To go live: add the SPM dep + swap the `send()` body to `TelemetryDeck.signal(...)`, add a `configure()` call + an opt-out toggle.
- **No-op stub**: every call site is wired but `signal()` early-returns. To go live: add the TelemetryDeck SPM dep and replace the no-op body. The taxonomy is already there.

> **The "one-function change" claim is proven.** Two shipped production apps — one OSLog-only, one a no-op stub — both graduated to live TelemetryDeck with exactly the swap above, plus the SPM dep, a `TelemetryDeckAppID` Info.plist key, a `configure()` call, and a Settings opt-out toggle. Because the taxonomy was already wired, the change was small. If you graduate a privacy-forward app, update its CLAUDE.md Dependencies + Privacy Stance, keep `NSPrivacyTracking` false (TelemetryDeck is anonymous, no IDFA), and **declare Product Interaction / Usage Data in App Store Connect → App Privacy**.

A truly zero-telemetry app has **no AnalyticsService at all** — that can be a product-spine decision (a privacy moat), not a gap. Don't "fix" it.

## Gotchas

- TelemetryDeck signal names are effectively a public schema for *you* — renaming one breaks the continuity of that metric. Name them carefully once.
- The `// TODO(telemetry)` marker is intentionally not a build error (it would block the scaffold) — it's on the launch-readiness checklist instead. Don't ship without resolving it.
- Don't send a signal's *payload* with high-cardinality values (note titles, free text) — TelemetryDeck aggregates, high cardinality just makes noise.
