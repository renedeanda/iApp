// SOURCE: Kindling template
// Alternative specimen; swap in via /pick-typography. Excluded from compile.

import SwiftUI

/// Mono-leaning specimen — monospaced body, default sans for headings.
///
/// Excluded from compilation by `project.yml`. The wizard copies into
/// `Theme/Typography.swift` (renaming `MonoSpecimen` -> `Typography`)
/// when `DECISIONS/011-typography.md` picks the mono specimen.
///
/// Best for brutalist + kinetic-type identities. Proven in a shipped
/// production app (body data in monospace, headlines in
/// SF Pro Display Condensed).
enum MonoSpecimen {
    static let display           = Font.system(size: 34, weight: .heavy,    design: .default).width(.condensed)
    static let title             = Font.system(size: 28, weight: .bold,     design: .default).width(.condensed)
    static let headline          = Font.system(size: 17, weight: .semibold, design: .default)
    static let body              = Font.system(size: 17, weight: .regular,  design: .monospaced)
    static let bodyEmphasized    = Font.system(size: 17, weight: .semibold, design: .monospaced)
    static let caption           = Font.system(size: 13, weight: .regular,  design: .monospaced)
    static let captionEmphasized = Font.system(size: 13, weight: .semibold, design: .monospaced)
}
