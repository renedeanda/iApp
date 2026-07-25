# Declare App Store App Privacy (the nutrition label)

> **Source:** *pattern described inline* — a deterministic signal→declaration mapping, proven in production release tooling, that turns a telemetry/permission scan into an App Store Connect App Privacy plan. Confirm against [REUSE_INDEX](../../portfolio/REUSE_INDEX.md).
> **Platform:** Swift (the ASC step is platform-agnostic; the bundled `PrivacyInfo.xcprivacy` half is Swift/iOS)
> **Reliability:** ✅ gold-standard — the advisor is deterministic; the ASC nutrition-label step is **manual web UI only** (the public API can't set it).

## What it adds

A correct, defensible **App Privacy** declaration in App Store Connect — the "nutrition label" questionnaire Apple shows on every product page — plus the in-binary `PrivacyInfo.xcprivacy` manifest that backs it. For a TelemetryDeck app the answer is small and fixed: you collect **Usage Data → Product Interaction**, *not linked to identity, not used for tracking*, for **Analytics**. This recipe is the standard so the answer is decided at scaffold time, not discovered in a submission-day panic.

> Two distinct privacy surfaces, easily conflated (see [portfolio/RECENT_LEARNINGS.md](../../portfolio/RECENT_LEARNINGS.md)):
> - **`PrivacyInfo.xcprivacy`** — a manifest *inside the binary* declaring collected data types + Required Reason APIs. Enforced by `PrivacyManifestTests`.
> - **App Privacy nutrition label** — the *ASC questionnaire*, set by hand in the web UI. The public ASC API cannot set it.
> A shipping app needs **both**, and they must agree.

## When to use

- The app ships **TelemetryDeck** (anonymous, opt-out, no IDFA) — the portfolio's only sanctioned analytics dep. Declare Product Interaction.
- You graduated a silent-by-design app (OSLog/no-op stub) to live transmission — the declaration is now required.
- Pre-submission readiness pass: you're filling out the ASC App Privacy section and want the exact three answers, not a guess.

## When NOT to use

- **Apps that genuinely collect nothing** (no analytics layer at all, by product-spine decision). Do **not** invent a Product Interaction declaration to "be safe" — declare **Data Not Collected** instead (see the path below). A false "we collect data" is as wrong as a false "we don't."
- **Apps using a crash reporter** (Sentry et al.). Those also collect **Diagnostics → Crash Data** — crash data is easy for a scan to miss, so add it by hand. Don't ship a Product-Interaction-only label when crash data is also leaving the device.
- **As an excuse to skip the in-binary manifest.** The ASC label is not a substitute for `PrivacyInfo.xcprivacy` (ITMS-91053 rejects the upload without it). Both, always.
- **Auto-declaring from permission strings.** A permission prompt (camera, photos, contacts) is a *verify-reminder*, never an automatic data-collection declaration — having the permission doesn't mean you transmit the data. Treat permissions as reminders.

## How

### 1. Derive the plan

- The signal→declaration mapping is deterministic. Scan the app for its analytics/crash dependencies and permission strings, then map: TelemetryDeck present → **Usage Data → Product Interaction**, not linked / not tracking, purpose Analytics; `NSPrivacyTracking=false`; expects a backing `PrivacyInfo.xcprivacy`. A crash reporter adds **Diagnostics → Crash Data**. Permission strings are verify-reminders only, never automatic declarations.

```sh
grep -rln 'TelemetryDeck\|Sentry' <path-to-app> --include='*.swift'
grep -n 'UsageDescription' <path-to-app>/*/Info.plist
```

The result is a copy-ready, per-app declaration plan (which types to declare, the three answers, and the manifest/ATT cross-checks). The ASC public API **cannot** write these labels — the plan is something you transcribe into the web UI.

### 2. Set the nutrition label in App Store Connect (manual web UI)

App Store Connect → your app → **App Privacy** → **Edit** → **"Yes, we collect data from this app"** → **Add** the data type with these three answers:

| Question | Answer (TelemetryDeck) |
|---|---|
| Data type | **Usage Data → Product Interaction** |
| Linked to the user's identity? | **No** (TelemetryDeck is anonymous — no IDFA, no account) |
| Used for tracking? | **No** |
| Purpose | **Analytics** |

Save and publish. Repeat the **Add** for any *additional* type a scan surfaces (e.g. Crash Data for a crash reporter — see "When NOT to use").

### 3. Back it with the in-binary manifest

Ship `PrivacyInfo.xcprivacy` (host app + every extension — the extension-bundle trap generalizes) declaring:
- `NSPrivacyCollectedDataTypes` → the Product Interaction type, *not linked, not tracking, purpose Analytics* (mirrors the label).
- `NSPrivacyTracking` → **false**.
- `NSPrivacyAccessedAPITypes` → the Required Reason APIs the app actually uses (UserDefaults `CA92.1`, FileTimestamp, etc.).

Pin it as an explicit resource in `project.yml` (a bare `sources:` glob can drop it) and let `PrivacyManifestTests` assert the pin.

### 4. The "Data Not Collected" path (zero-analytics apps)

If the scan finds **no** analytics layer and no other transmitted data:

App Store Connect → App Privacy → Edit → **"No, we do not collect data from this app"** → confirm the eligibility checklist. Still ship a `PrivacyInfo.xcprivacy` (Required Reason APIs like UserDefaults `CA92.1` are still declared even when you collect nothing) with `NSPrivacyTracking=false`.

### Verify

```sh
grep -rln 'TelemetryDeck\|Sentry' <path-to-app> --include='*.swift'   # re-derive the plan; it must match ASC
grep -n NSPrivacyTracking <path>/*/PrivacyInfo.xcprivacy   # expect <false/>
```

Expected: the scan-derived plan and your ASC answers agree; `NSPrivacyTracking` is false; the manifest declares the same collected type the label does.

## Gotchas

- **ATT contradiction.** If `NSUserTrackingUsageDescription` (the App Tracking Transparency prompt string) is present in Info.plist, the *not-tracking* default is wrong — you've told the system you may track. Either set **Used for Tracking: Yes** and declare the tracking identifier in both the label and the manifest, **or** drop the unused `NSUserTrackingUsageDescription` string if you don't actually track. Treat this as a contradiction signal — resolve it, don't ignore it.
- **The label is publish-on-save and public.** Changing your collection later (e.g. graduating a silent app) means going back into the web UI — there's no API to script it. Budget the manual step into the launch checklist.
- **Graduating analytics is a *constitutional* change, not just code** (see [portfolio/RECENT_LEARNINGS.md](../../portfolio/RECENT_LEARNINGS.md)). When a privacy-forward app flips transmission on, update its CLAUDE.md Dependencies + Privacy Stance, keep `NSPrivacyTracking` false (TelemetryDeck is anonymous), **and** set the ASC label in the same pass — the in-binary manifest landing without the label is a half-done declaration.
- **Permissions ≠ declarations.** A camera/photos permission is a reminder to verify what you do with the data, not an automatic "we collect Photos." Only declare a type you actually transmit.
