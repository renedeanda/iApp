# ADR 001 — Tech Choice

- **Status:** Accepted
- **App:** Sprout
- **Authors:** worked example (Kindling)

## Decision

**Swift/SwiftUI**, from `templates/swift`. iOS-only, no Mac Catalyst.

## Why

- The five-second log lives or dies on a Home-screen widget and a lock-screen-fast app open — native surfaces are the product.
- SwiftData + (later, opt-in) CloudKit covers persistence with zero infra.
- No Android ambition: a pocket gesture, not a platform.

## Consequences

Widget target enabled at render (`DECISIONS/004`); everything else stays in `Services/_Disabled/` until earned.
