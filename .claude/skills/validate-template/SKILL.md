---
name: validate-template
description: Verify a template (or a freshly-rendered child app from /new-app --commit) builds clean and passes all 8 housekeeping tests. Used inside /new-app --commit step 5; also runs in CI on every Kindling PR touching templates/.
---

# /validate-template

The end-to-end check that a generated repo actually works. Runs the Swift OR RN verify-script per the template, then the 9 housekeeping tests, then reports a pass/fail dashboard.

## When to use

- Automatic — inside `/new-app --commit` step 5, after templates are rendered into the new repo.
- Manual — when an Kindling PR touches `templates/` and you want to verify the change before push.
- Periodically — the end-to-end smoke test re-runs this.

## When NOT to use

- For unit-level changes to a single skill or doc — overkill.
- For RN-only changes when you only want to validate Swift template — pass `--swift-only` or `--rn-only`.

## Swift validation (when template = swift)

1. `cp -r templates/swift/ /tmp/kindling-verify/`
2. `cd /tmp/kindling-verify/`
3. `make bootstrap NAME=VerifyApp BUNDLE=com.example.verify`
   - Runs `scripts/rename-template.sh` (substitutes Seed → VerifyApp throughout)
   - Runs `xcodegen generate`
4. `xcodebuild -scheme VerifyApp -destination 'platform=iOS Simulator,name=iPhone 17' clean build`
   - Must succeed with 0 errors, 0 warnings (warnings-as-errors in CI).
5. `xcodebuild -scheme VerifyApp -destination '...' test`
   - All 9 housekeeping tests must pass:
     1. `AppIconAssetTests`
     2. `PrivacyManifestTests`
     3. `LocalizationParityTests`
     4. `WidgetLocalizationParityTests`
     5. `ThemeContrastTests`
     6. `HapticPatternTests`
     7. `SignatureMotionWiredTests` — the signature-motion ADR→code gate: `Theme/SignatureMotion.swift` exists AND something applies `.signatureMotion()` under `Views/`. A motion ADR with no call site fails the build.
     8. `WidgetEdgeToEdgeTests` (if widgets enabled)
     9. `LiveActivityViewTests` (if Live Activities enabled)

## RN validation (when template = rn)

1. `cp -r templates/rn/ /tmp/kindling-verify-rn/`
2. `cd /tmp/kindling-verify-rn/`
3. `npm install`
4. `npx tsc --noEmit` (strict TypeScript)
5. `npx jest` (test suite passes)
6. `npx expo prebuild --clean --platform ios --no-install`
   - Verifies Expo config plugins (withWidgetExtension, withICloudEntitlements, withAppGroup) generate valid native projects.

## Additional Kindling-specific checks (regardless of template)

7. **Reliability matrix sync** — every `// SOURCE:` header in template files points to a row in REUSE_INDEX, and no header points to a row flagged ⚠️.
8. **Privacy manifest API coverage** — every required-reason API actually used in template code is declared in `PrivacyInfo.xcprivacy`.
9. **⚠️-source quarantine compliance** — no template file's SOURCE header points to a source flagged ⚠️ in REUSE_INDEX.
10. **Dev-toggle wiring** — `Seed/Services/SubscriptionManager.swift` has the `debug.forcePremium` short-circuit AND the 24h-auto-clear logic AND the reviewer-suppression check.

## Output shape

```
validate-template — templates/swift/ — <date>

Swift build:                ✓ pass
Swift tests (9):            ✓ pass (9/9)
RN tsc:                     n/a (--swift-only)
RN jest:                    n/a
Expo prebuild:              n/a

Kindling-specific:
  Reliability matrix sync:  ✓ all SOURCE headers valid
  Privacy manifest:         ✓ all declared
  ⚠️-source quarantine:     ✓ no code from flagged sources
  Dev-toggle wiring:        ✓ all 3 checks pass

Result: VALIDATED. Safe to push.
```

If anything fails:
- Surface the specific test / file / line.
- Refuse to proceed (in `/new-app --commit` context — don't create the GitHub repo until validation passes).
- Suggest the relevant skill to fix (e.g., `/security-review` for privacy issues).

## Cross-references

- [docs/HOUSEKEEPING.md](../../../docs/HOUSEKEEPING.md) — the 8 housekeeping tests + dev-toggle pattern
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — reliability matrix for SOURCE-header validation
- [/security-review](../security-review/SKILL.md) — privacy + security follow-up if validation flags issues
- [DECISIONS/005-launch-readiness.md](../../../DECISIONS/005-launch-readiness.md) — the end-to-end smoke test depends on this skill
