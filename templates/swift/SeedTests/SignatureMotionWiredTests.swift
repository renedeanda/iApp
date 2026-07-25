import Foundation
import Testing

/// Hard gate for the signature-motion ADR→code loop.
///
/// RECENT_LEARNINGS "An ADR that produces no code is a gap": a motion ADR (`DECISIONS/009`) that
/// produces no `.signatureMotion()` call site is the Phase-1 bug — the
/// decision exists, the felt motion does not. `Theme/SignatureMotion.swift`
/// is the modifier's code home; this test fails the build unless
/// something actually applies it to a screen.
///
/// It is always-on (no widget/Live-Activity condition): it runs in
/// every child app's CI and inside `/validate-template` against the
/// rendered VerifyApp, so a template regression that drops the call
/// site is caught before any child app inherits it.
@Suite("Signature motion wired")
struct SignatureMotionWiredTests {
    /// `Theme/SignatureMotion.swift` must exist — the ADR→code home.
    @Test func signatureMotionFileExists() {
        let modifier = Self.repoRoot
            .appendingPathComponent("Seed/Theme/SignatureMotion.swift")
        #expect(
            FileManager.default.fileExists(atPath: modifier.path),
            "Theme/SignatureMotion.swift is missing — the signature-motion ADR has no code home"
        )
    }

    /// Something must apply `.signatureMotion()` — an ADR with no call
    /// site is a motion that was decided but never felt.
    @Test func signatureMotionIsApplied() {
        let views = Self.repoRoot.appendingPathComponent("Seed/Views")
        let applied = Self.swiftFiles(in: views).contains { file in
            guard let source = try? String(contentsOf: file, encoding: .utf8) else {
                return false
            }
            return source.contains(".signatureMotion(")
        }
        #expect(
            applied,
            "No .signatureMotion() call site under Seed/Views — DECISIONS/009 produced an ADR but no wired code (see RECENT_LEARNINGS: an ADR that produces no code is a gap)"
        )
    }

    // MARK: - helpers

    /// The rendered repo root — this test sits in `<App>Tests/`, so two
    /// levels up is the repo. (`rename-template.sh` rewrites `Seed`.)
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private static func swiftFiles(in directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
    }
}
