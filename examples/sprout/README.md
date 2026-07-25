# Sprout (Swift template)

This is the Swift / SwiftUI starter scaffold consumed by Kindling's `/new-app --commit` wizard. It is also runnable standalone for debugging.

Each `Sprout` token in this tree (file names, bundle id, App Group, iCloud container, type names, strings) is rewritten by `bin/rename-template.sh` to the new app's chosen name. Don't ship the template with `Sprout` strings — always rename before opening Xcode.

## Quick bootstrap (standalone)

```sh
make bootstrap NAME=YourApp BUNDLE=com.example.yourapp
open YourApp.xcodeproj
```

## Archive

```sh
make archive
```

The command regenerates the XcodeGen project, runs `bin/release-check.sh` when
present, archives for `generic/platform=iOS`, and opens the `.xcarchive` in
Xcode Organizer. Per-app native prerequisites stay explicit through hooks, for
example `ARCHIVE_PRE_CMD="../native-lib/build-ios.sh release" make archive`.

## What ships in the box

- **Theme suite** (`Sprout/Theme/`) — `AppTheme`, `Typography`, `LiquidGlass`, three swappable typography specimens at `Theme/_TypographySpecimens/`. Proven in a shipped production app.
- **Every service in `Sprout/Services/_Disabled/`.** The wizard graduates the ones `DECISIONS/004-native-feature-checklist.md` says yes to, leaves the rest dormant. CloudKit/SwiftData apps must graduate `DataDeletionService.swift` and its Settings Data section before submission.
- **3 starter haptic patterns** in `Sprout/Utilities/HapticPatterns.swift`; the full 24-pattern vocabulary (distilled from a shipped production app) stays as reference at `Sprout/Utilities/_HapticVocabulary/`.
- **Dev/Debug Premium toggle** wired through `SubscriptionManager.isPro`. See [`../../docs/HOUSEKEEPING.md`](../../docs/HOUSEKEEPING.md) "Dev/Debug Premium Toggle."
- **8 housekeeping tests** (`SproutTests/`) that catch dumb stuff at PR time: missing icon sizes, missing privacy declarations, locale parity, AAA contrast, etc.
- **Localizable.xcstrings** seeded with the 7 tier-1 locales.
- **PrivacyInfo.xcprivacy** with required-reason API declarations for the APIs the scaffold uses.
- **Sprout.storekit** for offline StoreKit testing.
- **GitHub Actions CI** at `.github/workflows/ci.yml` running build + the 8 tests.
- **Xcode Cloud bootstrap** at `Sprout/ci_scripts/ci_post_clone.sh`.

## Reading order

1. `CLAUDE.md` — the templated app constitution. Ships in this repo with `{{PLACEHOLDERS}}`; the wizard substitutes them at `/new-app --commit` time. If you see a stray `{{...}}` token in a child app, the substitution failed — run `/init` to re-seed.
2. `Sprout/SproutApp.swift` — entry point + DI wiring.
3. `Sprout/Theme/AppTheme.swift` — palette / typography tokens.
4. `Sprout/Services/SubscriptionManager.swift` — the dev premium toggle wiring is here.

## Where to harvest more

See `../../portfolio/REUSE_INDEX.md` for the canonical map of "where does feature X come from?"
