import Foundation
import Testing

/// Verifies every widget view uses `containerBackground(for: .widget)`
/// (iOS 17+ edge-to-edge requirement) rather than `.background(...)`
/// directly on the root view.
///
/// Apple's widget runtime applies its own corner radius + safe areas;
/// using plain `.background(...)` produces clipped widgets that look
/// awful on iOS 17+. The fix is `containerBackground(for: .widget)`.
///
/// This test scans the widget target's source files for the anti-pattern.
/// Skips gracefully when no widget extension exists (default template
/// state — widget target commented out in project.yml).
@Suite("Widget edge-to-edge")
struct WidgetEdgeToEdgeTests {
    @Test func widgetViewsUseContainerBackground() throws {
        let widgetDir = widgetSourceDirectory()

        guard FileManager.default.fileExists(atPath: widgetDir.path) else {
            // Widget extension not enabled.
            return
        }

        let widgetFiles = try swiftFiles(in: widgetDir)
        guard !widgetFiles.isEmpty else { return }

        for url in widgetFiles {
            let source = try String(contentsOf: url, encoding: .utf8)
            // The simplistic check: if the file declares a Widget view
            // and uses `.background(` *without* a sibling
            // `containerBackground(for: .widget)`, flag it.
            let isWidgetView = source.contains(": Widget {") || source.contains(": WidgetConfiguration")
            guard isWidgetView else { continue }

            let usesContainerBackground = source.contains("containerBackground(for: .widget)")
            #expect(
                usesContainerBackground,
                "\(url.lastPathComponent): widget views must use .containerBackground(for: .widget) for iOS 17+ edge-to-edge."
            )
        }
    }

    // MARK: - helpers

    private func widgetSourceDirectory() -> URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SproutWidgets")
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
