# Recipe — App-extension localization (per-bundle `Localizable.xcstrings`)

> **Gold-standard source:** `templates/swift/SeedWidgets/Resources/Localizable.xcstrings`
> + the `project.yml` resource pinning shown below. The generalized pattern —
> Share, File Provider, Control Center, and Widget extensions each shipping
> their OWN `Localizable.xcstrings` — is proven on a shipping production app.

## What this solves

**An app extension loads its strings from its OWN bundle, not the host
app's.** A `NSLocalizedString(...)` / `String(localized:)` call inside a
widget, Share, Action, File Provider, or Control Center extension resolves
against the `.appex` bundle. If that bundle ships no catalog, every locale
falls back to the development-language literal — the user sees English in an
otherwise-localized app.

This is the **widget-l10n trap** (see
[RECENT_LEARNINGS.md](../../portfolio/RECENT_LEARNINGS.md)), and
the key realization is that it is **not widget-specific** — it applies to
*every* extension type. We hit and fixed it in production for a Share
extension (`NSLocalizedString` with no extension catalog → English
everywhere) and a File Provider extension (a hardcoded `"Processed"` folder
name shown in the Files app).

## When to use

- You're adding ANY app extension that renders a user-facing string it owns:
  Widget, Live Activity, Share, Action, File Provider, Control Center,
  Notification Content, Intents UI.
- You have a hardcoded string literal in extension code (folder names, status
  text, placeholder labels).

## When NOT to use

- **Pure-logic extensions** with zero user-facing chrome (e.g. a background
  File Provider that surfaces no strings) — nothing to localize.
- **Strings that arrive from the host** via the App Group payload and were
  already localized host-side before being written. (But the extension's own
  chrome — section titles, empty states, action labels — still needs its
  catalog.)
- **Brand names only** (the app name, "PDF", "Pro") — those stay verbatim;
  read the app name from `Bundle.main.localizedInfoDictionary`, never
  `Text("…")`.

## Steps

1. **Create the extension's own catalog** at
   `<Extension>/Resources/Localizable.xcstrings` with the extension's strings.
   Use the `feature.context.label` key convention.

2. **Reference strings normally** in the extension code —
   `String(localized: "share_extension.processing")` /
   `NSLocalizedString("fileProvider.folder.processed", comment:)`. They
   resolve against the extension bundle automatically. **Delete any
   hardcoded literal.**

3. **Pin the catalog in `project.yml`** under the extension target's
   `resources:` (XcodeGen's `sources:` glob does not reliably classify
   `.xcprivacy`/loose resources):

   ```yaml
   SeedWidgets:
     type: app-extension
     resources:
       # The extension's OWN Localizable.xcstrings — strings load from the
       # extension bundle, not the host's.
       - path: SeedWidgets/Resources/Localizable.xcstrings
       # Each extension also bundles its OWN privacy manifest.
       - path: SeedWidgets/PrivacyInfo.xcprivacy
   ```

4. **Add a parity test.** Mirror `WidgetLocalizationParityTests.swift`: assert
   the extension catalog covers every app-locale present in the host catalog,
   with matching format specifiers. This is the *enforcer* (per the iApp
   maturity matrix, the rule must have an artifact, not just a SKILL line).

5. **Translate** with `/translate <lang>` for each tier-1 locale
   (`en es de fr pt ja zh-Hans` — plus any the app has promoted; one shipped
   app runs 9 including `it` + `ko`). Validate format specifiers (`%@`, `%lld`).

## Validation

- `xcodebuild build` — the extension compiles and bundles its catalog.
- The new parity test passes (every app-locale present, specifiers match).
- Manually: run the extension surface under a non-en system language and
  confirm no English leaks.

## Cross-references

- [docs/WIDGETS.md](../../docs/WIDGETS.md) rule 2 — the widget-specific origin.
- [portfolio/REUSE_INDEX.md](../../portfolio/REUSE_INDEX.md) — "App-extension
  localization" row.
- [portfolio/RECENT_LEARNINGS.md](../../portfolio/RECENT_LEARNINGS.md) — the
  widget l10n trap, later generalized to all extension types.
