import Foundation
import Testing

@Suite("App Intent localization boundaries")
struct AppIntentLocalizationBoundaryTests {
    @Test("Every semantic intent key has compiled English copy")
    func intentKeysAreCompiled() throws {
        let root = repositoryRoot
        let intentsRoot = root.appendingPathComponent("Seed/Intents")
        let enumerator = try #require(
            FileManager.default.enumerator(
                at: intentsRoot,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        )
        let keyExpression = try NSRegularExpression(
            pattern: #"\"(intent\.[A-Za-z0-9_.]+)\""#
        )
        var keys = Set<String>()

        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            let source = try String(contentsOf: fileURL, encoding: .utf8)
            let range = NSRange(source.startIndex..., in: source)
            for match in keyExpression.matches(in: source, range: range) {
                guard let keyRange = Range(match.range(at: 1), in: source) else { continue }
                keys.insert(String(source[keyRange]))
            }
        }

        #expect(!keys.isEmpty)

        let data = try Data(
            contentsOf: root.appendingPathComponent("Seed/Localizable.xcstrings")
        )
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)

        for key in keys.sorted() {
            let unit = try #require(
                catalog.strings[key]?.localizations["en"]?.stringUnit,
                "Missing English intent localization: \(key)"
            )
            #expect(unit.state == "translated", "Uncompiled intent localization: \(key)")
            #expect(!unit.value.isEmpty && unit.value != key, "Raw intent localization: \(key)")
        }
    }

    @Test("Every invocation phrase names the app")
    func shortcutPhrasesHaveApplicationNameToken() throws {
        let providerURL = repositoryRoot.appendingPathComponent(
            "Seed/Intents/SeedShortcutsProvider.swift"
        )
        let provider = try String(contentsOf: providerURL, encoding: .utf8)
        let phraseBlockExpression = try NSRegularExpression(
            pattern: #"phrases:\s*\[([\s\S]*?)\]"#
        )
        let stringExpression = try NSRegularExpression(pattern: #"\"([^\"]+)\""#)
        let providerRange = NSRange(provider.startIndex..., in: provider)
        let blocks = phraseBlockExpression.matches(in: provider, range: providerRange)

        #expect(!blocks.isEmpty)
        for block in blocks {
            guard let blockRange = Range(block.range(at: 1), in: provider) else { continue }
            let body = String(provider[blockRange])
            let bodyRange = NSRange(body.startIndex..., in: body)
            let phrases = stringExpression.matches(in: body, range: bodyRange).compactMap { match in
                Range(match.range(at: 1), in: body).map { String(body[$0]) }
            }
            #expect(!phrases.isEmpty)
            for phrase in phrases {
                #expect(
                    phrase.contains(#"\(.applicationName)"#),
                    "Shortcut invocation phrase must contain the application-name token: \(phrase)"
                )
            }
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
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
