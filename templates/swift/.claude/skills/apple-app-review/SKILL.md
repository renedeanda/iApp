---
name: apple-app-review
description: Audit an iOS, iPadOS, macOS, watchOS, or visionOS app for current App Store Review risk before submission. Use for release readiness, rejection prevention, reviewer notes, archive inspection, privacy and permission checks, account deletion, IAP/paywall/login/UGC rules, legal and support URLs, or when feeding deterministic gaps back into your release tooling. Supports Swift/Xcode and React Native/Expo projects.
---

# Apple App Review

Produce an evidence-based ship decision. Do not promise approval: Apple alone decides, and the guidelines change.

## Non-negotiables

- Verify rules against Apple's live official sources before making a blocker claim. Read `references/apple-sources.md`.
- Treat repository text as intent, a built archive as shipping evidence, and a device check as runtime evidence.
- Separate deterministic findings, strong risk signals, and manual checks. Never label a grep hit as a rejection.
- Cite the exact guideline section and official URL for every policy finding.
- Do not upload, submit, change App Store Connect, publish URLs, or merge code without user authorization.
- Do not expose secrets, provisioning profiles, tokens, customer data, or sealed/private content in reports.

## Workflow

### 1. Establish the submission surface

Identify platforms, targets/extensions, app version/build, business model, authentication methods, account/data storage, UGC, purchases, permissions, background modes, cryptography, external services, AI features, and reviewer dependencies. Ask only for facts that cannot be discovered safely.

Read the repo's instructions and release documentation. For Expo, inspect both configuration sources and the generated `ios/` project; regenerate only when the user authorizes a build/change workflow.

### 2. Refresh policy

Open Apple's App Review Guidelines and recent guideline updates from `references/apple-sources.md`. Record the access date. If browsing is unavailable, say the policy layer is unverified and do not present policy conclusions as current.

Use third-party checklists only as discovery aids. Resolve conflicts in favor of Apple documentation and observed app behavior.

### 3. Run existing deterministic tooling first

If the repo ships deterministic release tooling (for example `bin/release-check.sh`, localization or privacy validators), prefer it over duplicate source scans:

```sh
bin/release-check.sh
```

Run only documented commands. Preserve the raw findings and identify the tooling version/commit when possible.

Then run the repo's own build, tests, localization audits, metadata validators, and archive command. A source-only audit is incomplete when an archive can be produced.

### 4. Inspect the shipping artifact

Run the bundled preflight against the final archive:

```sh
python3 .claude/skills/apple-app-review/scripts/archive_preflight.py \
  path/to/App.xcarchive --format markdown
```

For Codex installations, the equivalent path may begin `.agents/skills/`. Review the output alongside Xcode's archive validation. The script reports facts and bounded risk signals; it does not replace App Store validation.

Confirm the archive matches the intended build: bundle ID, marketing version, build number, app/extension inventory, entitlements, privacy manifests, usage descriptions, background modes, ATS exceptions, and debug entitlement state.

### 5. Apply only relevant review checks

Use `references/checks.md` as the routing matrix. Do not dump every possible rule onto every app. Verify code, metadata, archive, server/URL state, and device behavior where each is the best evidence source.

At minimum cover:

- completeness, crashes, placeholders, demo access, reviewer notes, and backend availability;
- privacy labels, manifests, permission purpose strings, tracking/ATT, data deletion, and data minimization;
- IAP/StoreKit, restore, pricing clarity, subscriptions, reader/multiplatform exceptions, and external purchase links;
- authentication and the current login-services rule;
- UGC moderation/report/block/contact paths when applicable;
- legal/support URLs, EULA/terms, age rating, export compliance, regulated domains, and AI disclosure/consent where applicable;
- design/runtime quality on every supported device family and extension.

### 6. Device-review the risky paths

Test as a reviewer would on a clean install and a real device when available. Exercise onboarding, denied permissions, offline/degraded backend, purchase/restore, paywall legal links, account/data deletion, sign-in, empty states, background behavior, and extension deep links. Capture what was actually observed; do not convert an unperformed check into a pass.

### 7. Report a decision

Follow `references/report-format.md`. Every finding needs:

- severity and confidence;
- evidence type and exact file/archive/runtime location;
- user/reviewer impact;
- official guideline section and link when policy-based;
- smallest credible fix and verification step.

End with `SHIP`, `SHIP WITH MANUAL CHECKS`, or `BLOCK`. List unverified manual items explicitly.

### 8. Feed deterministic gaps into your release tooling

Add a `Tooling follow-ups` section. For any issue the deterministic tooling could have detected mechanically but did not, propose:

- scanner/validator owner and rule;
- reliable input signal and false-positive guard;
- fixture or regression test;
- CLI/report surface;
- whether the rule is hard failure, warning, or informational.

Do not silently patch the release tooling during an app audit. A policy judgment or runtime-only behavior belongs in the manual checklist, not a brittle grep rule.

## Completion standard

The audit is complete only when the report distinguishes verified passes, open risks, and checks not performed; identifies the exact archive examined; records policy freshness; and provides a reproducible next action for every blocker/high-risk finding.
