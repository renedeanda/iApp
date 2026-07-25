# Add a collections data model (lists of structured things)

> **Source:** `templates/swift/Seed/Models/Item.swift` (the shape to extend) + `templates/swift/Seed/Models/DomainModels.swift` (the logic-layer counterpart) — confirm against [`REUSE_INDEX`](../../portfolio/REUSE_INDEX.md).
> **Platform:** Swift
> **Reliability:** ✅ gold-standard shape; the parent/child pattern below is production-proven.

## What it adds

The data backbone nearly every idea-stage app turns out to need: **collections of structured items with ordered children** — entries with steps, projects with tasks, logs with attachments, sessions with segments. One parent `@Model`, one child `@Model`, an explicit ordered relationship, and search that stays fast. Model it right on day 1 and every later feature (widgets, search, sync, export) reads cleanly; model it as loose strings and you'll be migrating within a month.

## When to use

- The app's core noun contains other nouns ("a ___ has several ___s") and their order matters.
- You want SwiftData persistence that will survive turning on CloudKit later.
- Users will search or filter the collection.

## When NOT to use

- **A flat list is enough.** If children never exist ("just a list of notes"), extend `Item.swift` alone — a parent/child graph you don't need doubles every query and migration.
- **The children are really just text.** If a "step" is one string with no state of its own, store `[String]` on the parent. Promote to a child `@Model` only when children need identity (done-flags, images, reorder).
- **You're modeling to feel productive.** The wizard's `DECISIONS/008-data-model-and-sync.md` asks for the model *after* the mission for a reason — model the smallest graph the first-sixty-seconds flow needs, not the app you imagine at v3.

## How

### 1. Harvest

- Read `templates/swift/Seed/Models/Item.swift` — note the header rule: **when CloudKit is on, every `@Relationship` declares an explicit inverse + delete rule.** Adopt that now even before sync, so enabling sync later is a checkbox, not a migration.

### 2. Wire

Add alongside `Item.swift` (rename to your domain — kept generic here):

```swift
@Model
final class Collection {
    var title: String
    var createdAt: Date
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \Entry.collection)
    var entries: [Entry] = []

    init(title: String, notes: String = "", createdAt: Date = .now) {
        self.title = title; self.notes = notes; self.createdAt = createdAt
    }
}

@Model
final class Entry {
    var text: String
    var sortIndex: Int          // explicit order — SwiftData arrays don't persist order reliably
    var isDone: Bool
    var collection: Collection?

    init(text: String, sortIndex: Int, isDone: Bool = false) {
        self.text = text; self.sortIndex = sortIndex; self.isDone = isDone
    }
}
```

- Register both types in the `ModelContainer` in `SeedApp.swift`.
- **Order is `sortIndex`, always.** Read children as `entries.sorted { $0.sortIndex < $1.sortIndex }`; on reorder, rewrite indexes in one pass. Never trust array order across launches.
- **Search:** use a `#Predicate` on the parent's `title` + `notes` via `@Query`; for child-text search, query `Entry` directly rather than walking every parent.
- Keep computation (progress %, validation, dedupe) in a Sendable engine over `DomainModels.swift`-style value types — see [add-sendable-engine](add-sendable-engine.md) — not in the `@Model` classes.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: build green; add one round-trip test — create a Collection with 3 Entries, reorder, refetch, assert `sortIndex` order survived.

## Gotchas

- CloudKit requires all relationship properties optional or defaulted, and rejects ambiguous graphs — the explicit `inverse:` above is what saves you.
- `.cascade` on the parent's relationship is almost always right (children die with the parent); the default `.nullify` leaves orphan rows your data-deletion flow must remember (see [docs/ICLOUD_DATA_DELETION.md](../../docs/ICLOUD_DATA_DELETION.md)).
- Renaming a `@Model` property after shipping is a migration. Naming things generically now (`Entry.text`, not `Entry.stepText`) buys flexibility cheaply.
