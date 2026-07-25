# Add App Intents + Siri shortcuts

> **Source:** `templates/swift/Seed/Intents/` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard for the *logic* and provider pattern. ⚠️ Intent strings that surface on a widget / Live Activity must live in the extension's own string catalog — the bundle-localization trap applies to intents too.

## What it adds

`AppIntent` definitions that expose the app's core actions to Siri, Shortcuts, Spotlight, and (via a thin shell) Control Center. The user can run an action by voice, add it to a Shortcuts automation, or trigger it from the lock screen — without opening the app.

## When to use

- The app has a **discrete, parameterizable action** worth automating ("start a 90-second reset", "log a trip", "create a note titled X").
- You want the action available to Siri / Shortcuts / Spotlight from one definition.
- The action is the prerequisite for a Control Center control (see [add-control-center](add-control-center.md)).

## When NOT to use

- **The action needs a full UI to complete.** Intents can open the app (`OpensIntent`) but if every run just launches the app, it's a glorified deep link — ship an `NSUserActivity` instead.
- **Vague or compound actions.** "Do my morning routine" is a Shortcut the *user* composes from your atomic intents — don't pre-bundle it.
- **You haven't localized the intent phrases.** `AppShortcutsProvider` phrases are user-facing; un-localized phrases ship English to every locale.
- **One-off actions.** If the user would run it once a month, the discovery cost (Siri training, Shortcuts gallery) outweighs the benefit.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Intents/` — `SeedIntents.swift` + `SeedShortcutsProvider.swift` (the `AppIntent` + `AppShortcutsProvider` provider pattern), with `FocusFilterIntent.swift` as a richer example.
- Copy into: `<App>/Intents/`.

### 2. Wire

- **Intent definitions:** one `struct` per action conforming to `AppIntent`. `perform()` does the work and returns an `IntentResult`. Keep `perform()` thin — it calls into an existing service, it doesn't reimplement logic.
- **Parameters:** use `@Parameter` with a `title:` (localized). Provide `EntityQuery` for any parameter that picks from app data.
- **Shortcuts provider:** one `AppShortcutsProvider` listing each intent with localized invocation phrases. Phrases go through `Localizable.xcstrings`.
- **Donate** the intent after a successful in-app run so Siri learns the pattern (`IntentDonationManager` or the modern `donate()`).
- **No UI imports** in the intent file — it's logic. If it needs to show a result snippet, return a `ProvidesDialog` / `ShowsSnippetView` result, not a `View` reference.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# then on the simulator: Shortcuts app → + → search the app's name → confirm each intent appears with localized phrasing.
```

Expected: build green; every intent is discoverable in the Shortcuts gallery; running one performs the action without errors.

## Gotchas

- `AppShortcutsProvider` allows at most 10 shortcuts per app — be selective.
- Intent parameters that reference SwiftData entities need an `EntityQuery` that runs **outside** the main app process; keep it lightweight (no heavy fetches).
- Changing an intent's identifier breaks user-built Shortcuts that reference it. Treat identifiers as a public API.
