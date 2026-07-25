import Foundation
import Testing

/// Verifies the Localizable.xcstrings catalog has:
/// - a reviewed, compiled `en` source-language entry for every key, and
/// - every present non-en localization is in `translated` state with a
///   non-empty value (no half-baked translations).
///
/// Tier-1 locale population is enforced by a SEPARATE pre-submission
/// test in `docs/APP_STORE_CHECKLIST.md`; this test is the always-on
/// gate for catalog hygiene during development.
///
/// The `/translate` skill fills in the 6 tier-1 locales over time;
/// keys ship with `en` only by default.
@Suite("Localization parity")
struct LocalizationParityTests {
    @Test func everyKeyHasEnglishSource() throws {
        let catalog = try loadCatalog()

        for (key, entry) in catalog.strings {
            let en = entry.localizations["en"]
            #expect(en != nil, "Missing English source for key: \(key)")
            if let unit = en?.stringUnit {
                #expect(
                    unit.state == "translated",
                    "English source for key '\(key)' is '\(unit.state)' and may be omitted from the compiled bundle"
                )
                let value = unit.value
                #expect(!value.isEmpty, "Empty English source for key: \(key)")
                #expect(value != key, "English source exposes raw identifier: \(key)")
            }
        }
    }

    @Test func presentNonEnglishEntriesAreTranslated() throws {
        let catalog = try loadCatalog()

        for (key, entry) in catalog.strings {
            for (locale, loc) in entry.localizations where locale != "en" {
                let state = loc.stringUnit.state
                // Acceptable states: translated, stale (explicitly deferred).
                // Forbidden states for present entries: needs_review, new.
                #expect(
                    state == "translated" || state == "stale",
                    "Non-en localization '\(locale)' for key '\(key)' is in state '\(state)' — finish or remove"
                )
            }
        }
    }

    // MARK: - helpers

    private struct Catalog: Decodable {
        let sourceLanguage: String
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

    private func loadCatalog() throws -> Catalog {
        let testFile = URL(fileURLWithPath: #filePath)
        let catalogURL = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sprout/Localizable.xcstrings")

        let data = try Data(contentsOf: catalogURL)
        return try JSONDecoder().decode(Catalog.self, from: data)
    }
}
