// SOURCE: proven in a shipped production app.
// Glass material under floating bars; iOS 18+ Glass effect.

import SwiftUI

/// Liquid Glass material — a signature pattern proven in a shipped
/// production app, available as
/// an opt-in modifier so other identities can ignore it.
///
/// Apply under floating bars (toolbars, FABs, sheets) when the app's
/// visual identity is glassmorphic (per `DECISIONS/015-visual-identity.md`).
/// No-op when Reduce Transparency is on — falls back to a solid
/// secondary-surface fill that preserves the chrome's z-order
/// without the translucency.
///
/// Source pattern: simplified single-tint variant; the full production
/// pattern also handles adaptive tint based on scroll offset.
struct LiquidGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let tint: Color

    func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(AppTheme.surfaceSecondary)
        } else {
            content.background(
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    Rectangle().fill(tint.opacity(0.05))
                }
            )
        }
    }
}

extension View {
    /// Apply Liquid Glass material with an optional tint color.
    /// Default tint is `AppTheme.accent` — pass another color for
    /// surfaces that want a warmer or cooler glass.
    func liquidGlass(tint: Color = AppTheme.accent) -> some View {
        modifier(LiquidGlassModifier(tint: tint))
    }
}
