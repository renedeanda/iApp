# ADR 014 — Delight Moments

- **Status:** Accepted
- **App:** Sprout
- **Authors:** worked example (Kindling)

## The picks (3 of 5 allowed)

| Moment | Fires on | Reduce Motion fallback |
|---|---|---|
| **Result reveal** (`.resultReveal()`) | A win lands in the list | Row appears settled, no rise |
| **Celebration pop** (`.celebrationPop`) | A run reaches 7 days | Static badge state |
| **Breathing idle tile** (signature motion, counted honestly) | Home tile at rest | Static tile, accent-tinted |

## Why only three

Five-second interactions can't carry five delights. The cap protects the two that matter: logging must *feel* rewarding (reveal), and the weekly compounding must *feel* earned (pop). A 4th requires an ADR addendum per the house rule.

Implementation: `Sprout/Theme/DelightMoments.swift`; picks wired by `/wire-first-screen`. Catalog: docs/DELIGHT_REEL.md.
