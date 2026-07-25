// SOURCE: new — Seed template; the app's ONE signature motion.
//
// Every portfolio app has a single signature motion (DECISIONS/009).
// This file is where that motion lives as *code*. The wizard closes
// the ADR→code loop here: `/wire-first-screen` reads ADR 009 at
// `/new-app --commit` and either keeps this default or rewrites the
// modifier body to implement the chosen principle, then applies
// `.signatureMotion()` to the first screen.
//
// The template ships the warm-minimal default — Breathing (idle) — so
// a generated app is never motion-dead the way Phase 1 apps were
// (the ADR existed; the code did not).

import SwiftUI

extension View {
    /// Applies the app's signature motion (DECISIONS/009). Pass
    /// `active: false` to hold the static rest state while a sheet or
    /// operation is in flight — the ADR's "idle only" firing rule.
    ///
    /// This entry point and the `active:` contract are STABLE — when
    /// `/wire-first-screen` rewrites the motion for a non-breathing
    /// app, it changes `SignatureMotionModifier`'s body, never this
    /// signature, so call sites never change.
    func signatureMotion(active: Bool = true) -> some View {
        modifier(SignatureMotionModifier(active: active))
    }
}

/// The default signature motion: **Breathing (idle)** — a slow,
/// low-amplitude scale + opacity oscillation. Warm-minimal's calm made
/// visible: the app at rest, asking nothing while you're not using it.
///
/// `/wire-first-screen` replaces this struct's `body` when an app
/// picks a different principle (Bloom, Parallax-recede, …); the
/// `.signatureMotion()` entry point above stays put.
///
/// Reduce Motion holds the static rest state (scale 1.0 / opacity 1.0)
/// — the animation is dropped entirely, never a partial.
struct SignatureMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let active: Bool

    @State private var inhaled = false

    private var engaged: Bool { active && !reduceMotion && inhaled }

    func body(content: Content) -> some View {
        content
            .scaleEffect(engaged ? 1.012 : 1.0)
            .opacity(engaged ? 0.97 : 1.0)
            .motionSafeAnimation(
                engaged
                    ? .easeInOut(duration: 3).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 0.3),
                value: engaged
            )
            .onAppear { inhaled = true }
    }
}
