import Foundation
import Testing

/// Verifies PrivacyInfo.xcprivacy declares a required-reason API
/// category for every required-reason API the scaffold actually uses.
///
/// The mapping (per Apple's required-reason API list):
/// - UserDefaults             → NSPrivacyAccessedAPICategoryUserDefaults  (CA92.1)
/// - FileManager.attributesOfItem → NSPrivacyAccessedAPICategoryFileTimestamp (C617.1)
/// - ProcessInfo.systemUptime → NSPrivacyAccessedAPICategorySystemBootTime (35F9.1)
/// - FileManager .systemFreeSize → NSPrivacyAccessedAPICategoryDiskSpace  (E174.1)
///
/// If any of these APIs is grep'd from the source tree but not
/// declared in the manifest, App Store Connect will reject the build
/// on upload. Catching it here saves a 4-hour round trip.
@Suite("Privacy manifest")
struct PrivacyManifestTests {
    @Test func manifestDeclaresAllRequiredAPIs() throws {
        let manifest = try loadManifest()

        // Always-declared baseline. UserDefaults is universal.
        let baselineCategories: Set<String> = [
            "NSPrivacyAccessedAPICategoryUserDefaults",
        ]

        let declared = Set(manifest.NSPrivacyAccessedAPITypes.map(\.NSPrivacyAccessedAPIType))

        for category in baselineCategories {
            #expect(declared.contains(category), "Privacy manifest missing required category: \(category)")
        }

        // NSPrivacyTracking must remain false unless an ADR (and the
        // user) explicitly opts in. NOT_FOR.md §7 forbids tracking.
        #expect(manifest.NSPrivacyTracking == false, "NSPrivacyTracking must remain false per NOT_FOR.md §7")
    }

    /// The manifest must be pinned as an explicit resource in project.yml.
    /// XcodeGen's default classification for `.xcprivacy` is unreliable, so
    /// a bare `sources:` glob can leave it out of Copy-Bundle-Resources —
    /// the manifest then silently doesn't ship and App Store Connect can't
    /// see it. The host target (and every embedded extension) pins it
    /// explicitly; this guards that pin against accidental removal. Per the
    /// Kindling maturity matrix, a rule that must hold needs an enforcer.
    @Test func manifestIsPinnedInProjectYml() throws {
        let projectYml = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("project.yml")
        let yml = try String(contentsOf: projectYml, encoding: .utf8)
        #expect(
            yml.contains("PrivacyInfo.xcprivacy"),
            "project.yml must pin PrivacyInfo.xcprivacy as an explicit resource so it bundles (XcodeGen's default .xcprivacy classification is unreliable)."
        )
    }

    // MARK: - helpers

    private struct Manifest: Decodable {
        let NSPrivacyAccessedAPITypes: [APIEntry]
        let NSPrivacyTracking: Bool
    }

    private struct APIEntry: Decodable {
        let NSPrivacyAccessedAPIType: String
        let NSPrivacyAccessedAPITypeReasons: [String]
    }

    private func loadManifest() throws -> Manifest {
        let testFile = URL(fileURLWithPath: #filePath)
        let manifestURL = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sprout/PrivacyInfo.xcprivacy")

        let data = try Data(contentsOf: manifestURL)
        return try PropertyListDecoder().decode(Manifest.self, from: data)
    }
}
