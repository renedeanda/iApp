// SOURCE: Kindling template — placeholder example.
//
// Pure value-type domain models — the inputs/outputs a Sendable
// engine works with (see recipes/swift/add-sendable-engine.md).
// SwiftData `@Model` types (Item.swift) are the persistence layer;
// these are the logic layer. Keep them `Sendable`, UI-import-free.

import Foundation

/// Example value-type domain model. A Sendable engine takes these in
/// and returns these out — no `@Model`, no SwiftUI, no side effects.
struct DomainItem: Identifiable, Sendable, Hashable, Codable {
    let id: UUID
    var title: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

/// Example rich result type — engines return enums with associated
/// values, not bare Bools, so call sites stay honest.
enum DomainResult: Sendable, Equatable {
    case empty
    case ready([DomainItem])
    case needsAttention(reason: String)
}
