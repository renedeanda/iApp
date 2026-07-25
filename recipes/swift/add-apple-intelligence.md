# Add Apple Intelligence (Foundation Models)

> **Source:** `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard for the **gating pattern**. The consumer UI around it is app-specific — design your own surfaces rather than copying someone else's.

## What it adds

An on-device LLM capability via the `FoundationModels` framework, wrapped in a service that is **availability-checked, Pro-gated, and always has a deterministic fallback**. The app gains a smart feature (summarize, suggest, rewrite) that costs nothing per call, runs offline, and degrades gracefully on ineligible devices.

## When to use

- The feature genuinely benefits from natural-language generation or understanding, and a deterministic version would be meaningfully worse.
- You have a **deterministic fallback** ready — a rules-based or template-based path the caller uses when the model is unavailable.
- The feature is acceptable as a **Pro-gated** capability (Foundation Models is a premium-feeling feature; it also justifies the gate).

## When NOT to use

- **No fallback designed.** If the feature simply doesn't exist on a non-Apple-Intelligence device, that's an experience cliff. Every AI call must have a `nil`-return path the caller handles. Design the fallback first.
- **The deterministic version is just as good.** Don't reach for the model to look modern. If a `DateFormatter` or a lookup table does the job, use that.
- **Latency-critical paths.** On-device generation has real latency. Don't put it between a tap and a screen the user is waiting on without a loading state.
- **You're shipping the AI output to a widget / Live Activity surface.** Combine that with the bundle-localization trap and you get raw keys rendering on the Lock Screen. Keep AI output in the app.
- **Treating availability as a one-time check.** `LanguageModel.isAvailable` can change (Apple Intelligence toggled off, device thermal state). Check at call time, not just at launch.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift` — the gating wrapper. Read the whole file; the value is the structure, not the prompts.
- In a generated app it lives at `<App>/Services/_Disabled/OnDeviceAIService.swift` by default — graduate it when the wizard says yes.

### 2. Wire

- **Compile-time gate:** `#if canImport(FoundationModels)` around the import and the model-using code, so the app still compiles for older SDKs.
- **Runtime gate:** check `LanguageModel.isAvailable` (or the framework's current availability API) at **call time**. Branch to the fallback when false.
- **Pro gate:** the service checks `SubscriptionManager.shared.isPro` before offering the AI path. Non-Pro users get the deterministic fallback silently — no nag.
- **Fallback path:** every public method returns an optional or has a `deterministic:` sibling. The caller never assumes the model answered.
- **No UI imports** in the service — it's pure logic. UI talks to it via an `@Observable` `@MainActor` wrapper if it needs to publish loading state.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild build -scheme <App> -destination 'generic/platform=iOS'   # confirms the #if canImport guard compiles both ways
```

Expected: both builds green. On a simulator without Apple Intelligence, the feature exercises the fallback path with no crash and no empty UI.

## Gotchas

- `FoundationModels` availability is **not** the same as iOS version — it depends on device class + the user's Apple Intelligence setting. Never gate on `#available(iOS ...)` alone.
- The model's output is non-deterministic; don't write tests that assert exact strings. Test the fallback path deterministically and the AI path structurally (non-nil, within length bounds).
- Thermal throttling: under sustained load the model can become unavailable mid-session. The runtime check at call time catches this.
