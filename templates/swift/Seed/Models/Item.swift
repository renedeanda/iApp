// SOURCE: iApp template — placeholder example.
//
// The wizard replaces this with the app's real model types at
// /new-app --commit time, per DECISIONS/008-data-model-and-sync.md.
// Kept tiny and obvious on purpose — it's a shape to copy, not code
// to keep.

import Foundation
import SwiftData

/// Placeholder persistent model. A real app's models live here
/// alongside it. When CloudKit sync is enabled (DECISIONS/004),
/// every `@Relationship` must declare an explicit inverse + delete
/// rule — CloudKit rejects ambiguous graphs.
@Model
final class Item {
    var title: String
    var createdAt: Date

    init(title: String, createdAt: Date = .now) {
        self.title = title
        self.createdAt = createdAt
    }
}
