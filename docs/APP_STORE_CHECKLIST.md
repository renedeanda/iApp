# App Store Submission Checklist

Pre-decided answers to every App Store Connect question, baked into the template so each submission doesn't reinvent the wheel. Every new app gets a copy of this checklist; the wizard pre-fills the answers that don't vary by app.

## Build configuration

- [ ] `Version.xcconfig` defines `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` (single source of truth — `project.yml` references both via `$(...)`).
- [ ] `project.yml` has `DEVELOPMENT_TEAM: <your team id>` and `CODE_SIGN_STYLE: Automatic` so simulator, archive, and physical-device builds regenerate consistently from XcodeGen.
- [ ] `bin/bump-version <patch|minor|major>` script edits the xcconfig and tags the commit.
- [ ] `make archive` (Swift) or `npm run archive` (RN) exists and creates a Release `.xcarchive` for `generic/platform=iOS`.
- [ ] If a project generator runs before archive (`xcodegen generate`, `expo prebuild`, config plugins), its config is a complete source of truth for every shipped app, extension, watch target, scheme, capability, and archive pre-action. Do not regenerate a mature project if the generator would drop hand-maintained targets.
- [ ] The release command runs or validates an App Store Connect export for the host app and every embedded `.appex`/watch app. Decode each exported `embedded.mobileprovision`; fail if `ProvisionedDevices` exists.
- [ ] The exported IPA contains real executables for every `.app` and `.appex` bundle. For RN/Expo widgets, a target with an empty Sources phase can archive as a hollow `.appex` and later fail signing/upload.
- [ ] If the app offers alternate app icons, every runtime icon name has a matching `.appiconset` and the generator writes `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`; `INCLUDE_ALL_APPICON_ASSETS` alone is not enough for upload safety.
- [ ] Every shipped extension dependency is explicit in the source of truth with `embed: true`, `codeSign: true`, and `link: false` where the generator supports it.
- [ ] Every app and extension target includes its own `PrivacyInfo.xcprivacy` as a resource; do not rely on manual `.xcodeproj` edits surviving regeneration.
- [ ] For RN/Expo apps, a clean prebuild cannot regress the native splash screen or alternate icon names; archive scripts must verify the generated iOS project before `xcodebuild archive`.
- [ ] Automatically signed targets do not hardcode `Apple Distribution` into the Archive action; distribution signing is proven during `xcodebuild -exportArchive` or Organizer export.
- [ ] App-specific archive prerequisites are explicit hooks, not memory: Rust/static libraries, generated bindings, Expo prebuild, CocoaPods, dSYM upload, etc.
- [ ] Widget extension + tests target inherit the same version (verified by `project.yml` or the Expo config plugin).
- [ ] Release configuration uses `-O` (optimized) and stripped symbols.
- [ ] dSYMs uploaded to TelemetryDeck / Sentry on archive.

## Info.plist (baked into the template)

- [x] `ITSAppUsesNonExemptEncryption = NO` — pre-set so the encryption export compliance question is never asked.
- [x] `LSApplicationCategoryType` set (wizard prompts — default `public.app-category.utilities`).
- [x] `UILaunchScreen` JSON (modern launch screen — no storyboard).
- [x] `UIRequiredDeviceCapabilities: [arm64]`.
- [x] `UISupportedInterfaceOrientations` baseline (portrait + portrait-upside-down on iPhone; all on iPad if iPad supported).
- [x] `NSAppTransportSecurity` defaults to HTTPS-only (no exceptions).
- [x] `LSSupportsOpeningDocumentsInPlace = YES` only if document-based.
- [x] `UIBackgroundModes` empty by default — wizard adds only what's needed.

## Privacy permission strings (in `Localizable.xcstrings`, commented out by default)

The wizard uncomments only the ones for enabled features:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`
- `NSFaceIDUsageDescription`
- `NSUserNotificationsUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSContactsUsageDescription`
- `NSCalendarsUsageDescription`
- `NSRemindersUsageDescription`
- `NSMotionUsageDescription`
- `NSBluetoothAlwaysUsageDescription`
- `NSLocalNetworkUsageDescription`

Each string must:
- Be one sentence.
- Explain *why* (not just what).
- Be translated for every tier-1 locale.

## Privacy manifest (`PrivacyInfo.xcprivacy`)

Required-reason API declarations stubbed for the APIs the thick scaffold actually uses:

- `UserDefaults` → reason `CA92.1` (accessing user defaults for app functionality)
- `FileTimestamp` → `C617.1` (file creation/modification dates)
- `SystemBootTime` → `35F9.1` (calculating uptime for app metrics)
- `DiskSpace` → `E174.1` (storage availability checks)

- [x] `NSPrivacyTrackingDomains: []`
- [x] `NSPrivacyTracking: false`
- [x] `NSPrivacyCollectedDataTypes: []` by default — wizard adds rows when analytics enabled.

Verified at PR time by `PrivacyManifestTests.swift` (greps source for actual API usage, asserts manifest covers it).

## Entitlements (in `Seed.entitlements`, all commented unless enabled)

- iCloud (CloudKit container `iCloud.com.example.<name>`)
- App Groups (`group.com.example.<name>`)
- Push notifications (`aps-environment`)
- Siri / App Intents
- Time Sensitive Notifications
- Family Controls
- Sign in with Apple

Mac Catalyst entitlement file (`Seed-macOS.entitlements`) ships app sandbox + user-selected file access for Catalyst opt-in.

Widget entitlement (`Widgets/SeedWidgets.entitlements`) mirrors App Group only.

## Certs & keys (visible TODO markers, not hidden assumptions)

`App.swift` ships a commented block at the top:

```swift
// TODO(certs): Sign in with Apple key — generate at developer.apple.com → Keys
// TODO(certs): APNS auth key — needed before NotificationService can send remote pushes
// TODO(asc-api): App Store Connect API key — needed before fastlane beta/release lanes work
```

Mirrored in this checklist as actionable items per app:

- [ ] Sign in with Apple key generated and stored at `~/.appstore/keys/<app-name>-siwa.p8`
- [ ] APNS auth key generated (or pushes disabled)
- [ ] App Store Connect API key generated and added to `~/.appstore/keys/asc-api.p8` (one key for the whole portfolio works)

## Screenshots

- [ ] 6.9" iPhone (1320 x 2868) - current large iPhone shelf.
- [ ] 6.5" iPhone (1242 × 2688) — required for iPhone 11 Pro Max display.
- [ ] 5.5" iPhone (1242 × 2208) — no longer required since iOS 17, can omit.
- [ ] 13" iPad (2064 x 2752) - current large iPad shelf, if iPad supported.
- [ ] 12.9" iPad Pro (2048 × 2732) — if iPad supported.
- [ ] At least 3 screenshots per device size, max 10.
- [ ] First screenshot is the hero — communicates the mission in 1 second.
- [ ] Screenshot/device treatment intentionally bleeds off bottom or uses a justified full-device layout.
- [ ] Subtitles never touch or overlap screenshot/device imagery on phone or iPad.
- [ ] Localized hero text in each tier-1 locale.
- [ ] Full refreshes use new versioned output folders (`final_real_v2/`, `final_real_v3/`, etc.) instead of overwriting prior rounds.
- [ ] Seed media, if used, appears inside real app data and has been checked for rights/privacy, face-safety, crops, and text contrast.
- [ ] Screenshots show both rich and fallback states when the product supports both (for example, cards with and without cover images).

Generate via [recipes/app-store-screenshots.md](../recipes/app-store-screenshots.md). Use real simulator captures with seeded content; generated media belongs inside the app data, not as fake UI. Keep heavy raw/final image folders and ZIPs out of git unless explicitly approved.

## iCloud Data Deletion (user data control)

Accountless apps mean Guideline 5.1.1(v)'s account-deletion requirement
doesn't strictly apply — but App Review has cited it anyway for iCloud-stored
app data (a real rejection we ate). Treat in-app deletion of the
user's iCloud data as a must-ship for every CloudKit-backed app, framed as
data deletion / user control, never as "account deletion" in UX copy.

- [ ] If the app stores user data in iCloud, Settings includes an always-visible neutral Data/Data & Backup row; `Delete All Data` is destructive and one level deeper.
- [ ] Deletion is never paywalled and works when signed out of iCloud by wiping local data (with an honest "sign in to remove iCloud data too" message — never a silent no-op or a blind retry queue).
- [ ] The destructive confirmation is a centered/system alert attached to the visible Data/Delete destination, says the action cannot be undone, names app-owned data being deleted, explicitly excludes likely-confused system/private data, and uses the correct purchase wording for this app.
- [ ] SwiftData/NSPersistentCloudKitContainer apps: local row-by-row wipe FIRST (tombstones export through the still-attached mirror; never `delete(model:)` batch deletes), CloudKit zone delete LAST, and the store re-opens local-only while `pendingCloudDeletion` is set — otherwise the live mirror re-exports and resurrects the zone.
- [ ] The pending retry stores the requesting account's `userRecordID` captured at request time; retry fires only on an exact identity match, an identity-less pending marker is dropped (never a permanent sync-off deadlock), and no pending marker is ever queued without a verified identity.
- [ ] The deletion-in-progress flag is a self-expiring timestamp, not a boolean latch — a crash mid-deletion must not brick widget/intent intake forever.
- [ ] Widgets, App Intents, watch apps, share extensions, Spotlight, notifications, badges, app-group snapshots, KVS, attachments, AI/location caches, and export temp files are cleared by NAME or explicitly allowlisted — never a container-wide App Group sweep (it holds `Library/` with the group UserDefaults plist, and possibly the live store/externalStorage).
- [ ] The result alert reports the actual outcome (full / cloud-pending / no-account / failed) and is presented from a surface that survives any post-deletion container rebuild / `.id()` view reset.
- [ ] The app has a backup/export path before deletion when the data is valuable.
- [ ] App Review notes include the deletion path and a screen recording for iCloud-backed submissions.

See [ICLOUD_DATA_DELETION.md](ICLOUD_DATA_DELETION.md) for RN and Swift implementation notes.

## Privacy nutrition labels (pre-populated defaults)

For the standard service stack:

- **TelemetryDeck enabled:**
  - Data Type: Diagnostics → Crash Data, Performance Data, Other Diagnostic Data
  - Linked to identity: No
  - Used for tracking: No
- **CloudKit enabled:**
  - Data Type: User Content → Other User Content (whatever the app stores)
  - Linked to identity: Yes (via iCloud account, but only on user's own devices)
  - Used for tracking: No
- **StoreKit purchases:**
  - Data Type: Purchases → Purchase History
  - Linked to identity: Yes (Apple ID, handled by Apple)
  - Used for tracking: No
- **Sentry enabled:**
  - Data Type: Diagnostics → Crash Data
  - Linked to identity: No (PII scrubbing on)
  - Used for tracking: No

## App Review reviewer notes

Template at `docs/REVIEWER_NOTES.md`:

```
Demo account: not required (single-user app, no backend account).
Test flow: launch → tap "Start" → 90-second flow completes → app shows "done" screen.
Privacy: All data stays on-device + user's iCloud. No third-party servers.
ATT: Not requested.
Third-party content: None.
```

## Submission-day questionnaire (pre-decided)

- **Export compliance encryption:** No (handled by `ITSAppUsesNonExemptEncryption = NO`).
- **Content rights:** No third-party copyrighted content used.
- **Advertising identifier:** No (unless ads enabled — never, per [NOT_FOR.md](NOT_FOR.md)).
- **Age rating:** 4+ default (wizard prompts to override).
- **App uses IDFA:** No.
- **App contains third-party content:** No.

## CI / TestFlight

- [ ] `.github/workflows/ci.yml` green on `main`.
- [ ] Xcode Cloud bootstrap script (`ci_scripts/ci_post_clone.sh`) installs xcodegen + runs `xcodegen generate` pre-build.
- [ ] Fastlane `beta` lane uploads to TestFlight (commented out in template; user uncomments after first manual upload).
- [ ] `WHATS_NEW.md` localized for every tier-1 locale.

## Pre-submission tests (block PR merge)

Six unconditional + two widget/Live-Activity conditional:

- `AppIconAssetTests.swift` — every required icon size present.
- `PrivacyManifestTests.swift` — declared APIs cover code usage.
- `LocalizationParityTests.swift` — every key has translation per tier-1 locale.
- `WidgetLocalizationParityTests.swift` — widget extension's *own* xcstrings has every widget-surface string (the widget-bundle trap).
- `ThemeContrastTests.swift` — AAA contrast on primary pairs.
- `HapticPatternTests.swift` — every shipped haptic pattern loads.
- `WidgetEdgeToEdgeTests.swift` *(if widgets enabled)* — every widget uses `containerBackground(for: .widget)`.
- `LiveActivityViewTests.swift` *(if Live Activities enabled)* — all five Live Activity regions render localized.

## Kindling launch-packet conventions

Every generated app carries its launch data in a predictable shape, so release tooling (yours or an agent's) can find everything without spelunking:

- **Launch packet** — one versioned JSON document conforming to [`docs/schemas/launch-packet.v1.schema.json`](schemas/launch-packet.v1.schema.json): app identity, mission, build/test/archive commands, metadata + screenshot paths, locales, monetization tier, privacy plan.
- **App Store metadata JSON** — `Marketing/AppStoreMetadata/<app>-app-store-metadata.json`, one file per app, all locales inside. Field limits validated: name 30, subtitle 30, keywords 100, description 4000.
- **Screenshots** — locale/device folder layout under the path the packet's `paths.screenshots` names.
- **Release context doc** — `RELEASE.md` at the app repo root: bundle ID, shipping branch, metadata paths, local commands, archive flow.

- [ ] Launch packet written and validates against the v1 schema.
- [ ] Metadata JSON present for every tier-1 locale, within field limits.

## Privacy URL + Support URL

- [ ] `docs/PRIVACY_POLICY.md` published on GitHub Pages or a portfolio-wide privacy URL.
- [ ] `docs/SUPPORT.md` published (App Store requires a Support URL).
- [ ] Both URLs entered in App Store Connect → App Privacy / App Information.

## App Store Connect API

Pre-decided portfolio-wide answers:

- **Primary category:** varies (set per app).
- **Secondary category:** varies (set per app).
- **Age rating:** 4+ default.
- **App availability:** Worldwide except where Apple restricts.
- **Price tier:** see [MONETIZATION_MATRIX](../portfolio/MONETIZATION_MATRIX.md).
- **Sign in with Apple:** required if the app has any sign-in (per App Store guidelines).

## When this checklist fails

If submission is rejected:

1. Document the rejection reason in [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md) with date + one-sentence summary.
2. Open a PR to this checklist adding the prevention step.
3. Add a corresponding test (`AppIconAssetTests`-style) to catch it at PR time next time.

The goal: every submission rejection only happens once across the portfolio.
