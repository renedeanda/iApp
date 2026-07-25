import Foundation
import Testing

@Suite("BYOK model policy")
struct BYOKModelPolicyTests {
    @Test func templateCarriesCurrentCostConsciousCatalog() throws {
        let source = try catalogSource()

        for modelID in [
            "claude-sonnet-5", "claude-haiku-4-5", "claude-opus-5",
            "gpt-5.6-terra", "gpt-5.6-luna", "gpt-5.6-sol",
            "gemini-3.6-flash", "gemini-3.5-flash-lite", "gemini-3.1-pro-preview",
        ] {
            #expect(source.contains("id: \"\(modelID)\""), "Missing curated BYOK model: \(modelID)")
        }
    }

    @Test func fableIsExcludedAndMigratedToSonnet() throws {
        let source = try catalogSource()

        #expect(!source.contains("displayName: \"Claude Fable 5\""))
        #expect(source.contains("case (.anthropic, \"claude-fable-5\"):"))
        #expect(source.contains("return defaultModelID"))
    }

    private func catalogSource() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sprout/Services/_Disabled/BYOKModelCatalog.swift")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
