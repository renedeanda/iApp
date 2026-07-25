# Archive iOS

## What it adds

A checked-in one-command archive path for App Store builds. Swift apps expose
`make archive`; Expo/React Native apps expose `npm run archive`. The command
regenerates native project state, runs any app-specific native prerequisites via
explicit hooks, archives Release for `generic/platform=iOS`, and opens the
resulting `.xcarchive` in Xcode Organizer.

## When to use

- The app is near TestFlight or App Store submission.
- A project has signing/version settings that must survive regeneration.
- The app has native prerequisites that are easy to forget, such as Rust static
  libraries, generated bindings, Expo prebuild, CocoaPods, or dSYM upload.
- The owner should be able to archive without remembering manual Xcode steps.

## When NOT to use

- Do not hide unresolved signing problems by adding command-line overrides.
  Fix `project.yml`, entitlements, bundle IDs, and Apple Developer capabilities.
- Do not make the shared command install secrets, signing certificates, or App
  Store Connect API keys.
- Do not replace app-specific preflight checks. Call them from the archive hook
  or keep `make release-check` separate.
- Do not hard-code another app's scheme, workspace, or artifact paths.

## How

Swift/XcodeGen apps:

1. Copy `templates/swift/bin/archive-ios.sh` into `bin/archive-ios.sh`.
2. Add `archive` to the app `Makefile`:

   ```make
   archive:
   	@bin/archive-ios.sh
   ```

3. Set app-specific defaults only when the generated names are not enough:

   ```sh
   APP_TARGET=MyApp \
   SCHEME=MyApp \
   PROJECT=MyApp.xcodeproj \
   ARCHIVE_PRE_CMD="../my-parser/build-ios.sh release" \
   make archive
   ```

4. Keep `ARCHIVE_PRE_CMD` for prerequisite build products (a Rust static
   library, generated bindings, codegen). Keep `ARCHIVE_POST_CMD` for optional
   dSYM upload or notarization/export steps.

Expo/React Native apps:

1. Copy `templates/rn/scripts/archive-ios.sh` into the child app's `scripts/` directory.
2. Add `"archive": "bash scripts/archive-ios.sh"` to `package.json`.
3. Keep the default production-proven flow unless the app needs overrides:

   ```sh
   APP_NAME=MyApp npm run archive
   ```

   For unusual native layouts, set `IOS_DIR`, `SCHEME`, `WORKSPACE`,
   `EXPO_PREBUILD_CMD`, `POD_INSTALL_CMD`, `ARCHIVE_PRE_CMD`, or
   `ARCHIVE_POST_CMD`.

Verification:

```sh
OPEN_ARCHIVE=0 make archive       # Swift
OPEN_ARCHIVE=0 npm run archive    # RN
```

Use a real machine signed into the correct Apple Developer team. If signing
fails, fix automatic signing/team/bundle ID/capability source files before
falling back to manual Xcode archive.

The archive scripts run an App Store Connect export by default
(`EXPORT_FOR_APP_STORE=1`) after the raw `.xcarchive` is created. The export uses
`method=app-store-connect`, `signingStyle=automatic`, and your Apple Developer team, so
it exercises the same distribution-signing path that Organizer uses before
upload. The script then unzips the exported IPA and verifies every embedded
`embedded.mobileprovision` inside the host app and extensions. Verification fails
if any profile contains `ProvisionedDevices`, because that is a device,
development, or ad-hoc profile and App Store Connect will reject it.

The export verification also checks that every `.app` and `.appex` has a real
`CFBundleExecutable` file. RN/Expo widget plugins can accidentally generate an
archiveable but hollow extension when the widget Swift files are copied after
the Xcode project mod has already created the target, or when build-file entries
land in the host app target instead of the widget Sources phase. That often
presents as an App Store signing/profile rejection for the extension; the real
fix is to make the generated widget target compile its Swift sources and embed a
real executable before chasing provisioning profiles.

When an app has widgets, file providers, share extensions, notification service
extensions, watch apps, or any other embedded executable, treat each extension as
its own App Store-signed product: unique bundle ID, matching App Group/capability
state in Apple Developer, automatic signing, the same team, and an App Store
profile at export time. The containing app being correctly signed is not enough.
Do not force `Apple Distribution` into `xcodebuild archive` for automatically
signed targets; let Archive use Automatic signing, then prove the distribution
path with `xcodebuild -exportArchive`.
