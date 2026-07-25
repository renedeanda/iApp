---
name: security-review
description: Security audit of pending changes on the current branch. Scans for secrets, dependency risks, manifest leaks, and template-generated code that could ship vulnerabilities. Use before pushing or PR'ing.
---

> SOURCE: universal security-review skill, adapted for Kindling's template-generation responsibilities

# /security-review

Audit-only pass focused on what a template repo can leak. Kindling doesn't ship runtime code, but it ships *patterns* that propagate into every child app. A vulnerable pattern here = N vulnerable apps later.

## When to use

- Before pushing a phase commit.
- Before opening a PR to main.
- When adding a new recipe or template service.
- When updating dependency pins in templates.

## When NOT to use

- During pure doc edits (use `/review` instead).

## Categories scanned

1. **Secrets in committed files** — API keys, signing certs, App Store Connect keys, TelemetryDeck app IDs, Sentry DSNs that should be env-vars.
2. **Privacy manifest completeness** — every required-reason API used in template code is declared in `PrivacyInfo.xcprivacy`.
3. **Entitlements bloat** — entitlement files contain only what's enabled per ADR 004; no leaked Push / Family Controls / etc.
4. **Family Sharing flag honesty** — every IAP / sub in `.storekit` files has `familyShareable` set per ADR 003.
5. **Force-unwrap leaks** — no `!` in production Swift code paths in templates (per CLAUDE.md rule).
6. **Hardcoded URLs** — no analytics endpoints, no remote-config URLs (TelemetryDeck app-id placeholder OK, real endpoints not).
7. **Tracking authorization** — no `requestTrackingAuthorization` calls anywhere in templates (per NOT_FOR.md §7).
8. **Dependency pins** — third-party packages locked to exact versions, not ranges (`exact`, not `from`).
9. **HTTPS-only** — no `NSAllowsArbitraryLoads` in any Info.plist anywhere.
10. **Dev-premium-toggle Apple Review safety** — the `debug.forcePremium` key has the reviewer-suppression code path in template (per HOUSEKEEPING.md).
11. **Easter-egg gating** — prod easter egg has 24h expiry + clear-on-update + reviewer suppression baked in (the 5 conditions from WHATS_ALLOWED.md).
12. **⚠️-source quarantine compliance** — no harvested code from sources flagged ⚠️ in REUSE_INDEX.md.

## Steps

1. Stage and run all 12 checks against the diff for the current branch.
2. For each finding, classify:
   - **Critical** — block the commit/push (secrets, force-unwraps in `_Disabled/`-graduated services)
   - **High** — flag, recommend fix before PR (missing privacy declarations)
   - **Medium** — note for follow-up (dependency ranges, missing tests)
   - **Low** — informational
3. Auto-fix where unambiguous (e.g., delete `.env` if accidentally staged).
4. Surface remaining findings with proposed fixes.

## Output shape

```
Security review — current branch <branch-name>

Critical: 0
High:     1 — templates/swift/Seed/Info.plist missing PrivacyInfo.xcprivacy alongside
Medium:   2 — RN template Package.json uses `^` instead of pinned versions (2 deps)
Low:      0

Auto-fixed: 0 (nothing unambiguous)
Recommend: address High before PR.
```

## Cross-references

- [docs/HOUSEKEEPING.md](../../../docs/HOUSEKEEPING.md) — privacy manifest + dev-toggle pattern
- [docs/APP_STORE_CHECKLIST.md](../../../docs/APP_STORE_CHECKLIST.md) — pre-submission tests
- [docs/NOT_FOR.md](../../../docs/NOT_FOR.md) — tracking + dark patterns rejected
- [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md) — Family Sharing default
