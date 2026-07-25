# Add Spotlight indexing

> **Source:** `templates/swift/Seed/Services/_Disabled/SpotlightService.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard.

## What it adds

A `SpotlightService` that indexes the app's entities into Core Spotlight, so the user can find their content from the system search field and tap straight back into the right screen. Also feeds Siri Suggestions.

## When to use

- The app holds **named, user-created content** worth finding by search — notes, saved trips, people, habits.
- Each indexed item has a **stable identity** and a **clear destination** to deep-link to.
- The content set is **bounded enough** to index without flooding (hundreds–thousands, not millions).

## When NOT to use

- **The app has no findable content.** A timer, a single-screen utility — nothing to index. Skip it.
- **Indexing ephemeral or sensitive items.** Don't index draft content, trashed items, or anything behind the biometric gate — Spotlight results are visible system-wide.
- **Without handling the deep link.** Indexing items the app can't navigate to on tap is a dead end — wire the `NSUserActivity` / `CSSearchableItem` continuation *first*.
- **Re-indexing everything on every launch.** Index on create/update, delete from the index on delete. A full re-index belongs behind a migration, not `didFinishLaunching`.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/SpotlightService.swift` for the minimal pattern; batch indexing + attribute richness are production-proven extensions of the same shape.
- In a generated app it ships in `Services/_Disabled/` — move it up to `<App>/Services/SpotlightService.swift`.

### 2. Wire

- **Index on write:** when an entity is created or updated, build a `CSSearchableItem` with a `CSSearchableItemAttributeSet` (title, content description, thumbnail) and a `uniqueIdentifier` that's the entity's stable ID. Call `CSSearchableIndex.default().indexSearchableItems(...)`.
- **De-index on delete:** `deleteSearchableItems(withIdentifiers:)` when the entity goes away. Orphaned index entries that 404 on tap are a bad look.
- **Continuation:** handle `userActivity(...)` / `onContinueUserActivity(CSSearchableItemActionType)` at the app root — extract the identifier, route the `NavigationRouter` to that entity.
- **Localized attributes:** the indexed `title` / `contentDescription` are user-visible in system search — they come from the entity's own (already localized-by-the-user) content, not hardcoded English.
- **Domain identifier:** group items under a `domainIdentifier` so you can bulk-clear a category.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# then on the simulator: create an item → swipe down for Spotlight → search its title → tap the result.
```

Expected: build green; the item appears in Spotlight; tapping it launches the app and routes to that exact item; deleting the item removes it from Spotlight.

## Gotchas

- Spotlight indexing is async and best-effort — there's a delay before an item appears, and no completion guarantee. Don't build UI that waits on it.
- The `uniqueIdentifier` must be **stable and collision-free** across the whole app — prefix it with the entity type (`note:<uuid>`), not just the bare UUID.
- A thumbnail in the attribute set makes the result far more tappable — but it's loaded eagerly; keep it small.
- If the app supports macOS, Core Spotlight works there too — but the continuation handling differs slightly; test both.
