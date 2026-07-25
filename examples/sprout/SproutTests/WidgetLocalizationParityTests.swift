import Foundation
import Testing

/// The widget-localization-trap test.
///
/// Widget / Live Activity / Control Center extension surfaces load
/// strings from the **extension's own** bundle, not the host app's.
/// A production app we shipped keyed its widgets only in the app's
/// `Localizable.xcstrings`; the result was widget surfaces showing the
/// raw key string in every locale because the extension couldn't
/// resolve them. See portfolio/RECENT_LEARNINGS.md for the lesson.
///
/// This test:
/// - Locates the widget extension's own xcstrings (if a widget target
///   exists), and verifies every string used in widget views has a
///   key declared there.
/// - Skips gracefully when no widget extension is present (default
///   template state — widget target commented out in project.yml).
///
/// Per docs/WIDGETS.md rule 2 + REUSE_INDEX "Native widgets" row:
/// harvest widgets from the template's own proven scaffold only.
@Suite("Widget localization parity")
struct WidgetLocalizationParityTests {
    @Test func widgetCatalogCoversWidgetStrings() throws {
        let catalogURL = widgetCatalogURL()

        guard FileManager.default.fileExists(atPath: catalogURL.path) else {
            // Widget extension not enabled — nothing to verify.
            // Will return without expectation; test passes trivially.
            return
        }

        let data = try Data(contentsOf: catalogURL)
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)

        for (key, entry) in catalog.strings {
            let en = entry.localizations["en"]
            #expect(en != nil, "Widget xcstrings missing English source for key: \(key)")
            if let unit = en?.stringUnit {
                #expect(
                    unit.state == "translated",
                    "Widget English source for key '\(key)' may be omitted from the compiled extension bundle"
                )
                #expect(!unit.value.isEmpty && unit.value != key)
            }
        }

        let sourceKeys = try widgetSourceKeys()
        #expect(!sourceKeys.isEmpty)
        for key in sourceKeys.sorted() {
            #expect(catalog.strings[key] != nil, "Widget source key missing from extension catalog: \(key)")
        }

        let projectURL = widgetCatalogURL()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("project.yml")
        let project = try String(contentsOf: projectURL, encoding: .utf8)
        #expect(project.contains("path: SproutWidgets/Resources/Localizable.xcstrings"))
        #expect(project.contains("path: SproutWidgets/PrivacyInfo.xcprivacy"))
    }

    private func widgetCatalogURL() -> URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SproutWidgets/Resources/Localizable.xcstrings")
    }

    private func widgetSourceKeys() throws -> Set<String> {
        let widgetRoot = widgetCatalogURL()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let enumerator = try #require(
            FileManager.default.enumerator(
                at: widgetRoot,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        )
        let expression = try NSRegularExpression(pattern: #"\"(widget\.[A-Za-z0-9_.]+)\""#)
        var keys = Set<String>()

        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            let source = try String(contentsOf: fileURL, encoding: .utf8)
            let range = NSRange(source.startIndex..., in: source)
            for match in expression.matches(in: source, range: range) {
                guard let keyRange = Range(match.range(at: 1), in: source) else { continue }
                keys.insert(String(source[keyRange]))
            }
        }
        return keys
    }

    private struct Catalog: Decodable {
        let strings: [String: Entry]
    }

    private struct Entry: Decodable {
        let localizations: [String: Localization]
    }

    private struct Localization: Decodable {
        let stringUnit: StringUnit
    }

    private struct StringUnit: Decodable {
        let state: String
        let value: String
    }
}
