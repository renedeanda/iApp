# Working with XcodeGen (project.yml)

> **Source:** the Swift template's own `templates/swift/project.yml` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)) — a clean 3-target base proven in production.
> **Platform:** Swift
> **Reliability:** ✅ — the template (and every app generated from it) is XcodeGen-driven. This recipe is the reference for *changing* `project.yml`, not adding XcodeGen (it's already there).

## What it adds

Not a feature — the **discipline** for the project file. Every Swift template app generates its `.xcodeproj` from `project.yml` via XcodeGen. The `.xcodeproj` is **not checked in** (`.gitignore`d). This recipe is how you add a target, a file group, a build setting, or a dependency without ever opening the project editor.

## When to use

- Adding a target (widget extension, share extension, app-intents) — see [add-widgets](add-widgets.md), [add-share-extension](add-share-extension.md).
- Adding an SPM dependency.
- Changing a build setting, entitlement path, or Info.plist property.
- A teammate's checkout shows project drift — regenerate and the drift is gone.

## When NOT to use

- **Hand-editing the `.xcodeproj`.** It's generated. Any change you make in Xcode's project editor is erased on the next `xcodegen generate`. This is the whole point — the project file can't drift because it isn't the source of truth.
- **Checking in the `.xcodeproj`.** It's gitignored. Committing it reintroduces merge conflicts and per-machine drift — the exact problems XcodeGen exists to kill.
- **Bypassing it "just this once."** The pre-commit hook runs `xcodegen generate` so `project.yml` drift never ships. Working around that defeats the guarantee.

## How

### Adding a file

You don't. `sources: [{ path: Seed }]` globs the directory — a new file under `Seed/` is picked up on the next `xcodegen generate`. No PBXBuildFile entry to hand-add (the trap in non-XcodeGen projects). The exceptions are the `excludes:` patterns — files under `Services/_Disabled/`, `Utilities/_HapticVocabulary/`, `Theme/_TypographySpecimens/`, `Intents/` are deliberately not compiled until the wizard graduates them.

### Adding a target

1. Add the target block under `targets:` (see the commented `SeedWidgets` block for the shape — `type`, `platform`, `sources`, `settings`, `info`).
2. Add it to the app target's `dependencies:` if it must be embedded (extensions: `embed: true`).
3. Add it to the `schemes:` block if it should build with the main scheme.
4. `xcodegen generate`.

### Adding an SPM dependency

1. Add it under `packages:` (top of `project.yml`) — `url` + `exactVersion` (pin it; no floating versions).
2. Reference it in the consuming target's `dependencies:` as `- package: <name>`.
3. `xcodegen generate`. Commit the updated `project.yml` — and `Package.resolved` if the template tracks it.
4. No new dep without an ADR — `DECISIONS/NNN-dependency-<name>.md`. TelemetryDeck is the only pre-approved one.

### Changing a build setting

Edit `settings:` (project-wide) or a target's `settings.base` / `settings.configs`. Never set it in the Xcode UI — it won't survive regeneration. Version/build come from `Version.xcconfig` via `configFiles:` — never put `MARKETING_VERSION` literally in `project.yml`. Signing is also project-source-owned: keep `DEVELOPMENT_TEAM: <your-team-id>` and `CODE_SIGN_STYLE: Automatic` in `project.yml` so physical-device builds do not need local command-line overrides after every regeneration.

### Verify

```sh
xcodegen generate
xcodebuild build -scheme Seed -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
git status   # the .xcodeproj should NOT appear — it's gitignored
```

Expected: regenerates cleanly, builds green, no `.xcodeproj` in `git status`.

## Gotchas

- After **any** `project.yml` change, run `xcodegen generate` before building — stale `.xcodeproj` is the most common "but it worked yesterday."
- The `.githooks/pre-commit` runs `xcodegen generate` so drift never ships — if it modifies files, that's the hook doing its job; stage them.
- `generateEmptyDirectories: true` is set so gated directories (`_Disabled/` etc.) survive a fresh clone even when empty.
- XcodeGen is installed via the `Brewfile` (`brew bundle`) — a checkout without it can't generate. `make bootstrap` handles this.
