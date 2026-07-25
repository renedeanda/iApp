# ADR 008 — Data Model and Sync

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling
- **Authors:** Kindling maintainers

## Context

Data model decisions baked in late cause migration pain. Sync strategy decisions made late cause CloudKit schema regrets. Both belong up front, even when "what's the data model" is "there isn't one yet" — that itself is a decision.

## Decision

**Kindling has no data model and no sync.** It's docs-on-disk in a git repo. The git history *is* the change log; GitHub *is* the persistence layer; no app reads or writes structured data from Kindling.

For child apps, this ADR is the worked example. The shape:

### Child app ADR 008 shape

```markdown
# ADR 008 — Data Model and Sync

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Decision

Data model: SwiftData (Swift) | AsyncStorage + native widget bridge (RN)
Sync: CloudKit (Swift) | the RN template's iCloud-bridge module | none

## Schema sketch (Swift, SwiftData)

@Model
final class Item {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date  // for CloudKit conflict resolution
    // ...
}

CloudKit container: iCloud.com.example.<name>
Sync zones: <default | custom shared zones if multi-user>
Conflict resolution: last-write-wins via updatedAt | <custom>

## Schema sketch (RN, iCloud bridge)

interface StoredItem {
  id: string  // UUIDv4
  title: string
  createdAt: number  // ms epoch
  updatedAt: number
}

iCloud key: com.example.<name>.items
Sync via templates/rn/modules/icloud-sync/ verbatim.

## Source for the harvest

See portfolio/REUSE_INDEX.md row "CloudKit + SwiftData" or "RN iCloud sync":
- Seed/Services/_Disabled/DataController.swift (Swift) — the template baseline
- templates/rn/modules/icloud-sync/ (RN) — verbatim copy

## Migrations

First version: no migrations.
Migration pattern when needed: SwiftData VersionedSchema chain
(documented per-app in this ADR's future "Migrations" section as it evolves)

## Privacy manifest implications

UserDefaults → reason CA92.1
FileTimestamp → reason C617.1
URLForUbiquityContainerIdentifier → no required-reason needed
(Update PrivacyInfo.xcprivacy when adding new required-reason APIs)
```

## Options considered

For Kindling itself:

- **Persist generated app metadata in a JSON manifest** — rejected. Git history is the source of truth for "what apps have we generated?"; `portfolio/PORTFOLIO.md` is the human-readable index. A separate JSON would drift from the markdown.
- **Use GitHub Issues for ADR drafts** — rejected. Drafts live in the local `drafts/<app-name>/` folder per the sleep rule (CLAUDE.md taste rule 6). GitHub Issues would publish drafts prematurely.
- **Use a database (SQLite / Fauna / Notion) to store decisions** — rejected. Git + Markdown is the data model. Anything else is overhead.

## Consequences

- **Unlocks:** Kindling stays grep-able and git-history-able forever.
- **Forecloses:** no real-time wizard state, no shared draft session. Each `/new-app --draft` is a solo session writing local files.
- **Cost to revisit:** small if we ever add real state (would be a new top-level dir + ADR 008 supersession).

## Cross-references

- [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — CloudKit + SwiftData and RN iCloud sync rows
- [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) — privacy manifest section
- [docs/APP_STORE_CHECKLIST.md](../docs/APP_STORE_CHECKLIST.md) — required-reason APIs
