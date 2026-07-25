// SOURCE: iApp portfolio/CROSS_PROMO_REGISTRY.json
//
// Loads the studio's cross-promotion list from a bundled JSON copy of
// iApp's `portfolio/CROSS_PROMO_REGISTRY.json`. Vendor that file into
// the app's Resources (Copy Bundle Resources) as `CrossPromoRegistry.json`
// and refresh it when the portfolio changes.
//
// Apple-compliant: `liveApps` returns ONLY apps with a real App Store URL, so
// unreleased siblings auto-hide and appear the moment they ship. The current
// app excludes itself by bundle identifier.

import Foundation

struct PortfolioApp: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let bundleID: String
    let appStoreURL: String
}

enum PortfolioRegistry {
    private struct Payload: Decodable {
        let studioName: String
        let studioURL: String
        let apps: [PortfolioApp]
    }

    private static let payload: Payload? = {
        guard let url = Bundle.main.url(forResource: "CrossPromoRegistry", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(Payload.self, from: data)
        else { return nil }
        return decoded
    }()

    /// The studio "Made with care" destination (always available).
    static let studioURL = URL(string: payload?.studioURL ?? "https://example.com")
    static var studioName: String { payload?.studioName ?? "Your Studio" }

    /// Sibling apps that are live on the App Store, excluding this app.
    /// Returns [] when nothing else is live yet — callers hide the section.
    static func liveApps(excludingBundleID bundleID: String = Bundle.main.bundleIdentifier ?? "") -> [PortfolioApp] {
        (payload?.apps ?? [])
            .filter { !$0.appStoreURL.isEmpty && $0.bundleID != bundleID }
    }
}
