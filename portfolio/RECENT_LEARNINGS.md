# Recent Learnings

A dated changelog of lessons learned across the portfolio. One entry per lesson: date, one-sentence summary, then the detail. Newest first. Skills and docs cross-reference entries here instead of restating them.

iApp ships this file **pre-seeded with the distilled, app-agnostic lessons** that shaped the templates — each one was paid for by a real shipped bug or a real App Store rejection somewhere. Keep them; add your own on top with dates.

---

## Starter lessons (distilled from shipped production apps)

### Widget and extension strings load from the *extension's* bundle

A widget/Live Activity/Control Center surface that renders `"widget.title"` instead of the title means the string was keyed only in the host app's `Localizable.xcstrings`. Extension runtimes resolve strings from the **extension's own bundle** — every extension target ships its own `Localizable.xcstrings`, full stop. This one shipped broken once and cost a point release. Enforced in the template by `WidgetLocalizationParityTests.swift`; see [docs/WIDGETS.md](../docs/WIDGETS.md) rule 2 and `recipes/swift/extension-localization.md`.

### App Intents strings load from the intent's bundle

Same trap, different surface: intent titles and parameter prompts resolve from the bundle that *declares* the intent. If intents live in the widget extension, their strings must too.

### A localized key can still leak its raw ID (interpolation trap)

`Text("greeting.\(style)")` builds the key at runtime — the string extractor never sees it, so it silently falls out of every catalog. Keys must be string literals; interpolate *values*, never *key fragments*.

### The 64-notification limit is a hard ceiling

iOS caps pending local notifications at 64 per app — sched­ule number 65 and iOS silently drops the oldest. Any recurring-reminder feature needs a rolling window: schedule the next N occurrences, re-fill on every app open and on `didReceive`. The RN template's `NotificationService.ts` implements this.

### `setHours`/`setMinutes` matters for iOS notification scheduling (RN)

Constructing trigger dates by string parsing breaks across time zones and DST. Build dates with explicit `setHours`/`setMinutes` on a local-time `Date`, and test the DST boundary weeks.

### On-device AI needs a deterministic fallback, always

`#if canImport(FoundationModels)` at compile time, a runtime availability check, and a `nil` return path the caller *handles with real UX* — not a spinner. The feature must degrade to something deterministic and useful on unsupported devices, or it isn't shippable.

### The pre-iOS-18 sandbox-receipt check is dead

`appStoreReceiptURL == "sandboxReceipt"` stopped being a reliable environment signal. Gate debug/dev behavior on `AppTransaction.environment` instead — the template's `DebugUnlock.swift` is the reference.

### Hand-rolled CloudKit bridges in RN are a maintenance trap

A custom native CloudKit bridge works on day 1 and rots by month 3 (entitlement drift, silent `UserDefaults(suiteName:)` failures, schema migrations). Use a clean, small Expo module with an explicit surface — the template's `modules/icloud-sync/` — and let the user's own iCloud do the syncing.

### XcodeGen `sources:` globs may not bundle `.xcprivacy` files

A privacy manifest that isn't pinned as an explicit resource in `project.yml` can silently miss the bundle — and App Store Connect only tells you at submission. Pin each target's `PrivacyInfo.xcprivacy` explicitly; `PrivacyManifestTests` enforces the host pin.

### Archive validation must inspect embedded extension profiles

An `.ipa` can build green while an embedded extension carries the wrong provisioning profile or a stale entitlement. Pre-submission checks must open the archive and verify each embedded target, not just the host.

### App Store screenshots must be real app captures

Composited mockups drift from the shipping product and invite rejection under 2.3.7. Capture the real app (Simulator is fine), then compose the marketing frame around real pixels. The graphics tool in `tools/app-store-graphics/` assumes real captures as input.

### `ITSAppUsesNonExemptEncryption = NO` saves a question per submission

If the app only uses standard HTTPS/OS crypto, declare it in the Info.plist once instead of answering the export-compliance questionnaire on every single build upload.

### Haptic vocabulary is a finite resource

Users habituate: a dozen distinct haptic patterns feel like noise; three feel like language. Start every app with 3; earn additions deliberately (`/earn-haptic`), soft cap 8.

### Delight moments have the same bandwidth problem

Micro-animations compete for the same attention budget. Cap at 5 per app; each must be tied to a specific user action and must degrade gracefully under Reduce Motion.

### An ADR that produces no code is a gap

A "signature motion" that exists only as a decision doc never ships. Every design ADR needs a code artifact the build can verify — the template's `SignatureMotionWiredTests` fails the build when the motion ADR has no `.signatureMotion()` call site.

### A template is not verified until the rendered test host runs

Template code that compiles in the template repo can still fail after rename/render (stale bundle IDs, missed file renames, placeholder leaks). The verify scripts render a child app and run *its* tests — that's the bar.

### Accessibility layouts must change shape, not merely grow

At the largest Dynamic Type sizes, scaling a fixed layout produces truncation. Grids must reflow to lists; multi-column must collapse. Test at `AX5`, not just `XL`.

### iCloud data deletion is a danger-zone pattern

"Delete my data" belongs behind an explicit danger-zone section with typed confirmation — not a root Settings row. And deletion must cover *all* stores: local, CloudKit private DB, and any App Group container, verified with a read-back. See [docs/ICLOUD_DATA_DELETION.md](../docs/ICLOUD_DATA_DELETION.md).

### Reversible customization must not look like deletion

Letting users hide/reorder shelves or shortcuts is customization; if the affordance looks destructive ("remove"), users fear data loss and never touch it. Label reversible actions as reversible ("hide", "reset to defaults").

### Cross-promo lists must be live-apps-only and self-excluding

A "More from us" section that links an unreleased app is a broken promise (and a rejection risk). Render only entries with a real App Store URL; exclude the current app by bundle ID. The template's `PortfolioRegistry.swift` implements this.

---

## How to add a learning

```markdown
## YYYY-MM-DD — <One-sentence summary>

<2–6 lines of detail: what happened, what the fix was, where the
enforcement now lives (test / script / skill), and links.>
```

Add the entry at the **top** of the file (below this header block). If the lesson changes a reliability judgment, update [REUSE_INDEX.md](REUSE_INDEX.md) in the same PR. If it changes a taste rule, propose the CLAUDE.md edit in the same PR too.
