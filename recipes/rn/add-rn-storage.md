# Add a typed storage wrapper (RN)

> **Source:** *pattern described inline* — a ~13.5 KB typed storage wrapper proven in a shipped production RN app (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — type-safe wrapper with namespacing + migration support.

## What it adds

A `StorageService` over `@react-native-async-storage/async-storage`: typed get/set with namespaced keys, JSON (de)serialization handled, schema-version migration support, and a single audited surface instead of raw `AsyncStorage` calls scattered across the app.

## When to use

- The app persists **local, non-secret state** — preferences, cached data, a "seen onboarding" flag, draft content.
- You want **type safety** on persisted values, not `string | null` everywhere.
- The persisted shape will **evolve** and you need a migration path.

## When NOT to use

- **Secrets.** Auth tokens, API keys, credentials → the secure store, not AsyncStorage. (Expo: `expo-secure-store`. AsyncStorage is plaintext.)
- **Large datasets / relational data.** AsyncStorage is a key-value store with real size limits. A growing list of records belongs in SQLite (`expo-sqlite`) or a synced store — see [add-rn-icloud-sync](add-rn-icloud-sync.md).
- **High-frequency writes.** Every `setItem` is an async disk write. Don't call it on every keystroke or scroll — debounce.
- **Raw `AsyncStorage` calls alongside it.** The whole value is the single audited surface. A raw call bypasses the namespace, the typing, and the migration.

## How

### 1. Harvest

- The shape (proven in production): a namespacing convention, a typed key registry, and a migration runner — all specified in Wire below.
- Create: `src/services/StorageService.ts`.

### 2. Wire

- **Key registry:** all storage keys are a typed enum/const — no string literals at call sites. Keys are namespaced (`<app>.<domain>.<name>`).
- **Typed accessors:** `StorageService.get<T>(key)` / `set<T>(key, value)` handle `JSON.stringify`/`parse`. A `get` of a missing key returns a typed default, not `null`-soup.
- **Migrations:** a `schemaVersion` key + an ordered list of migration functions. On launch, the service runs any migrations between the stored version and the current one. This is what lets the persisted shape evolve safely.
- **Errors:** AsyncStorage can fail (disk full, corruption) — the service catches and returns the default rather than throwing into render.
- **No secrets:** if a value is sensitive, it goes through `expo-secure-store` instead — the service does not store secrets, by policy.

### 3. Verify

```sh
npx jest
npm run typecheck
```

Expected: type-clean; round-trip get/set tests pass; a migration test confirms an old-schema blob is upgraded correctly on read.

## Gotchas

- AsyncStorage is **not** synchronous — there's no `getItemSync`. Any code that needs a persisted value at first render must handle the loading state (see [add-rn-onboarding](add-rn-onboarding.md)).
- `JSON.parse` on corrupted data throws — the service's catch-and-default is what keeps a bad write from bricking the app.
- Migrations run on every launch — keep them fast and idempotent, and never delete an old migration (a user can skip several versions).
- Clearing AsyncStorage (`AsyncStorage.clear()`) wipes *everything*, including other libraries' keys — never call it; delete by namespace prefix instead.
