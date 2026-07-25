// SOURCE: proven in a shipped production app.
//
// The conditional-modifier helper. Use sparingly — an `.if()` defeats
// SwiftUI's structural diffing, so reach for a real `if` in the view
// body when the branches differ in layout. `.if()` is for the case
// where only a modifier toggles.

import SwiftUI

extension View {
    /// Apply a modifier only when `condition` is true.
    ///
    /// Prefer a plain `if` in the body when the two branches produce
    /// different view *structure* — this helper is for toggling a
    /// single modifier, not for conditional layout.
    @ViewBuilder
    func `if`<Transformed: View>(
        _ condition: Bool,
        transform: (Self) -> Transformed
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
