# App Review readiness

## What it adds

A repeatable pre-submission audit that combines current Apple policy, the repo's deterministic launch-packet checks, the final archive, and reviewer-style device checks. The installed `apple-app-review` skill produces a ship/block report and turns missed mechanical checks into scoped deterministic-check follow-ups.

## When to use

- Before TestFlight external testing or App Store submission.
- After adding purchases, login, account/data deletion, UGC, permissions, background modes, extensions, analytics, or an external AI service.
- After a rejection, before writing the Resolution Center response.
- When a built archive exists and source-only readiness claims need verification.

## When NOT to use

- As a promise that Apple will approve the app.
- As a replacement for building, testing, Xcode archive validation, App Store Connect declarations, or device testing.
- To apply every guideline to every app regardless of its features.
- To turn heuristics or keyword matches into automatic blockers.

## How

1. Invoke `.claude/skills/apple-app-review/SKILL.md` (or the `.agents/skills/` compatibility link).
2. Verify the live App Review Guidelines from Apple's official site; record the access date.
3. Run the repo's supported inspection/validation/privacy checks first, then the app's build, tests, and metadata validation.
4. Build the final archive and run `python3 .claude/skills/apple-app-review/scripts/archive_preflight.py path/to/App.xcarchive`.
5. Perform the relevant clean-install/device matrix, including denial, offline, purchase/restore, legal URLs, and deletion paths.
6. Return the skill's evidence-based report. Add mechanically detectable misses to the deterministic-check follow-ups list with a signal, false-positive guard, fixture, and severity.
7. Keep App Store Connect edits, uploads, submissions, URL publishing, and merges manual unless the owner explicitly authorizes them.

The workflow was informed by the MIT-licensed `safaiyeh/app-store-review-skill`, but the portfolio implementation is original and intentionally replaces categorical third-party claims with live Apple-source verification and bounded evidence levels.
