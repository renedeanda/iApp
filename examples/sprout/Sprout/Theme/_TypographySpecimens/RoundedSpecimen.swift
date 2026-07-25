// SOURCE: Kindling template
// Warm-minimal default specimen; swap in via /pick-typography. Excluded from compile.

import SwiftUI

/// Rounded-system specimen — the warm-minimal default.
///
/// Excluded from compilation by `project.yml`. The wizard at
/// `/new-app --commit` copies these tokens into `Theme/Typography.swift`
/// (renaming `RoundedSpecimen` -> `Typography`) when
/// `DECISIONS/011-typography.md` picks the rounded specimen.
///
/// Best for warm-minimal + glassmorphic identities. Proven in
/// shipped production apps.
enum RoundedSpecimen {
    static let display           = Font.system(size: 34, weight: .bold,     design: .rounded)
    static let title             = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline          = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body              = Font.system(size: 17, weight: .regular,  design: .rounded)
    static let bodyEmphasized    = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let caption           = Font.system(size: 13, weight: .regular,  design: .rounded)
    static let captionEmphasized = Font.system(size: 13, weight: .semibold, design: .rounded)
}
