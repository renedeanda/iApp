# Add CloudKit + SwiftData sync

> **Source:** `templates/swift/Seed/Services/_Disabled/DataController.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — the template ships the minimal baseline; the advanced extensions (migration handling, batch operations, background contexts) are proven in production.

## What it adds

A SwiftData stack backed by CloudKit's private database, so the user's data syncs across their devices automatically. The `DataController` owns the `ModelContainer`, configures the CloudKit container, and exposes the `ModelContext` the app reads/writes.

## When to use

- The app stores **user-owned data** that should follow them between iPhone, iPad, and Mac.
- The data model is **CloudKit-compatible** — every `@Model` property is a supported type, every `@Relationship` has an explicit inverse.
- You want sync to be **free of conflict UI** — CloudKit's last-writer-wins is acceptable for this data.

## When NOT to use

- **Shared / collaborative data.** Private-database sync is single-user. Multi-user sharing is a different (much larger) feature — `CKShare`, not this recipe.
- **Large binary blobs in records.** CloudKit caps a record at 1 MB. Big assets go in `CKAsset` (file-backed), referenced from the record — not inlined.
- **Data that must never be lost to a conflict.** Last-writer-wins silently drops the loser. If that's unacceptable, you need explicit conflict resolution — out of scope here.
- **Apps with no iCloud entitlement need.** If the data is device-local and disposable, a plain on-disk `ModelContainer` (no CloudKit) is simpler — don't add the entitlement for nothing.

## How

### 1. Harvest

- Source: start from `templates/swift/Seed/Services/_Disabled/DataController.swift` for a simple model; grow it with migration handling, batch operations, and background contexts as the app needs them (all production-proven extensions of the same shape).
- In a generated app it ships in `Services/_Disabled/` — graduate it when the wizard says yes.

### 2. Wire

- **Container:** `ModelContainer` configured with `.automatic` CloudKit database scope (`ModelConfiguration(cloudKitDatabase: .automatic)`).
- **Entitlements:** add the iCloud + CloudKit entitlement with container `iCloud.com.example.<app>`. The `.entitlements` stub ships with the template — uncomment the keys.
- **`@MainActor`:** any `@Observable` that touches the `ModelContext` is `@MainActor`. SwiftData `@Model` mutations off the main actor are a data race.
- **Relationships:** every `@Relationship` declares an explicit inverse and a delete rule. CloudKit rejects ambiguous graphs; a missing inverse also silently breaks sync.
- **Schema discipline:** CloudKit schema is **append-only in production**. You can add fields; you cannot rename or retype them. Plan the model before first ship.
- **Background context** for bulk imports — don't block the main actor on a 10k-record insert.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/DataControllerTests
xcodebuild build -scheme <App> -destination 'platform=macOS'
```

Expected: tests green; both platforms build with the iCloud entitlement. On two simulators signed into the same iCloud account, a write on one appears on the other within ~30 s.

## Gotchas

- The CloudKit schema is created lazily on first write in the **development** environment — you must explicitly deploy it to **production** in the CloudKit dashboard before App Store release, or shipped users get an empty container.
- `#Predicate` pushes the filter to SQLite; a `.filter {}` on a fetched array loads everything first. Always predicate `@Query`.
- First sync after install can take a while — show a loading/syncing state, don't render an empty list as if it's the truth.
