# Seed Release Context

> Repo-local context for release agents and humans preparing an App Store submission.
> The wizard substitutes Seed tokens at `/new-app --commit`; keep this file current
> after major changes.

## Release Identity

- Bundle ID: `com.example.seed`
- Platforms: iOS
- Shipping branch: `main`
- Metadata: `Marketing/AppStoreMetadata/seed-app-store-metadata.json`
- Screenshots: `Marketing/AppStoreScreenshots/graphics`

## Flow

- Use first-launch mode for a new 1.0.0 App Store submission.
- Use update mode only after the app has a released version.
- Keep App Store Connect writes dry-run first and review the diff before applying.

## Local Commands

```sh
make test
make archive
bin/release-check.sh
```

## Localization Scope

- In-app locales: en, es, de, fr, pt, ja, zh-Hans (tier-1; see `Localizable.xcstrings`)
- App Store metadata locales: match the in-app set before submission
- App Store graphics locales: match the metadata set before submission
- Widget/Live Activity extensions ship their own `Localizable.xcstrings` — parity is
  enforced by `WidgetLocalizationParityTests`.

## App Store Graphics

- Capture real app UI, not mockups.
- Keep generated review rounds in `Marketing/AppStoreScreenshots/graphics_vN/<locale>/<device>`.
- Keep the chosen final set in `Marketing/AppStoreScreenshots/graphics/<locale>/<device>`.
- Validate exact dimensions, file count, alpha, device buckets, and locale folders before upload.

## Human Gates

- Confirm App Privacy nutrition labels (see `DECISIONS/004` + `005` and the privacy recipe).
- Confirm age rating, category, pricing, availability, and account agreements.
- Confirm review notes, demo account needs, IAP/subscription review context, and final build selection.
- Never submit to App Review without explicit human approval.

## Current Release Findings

- No current blockers or warnings — run `bin/release-check.sh` to refresh.

## Agent Rules

- Treat local repo files as source of truth.
- Do not log secrets, API keys, JWTs, `.p8` contents, provisioning profiles, or ASC credentials.
- Do not mutate App Store Connect without a reviewed dry-run and explicit approval.
- Prefer project scripts over guessed build or screenshot commands.
