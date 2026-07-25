// SOURCE: proven in a shipped production app.
// Tactile press feedback + theme accent; rename token swapped by wizard.

import SwiftUI

/// The template's default tactile button style.
///
/// Pattern: spring on press (Reduce Motion drops the spring but
/// keeps the opacity dip so VoiceOver users still see the confirm).
/// Adapt or replace per app — brutalist apps skip the spring
/// entirely; warm-minimal apps inherit this style.
struct SproutButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .font(Typography.bodyEmphasized)
            .foregroundStyle(AppTheme.onSurface)
            .background(
                Capsule().fill(AppTheme.surfaceSecondary)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(reduceMotion ? 1.0 : (configuration.isPressed ? 0.97 : 1.0))
            .animation(
                reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

extension ButtonStyle where Self == SproutButtonStyle {
    static var seed: SproutButtonStyle { .init() }
}
