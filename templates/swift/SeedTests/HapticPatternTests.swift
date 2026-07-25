import CoreHaptics
import Testing
@testable import Seed

/// Verifies every shipped haptic pattern parses correctly via
/// CoreHaptics. A malformed pattern dictionary fails at runtime when
/// the user triggers the haptic — catching it here means we ship
/// only patterns that actually work.
@Suite("Haptic patterns")
struct HapticPatternTests {
    @Test func everyActivePatternBuildsAValidCHHapticPattern() throws {
        for name in HapticPatterns.Named.allCases {
            #expect(throws: Never.self) {
                _ = try name.coreHapticsPattern()
            }
        }
    }

    @Test func patternCountIsWithinDiscipline() throws {
        let count = HapticPatterns.Named.allCases.count
        // Soft cap 8, hard cap 10 (CLAUDE.md taste rule 2 +
        // RECENT_LEARNINGS "Haptic vocabulary is a finite resource" lesson). Anything
        // beyond requires explicit reviewer sign-off.
        #expect(count <= 10, "Too many haptic patterns: \(count). Hard cap is 10. Use /earn-haptic for additions.")
    }
}
