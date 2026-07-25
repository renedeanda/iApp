import Foundation
import Testing

/// Verifies `Assets.xcassets/AppIcon.appiconset/Contents.json` declares
/// every iOS app icon size Apple requires. Catches the "missing icon
/// size" App Store rejection before submission.
///
/// Required sizes (per Apple HIG, iOS 17+):
/// - 1024×1024 marketing
/// - 60×60 @2x and @3x for iPhone (Settings, Spotlight, Notification)
/// - 76×76 @2x and 83.5×83.5 @2x for iPad
/// - 167×167 (iPad Pro), 152×152 (iPad)
///
/// The Contents.json manifest is parsed directly from the source tree
/// (via `#filePath`) so this test runs against the canonical asset
/// catalog, not a compiled bundle artifact.
@Suite("AppIcon assets")
struct AppIconAssetTests {
    @Test func appIconManifestDeclaresAllRequiredSizes() throws {
        let json = try loadIconContents()
        let entries = json.images

        // The universal / platform:ios 1024 entry is the modern
        // single-size App Store icon — it carries NO scale key (actool
        // rejects a scaled universal entry). The device-specific slots
        // still use explicit scales.
        let required: [(idiom: String, size: String, scale: String?)] = [
            ("universal", "1024x1024", nil),
            ("iphone",    "60x60",     "2x"),
            ("iphone",    "60x60",     "3x"),
            ("ipad",      "76x76",     "2x"),
            ("ipad",      "83.5x83.5", "2x"),
        ]

        for slot in required {
            let match = entries.contains { entry in
                entry.idiom == slot.idiom
                && entry.size == slot.size
                && (slot.scale == nil || entry.scale == slot.scale)
            }
            #expect(match, "Missing AppIcon slot: idiom=\(slot.idiom) size=\(slot.size) scale=\(slot.scale ?? "n/a")")
        }
    }

    // MARK: - helpers

    private struct IconContents: Decodable {
        let images: [IconEntry]
    }

    private struct IconEntry: Decodable {
        let idiom: String
        let size: String
        let scale: String?
    }

    private func loadIconContents() throws -> IconContents {
        let testFile = URL(fileURLWithPath: #filePath)
        let manifest = testFile
            .deletingLastPathComponent() // SeedTests/
            .deletingLastPathComponent() // template root
            .appendingPathComponent("Seed/Assets.xcassets/AppIcon.appiconset/Contents.json")

        let data = try Data(contentsOf: manifest)
        return try JSONDecoder().decode(IconContents.self, from: data)
    }
}
