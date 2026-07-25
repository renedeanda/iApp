// SOURCE: proven in a shipped production app.
// Index app entities for Spotlight + Siri suggestions.

import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

/// Index app entities for Spotlight + Siri Suggestions.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// `spotlight`. Index domain entities the user might search (notes,
/// reminders, items, etc.) but NEVER index sensitive content unless
/// the user opts in.
///
/// Source pattern: minimal baseline proven in a shipped production
/// app; extend to full indexing as the app's content grows.
@MainActor
final class SpotlightService {
    static let shared = SpotlightService()

    private let index = CSSearchableIndex.default()

    private init() {}

    /// Index a single entity. `id` should be globally unique (use
    /// the SwiftData PersistentIdentifier.description or a UUID).
    func index(
        id: String,
        title: String,
        contentDescription: String?,
        keywords: [String] = []
    ) async {
        let attributes = CSSearchableItemAttributeSet(contentType: UTType.text)
        attributes.title = title
        attributes.contentDescription = contentDescription
        attributes.keywords = keywords

        let item = CSSearchableItem(
            uniqueIdentifier: id,
            domainIdentifier: Bundle.main.bundleIdentifier,
            attributeSet: attributes
        )

        try? await index.indexSearchableItems([item])
    }

    /// Remove an indexed entity.
    func remove(id: String) async {
        try? await index.deleteSearchableItems(withIdentifiers: [id])
    }

    /// Wipe the entire app's index.
    func removeAll() async {
        try? await index.deleteAllSearchableItems()
    }
}
