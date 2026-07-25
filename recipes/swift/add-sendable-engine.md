# Add a pure Sendable engine

> **Source:** *pattern described inline* — an engine architecture proven in a shipped production app (four small engines: recommendation, compliance, cost, currency). Confirm reuse conventions against [REUSE_INDEX](../../portfolio/REUSE_INDEX.md).
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — this is the reference architecture for domain logic.

## What it adds

A value-type "engine" that holds the app's domain logic — recommendations, compliance checks, cost math — with **zero UI imports**, fully `Sendable`, fully testable in isolation. The UI talks to it through an `@Observable` `@MainActor` service; the engine itself never imports SwiftUI or touches a `@Model`.

## When to use

- The app has **non-trivial domain logic** worth testing without a UI — calculations, rule evaluation, recommendations.
- You want that logic **parallelizable / cacheable / reusable** across surfaces (app, widget, intent) without dragging UI in.
- The logic is **deterministic** given its inputs — same inputs, same output.

## When NOT to use

- **Trivial logic.** A one-line transform doesn't need an engine. Three similar lines beat a premature abstraction.
- **Logic that's inherently stateful + UI-bound.** Navigation state, selection, focus — that's a `@MainActor` service or view state, not an engine.
- **Anything that needs `@Model` access.** Engines take plain value types in and return value types out. If it needs to fetch from SwiftData, the *service* fetches and hands the engine plain structs.
- **As a dumping ground.** "EngineManager" that does everything is the anti-pattern. One engine, one bounded concern (the proving app shipped four small ones, not one big one).

## How

### 1. Harvest

- The shape (proven in production): a `struct`, `Sendable`, pure functions, value-type inputs/outputs.
- Copy the *pattern*, not a file — engines are app-specific. Use the Wire section below as the structural template.

### 2. Wire

- **Value type:** `struct <Name>Engine: Sendable`. No `class`, no UI imports, no `@Model` references.
- **Pure methods:** every method takes value types and returns value types. No side effects, no I/O, no `Date()` calls inside (inject `now` as a parameter — see the RN `NotificationService` for the same discipline).
- **The service layer:** a separate `@Observable @MainActor` service owns the engine instance, fetches the `@Model` data, maps it to the engine's value-type inputs, calls the engine, and publishes the result for the UI.
- **One concern per engine:** if it's growing two unrelated responsibilities, split it. Four small focused engines beat one big one — that's the production proof.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/<Name>EngineTests
```

Expected: the engine is tested with **no UI harness at all** — pure inputs, asserted outputs, edge cases enumerated. If a test needs a `@MainActor` or a `ModelContainer`, the logic leaked into the engine; pull it back out.

## Gotchas

- Injecting `now: Date = Date()` (default param) keeps the engine pure *and* ergonomic — tests pass a fixed date, callers omit it.
- `Sendable` conformance is the compiler's proof the engine is data-race-free. If you have to `@unchecked Sendable` it, something mutable leaked in — fix that instead.
- The engine returning a rich result type (an enum with associated values, not a bare `Bool`) keeps the call sites honest and the tests meaningful.
