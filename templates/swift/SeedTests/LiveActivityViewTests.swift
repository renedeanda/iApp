import Foundation
import Testing

/// Verifies the Live Activity widget implements all five required
/// presentations: lock-screen body, compact leading, compact trailing,
/// minimal, and the expanded Dynamic Island region.
///
/// Live Activities crash silently in production when a presentation is
/// missing — the iOS process simply doesn't render that surface,
/// leaving an empty Dynamic Island state. Apple's runtime does NOT
/// give you a build warning for the omission.
///
/// This test scans the widget target's Live Activity Swift sources
/// for the four keyword-checkable presentations (the lock-screen body
/// is the activity view's root and is always present when
/// ActivityConfiguration is declared). The expanded region check is
/// satisfied by any DynamicIslandExpandedRegion (apps choose which
/// subregions to use — leading/center/trailing/bottom — per their UX).
/// Skips gracefully when no Live Activity exists.
///
/// Per portfolio/REUSE_INDEX.md "Live Activities + Dynamic Island"
/// row: harvest the LA view from the template's own proven scaffold
/// only — never from an unproven source.
@Suite("Live Activity regions")
struct LiveActivityViewTests {
    @Test func liveActivityImplementsAllFivePresentations() throws {
        let widgetDir = widgetSourceDirectory()

        guard FileManager.default.fileExists(atPath: widgetDir.path) else {
            // Widget extension not enabled — Live Activities can't
            // exist without one.
            return
        }

        let allFiles = try swiftFiles(in: widgetDir)
        let liveActivityFiles = allFiles.filter { url in
            guard let contents = try? String(contentsOf: url, encoding: .utf8) else { return false }
            return contents.contains("ActivityConfiguration")
        }

        guard !liveActivityFiles.isEmpty else {
            // No Live Activity in this app.
            return
        }

        // Four keyword-checkable presentations. The fifth — the
        // lock-screen body — is the ActivityConfiguration root view
        // itself and is structurally always present.
        let requiredPresentations: [String] = [
            "compactLeading:",
            "compactTrailing:",
            "minimal:",
            "DynamicIslandExpandedRegion",
        ]

        for url in liveActivityFiles {
            let source = try String(contentsOf: url, encoding: .utf8)
            for presentation in requiredPresentations {
                #expect(
                    source.contains(presentation),
                    "\(url.lastPathComponent): Live Activity missing presentation '\(presentation)'"
                )
            }
        }
    }

    // MARK: - helpers

    private func widgetSourceDirectory() -> URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SeedWidgets")
    }

    private func swiftFiles(in directory: URL) throws -> [URL] {
        let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        var result: [URL] = []
        while let item = enumerator?.nextObject() as? URL {
            if item.pathExtension == "swift" {
                result.append(item)
            }
        }
        return result
    }
}
