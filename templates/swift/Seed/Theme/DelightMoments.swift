// SOURCE: new — Seed template; the code home for the app's delight moments.
//
// Every portfolio app picks 3–5 delight moments (DECISIONS/014, via
// `/pick-delight-moments`). This file is where those moments live as
// *code* — the parallel of `SignatureMotion.swift` for the signature
// motion. RECENT_LEARNINGS 2026-05-21 named the gap: the wizard filed
// the delight ADR and never closed the loop to code, so moments #2–5
// produced nothing. They have a home now.
//
// It ships the recurring, reusable delight PATTERNS from the
// DELIGHT_REEL as working, Reduce-Motion-aware modifiers behind stable
// `View` extension APIs. `/wire-first-screen` applies the chosen ones
// to the real first screen's action surfaces; an app-specific bespoke
// moment is added here as one more modifier, never scattered inline.
//
// Every moment degrades to a tasteful static state under Reduce Motion
// — the same rule `SignatureMotion.swift` follows.

import SwiftUI

extension View {
    /// Delight: the **operation-complete result reveal** — a result or
    /// success view settling in with a soft scale-up + fade. Apply it
    /// to a view that is *inserted* on completion, inside a parent that
    /// animates the insertion (`motionSafeAnimation` on a phase value).
    ///
    /// Reduce Motion drops the scale and keeps a plain crossfade.
    func resultReveal() -> some View {
        modifier(ResultRevealModifier())
    }

    /// Delight: a brief, low-amplitude **celebration pop** when
    /// `trigger` changes — for completion and milestone moments (a
    /// finished operation, a streak hit). A ~320 ms spring that crests
    /// and settles back to rest; dropped entirely under Reduce Motion.
    func celebrationPop(_ trigger: some Equatable) -> some View {
        modifier(CelebrationPopModifier(trigger: trigger))
    }
}

/// The result-reveal transition. A `ViewModifier` rather than a bare
/// `.transition(...)` so it can read Reduce Motion.
struct ResultRevealModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.transition(
            reduceMotion
                ? .opacity
                : .scale(scale: 0.96).combined(with: .opacity)
        )
    }
}

/// The celebration-pop modifier — a one-shot scale crest keyed to a
/// trigger. Holds the static rest state (scale 1.0) under Reduce
/// Motion; the pop is dropped entirely, never a partial.
struct CelebrationPopModifier<Trigger: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let trigger: Trigger

    @State private var popped = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(popped && !reduceMotion ? 1.06 : 1.0)
            .motionSafeAnimation(
                .spring(response: 0.32, dampingFraction: 0.55),
                value: popped
            )
            .onChange(of: trigger) {
                guard !reduceMotion else { return }
                popped = true
                // Settle back once the spring has crested.
                Task {
                    try? await Task.sleep(for: .milliseconds(170))
                    popped = false
                }
            }
    }
}
