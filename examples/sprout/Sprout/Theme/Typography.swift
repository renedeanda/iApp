// SOURCE: proven in a shipped production app.
// 7-token semantic type scale; never use .system(size:) directly.

import SwiftUI

/// The 7-token type system. Views always go through these tokens —
/// never call `.system(size:)` directly. Enforced by swiftlint +
/// ThemeContrastTests.
///
/// This file holds the *active* specimen. The two unchosen specimens
/// (one of rounded / serif / mono) stay at
/// `Theme/_TypographySpecimens/` as references; the wizard moves the
/// chosen one here at `/new-app --commit` time per
/// `DECISIONS/011-typography.md`.
///
/// Default ships rounded-system to fit the warm-minimal default
/// (a pairing proven in shipped production apps).
enum Typography {
    static let display = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyEmphasized = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
    static let captionEmphasized = Font.system(size: 13, weight: .semibold, design: .rounded)
}

/// Semantic icon sizes keep glyph hierarchy consistent without view-level
/// `.system(size:)` calls. The wizard may tune these with the chosen identity.
enum IconSize {
    static let medium = Font.system(size: 28, weight: .regular)
    static let hero = Font.system(size: 64, weight: .regular)
}
