# ADR 009 — Signature Motion

- **Status:** Accepted
- **App:** Sprout
- **Authors:** worked example (Kindling)

## Decision

**Breathing** — the template default, kept *deliberately*: a slow 4s scale oscillation (1.0 → 1.015) on the idle home tile. A tool about growth should feel alive at rest, not animated in use.

Timing: `easeInOut(duration: 4).repeatForever(autoreverses: true)` via `.signatureMotion()`.
Reduce Motion fallback: tile renders static at 1.0 — presence conveyed by the accent-tinted surface instead.

## Why not more

Logging takes five seconds; motion during the act would tax the act. The one moment that earns animation is the result reveal (see 014/DelightMoments), which is a delight moment, not the signature.
