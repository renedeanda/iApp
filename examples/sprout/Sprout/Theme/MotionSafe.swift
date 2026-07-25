// SOURCE: proven in a shipped production app.
// motionSafeAnimation() wrapper respecting UIAccessibility.isReduceMotionEnabled.

import SwiftUI
import UIKit

extension View {
    /// Wraps `animation(_:value:)` with Reduce Motion gating.
    /// Use this everywhere instead of bare `.animation(...)` — the
    /// motion-safe rule from CLAUDE.md is enforced
    /// here, not at the call site.
    ///
    /// When Reduce Motion is on, returns `self` unchanged — the
    /// animation is dropped but the value change still happens
    /// (so the end state is reached, just without the in-between).
    @ViewBuilder
    func motionSafeAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V
    ) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            self
        } else {
            self.animation(animation, value: value)
        }
    }
}
