// SOURCE: iApp template
// Alternative specimen; swap in via /pick-typography. Excluded from compile.

import SwiftUI

/// Serif specimen — New York system serif, weight-led hierarchy.
///
/// Excluded from compilation by `project.yml`. The wizard copies into
/// `Theme/Typography.swift` (renaming `SerifSpecimen` -> `Typography`)
/// when `DECISIONS/011-typography.md` picks the serif specimen.
///
/// Best for typographic-led + monochrome-luxe identities.
enum SerifSpecimen {
    static let display           = Font.system(size: 34, weight: .bold,     design: .serif)
    static let title             = Font.system(size: 28, weight: .semibold, design: .serif)
    static let headline          = Font.system(size: 17, weight: .semibold, design: .serif)
    static let body              = Font.system(size: 17, weight: .regular,  design: .serif)
    static let bodyEmphasized    = Font.system(size: 17, weight: .semibold, design: .serif)
    static let caption           = Font.system(size: 13, weight: .regular,  design: .serif)
    static let captionEmphasized = Font.system(size: 13, weight: .semibold, design: .serif)
}
