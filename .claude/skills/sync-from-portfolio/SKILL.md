---
name: sync-from-portfolio
description: Propagate an improvement from one of your shipped portfolio apps back into the iApp template. Diffs the child app's file against the corresponding template file and prepares a reviewable PR. Sync is opt-in and explicit — children never silently inherit template changes.
---

# /sync-from-portfolio

When a child app proves a pattern works better than the version in `templates/`, this skill brings the improvement upstream. The reverse path — propagating template changes back to children — is also explicit (children must `/sync-from-portfolio --reverse` themselves).

## When to use

- A child app's `Services/HapticManager.swift` evolved and is now better than the template's.
- A new pattern (e.g., Foundation Models gating) was proven in a child app and should become the canonical template version.
- Periodically auditing template freshness against shipped apps.

## When NOT to use

- For ad-hoc one-off improvements that aren't generalizable.
- When the child app's change is app-specific (custom UI, bespoke domain logic).

## Usage

```
/sync-from-portfolio <owner>/<your-app> <YourApp>/Utilities/HapticManager.swift
/sync-from-portfolio <owner>/<your-app> <YourApp>/Services/SubscriptionManager.swift
```

## Steps

1. Parse the arguments: source repo + source file path.
2. Verify the source repo is in the allowed-repos list (from the repository scope).
3. Read the source file at HEAD via `mcp__github__get_file_contents`.
4. Find the corresponding template file (e.g., `<your-app>:<YourApp>/Utilities/HapticManager.swift` → `templates/swift/Seed/Utilities/HapticManager.swift`).
5. If template file doesn't exist yet: this is a *new* harvest, not a sync — treat as such and add a new row to REUSE_INDEX.
6. Diff the source against the template.
7. Show the proposed delta + updated `// SOURCE: <repo>@<sha>:<path>` header.
8. **Confirm with user** before applying — sync is always explicit.
9. On confirm: apply the delta, update the SOURCE header to the new SHA, run `/security-review` on the change, then run `/validate-template` if it's a Swift file.
10. Commit: `sync: <feature> from <repo>@<sha>` with PR description referencing the original upstream commit so rationale is preserved.

## Reliability check

This skill **always** runs `/reliability-check` first. If the source repo is flagged WIP for the feature being synced (e.g., widget code whose l10n is known-broken), refuse with the reason.

## Reverse-sync (child app pulls template improvement)

When a template has evolved and a child app wants the new version:

```
# inside the child app:
/sync-from-portfolio --reverse <owner>/iApp templates/swift/Seed/Utilities/HapticManager.swift
```

Same diff-and-confirm pattern, but reversed. The reverse path is always opt-in because children diverge freely; iApp never silently overwrites them.

## Constraints

- Never auto-apply — sync is always reviewable.
- Always update the `// SOURCE:` header to the new SHA.
- Always preserve the upstream commit reference in the PR description.
- Always run `/reliability-check` first.
- Never sync a file flagged ⚠️ in REUSE_INDEX.

## Cross-references

- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — gold-standard source per feature; WIP flags
- [/reliability-check](../reliability-check/SKILL.md) — pre-flight enforcement
- [/security-review](../security-review/SKILL.md) — post-sync audit
- [docs/CONTRIBUTING.md](../../../docs/CONTRIBUTING.md) — sync-from-portfolio workflow
- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) — templates ↔ children boundary
