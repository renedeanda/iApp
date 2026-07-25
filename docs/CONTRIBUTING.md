# Contributing to iApp

Thanks for wanting to make iApp better. Contributions take three forms:

1. **From one of your apps back to the template** — sync a proven improvement upstream.
2. **From a new lesson to the docs** — add a learning, a delight pattern, an identity, a recipe.
3. **Code contributions** — templates, tests, scripts, wizard skills.

This doc explains all three, plus the conventions every PR follows.

## Getting started

1. Fork the repo and create a topic branch from `main`.
2. Read [CLAUDE.md](../CLAUDE.md) — it's the taste-rule contract every change is reviewed against.
3. If your change touches `templates/`, run the verify scripts locally (`templates/swift/bin/verify-*.sh`, `npm test` in `templates/rn/`) before opening the PR — CI runs the same checks.
4. Open a PR against `main`. Small and focused beats large and sweeping.

## Path 1 — Sync from one of your apps back to the template

When an app generated from these templates proves a pattern works better than the version in `templates/`, the path is:

```
$ /sync-from-portfolio <owner>/<your-app> Sources/Utilities/HapticManager.swift

Reading templates/swift/Seed/Utilities/HapticManager.swift...
Reading <owner>/<your-app>@HEAD:Sources/Utilities/HapticManager.swift...

Diff:
+ // New private helper for transient coalesce window
+ private func coalesceWindow(...) { ... }

Proposed: open PR to templates/swift/Seed/Utilities/HapticManager.swift
with the above delta. Also update the SOURCE: header to the new SHA.

Confirm? (y/n)
```

The skill:

1. Reads the named source file at HEAD of the upstream repo.
2. Diffs against the corresponding template file.
3. Opens a PR with the delta + updated `// SOURCE: <repo>@<sha>:<path>` header.
4. PR description references the original commit in the upstream repo so the rationale is preserved.

Sync is opt-in and explicit. Child apps never silently inherit template changes — and the template never silently inherits child changes.

## Path 2 — Doc updates

Most contributions are doc-only. The big four:

### 2a. New lesson learned

Open a PR to [portfolio/RECENT_LEARNINGS.md](../portfolio/RECENT_LEARNINGS.md):

```markdown
## YYYY-MM-DD — Widget l10n trap
When localizing widget strings via the host app's xcstrings only, widget surfaces render the key (or English fallback). Live Activities and widget extensions load strings from the *extension's own* bundle. Fix: ship a separate `Localizable.xcstrings` in the widget target. See docs/WIDGETS.md rule 2.
```

One date, one sentence summary, one paragraph of detail (max). If the lesson changes a rule, link to the rule.

### 2b. New delight moment

Open a PR to [docs/DELIGHT_REEL.md](DELIGHT_REEL.md) adding a row to the relevant pattern table:

```markdown
| **New pattern name** | what it is | what user action fires it | Reduce Motion fallback |
```

The new pattern must:

- Have shipped in a real app (yours counts — say so in the PR description).
- Tie to a specific user action.
- Pass the forbidden-delights checklist at the bottom of DELIGHT_REEL.md.

### 2c. New visual identity

Open a PR to [docs/VISUAL_IDENTITIES.md](VISUAL_IDENTITIES.md). The PR must:

- Add a section in the form of the existing eight.
- Cite a shipped app as proof (not aspirational).
- Justify why none of the existing eight fit.

The wizard's `/pick-visual-identity` skill picks up the new identity automatically on the next session.

### 2d. New rule or rule change

If you discover a rule in [docs/PHILOSOPHY.md](PHILOSOPHY.md) or the [CLAUDE.md](../CLAUDE.md) Taste Rules section is wrong, the PR must:

- Name the specific feature in the specific app that proved it wrong.
- Propose the rule change.
- Update any skills that depend on the rule.

Rules don't get changed in a Slack thread.

## Path 3 — Code contributions

Templates, tests, scripts, and wizard skills all welcome PRs. Ground rules:

1. **Templates are load-bearing.** A bug in `templates/` ships into every future generated app. Every template change needs a passing verify script or test.
2. **Skills need artifacts.** If your new wizard rule *must* hold, back it with a check (a script, a test, a file-presence gate) — not just SKILL.md prose. See the maturity matrix in [CLAUDE.md](../CLAUDE.md).
3. **One concern per PR.** Don't batch unrelated fixes.

### Commit conventions

- Imperative mood, ≤72 chars subject, optional body.
- No "wip" / "fix" / "checkpoint" commits on shared branches. Squash before push.

### PR conventions

- PR title: one-line summary of the change.
- PR body: bullet list of what was added/changed and why.
- Self-review checklist:
  - [ ] All harvested files have an appropriate `SOURCE: repo@sha:path` header.
  - [ ] No secrets, no `.env`, no certs.
  - [ ] Docs cross-reference correctly (no broken intra-repo links).
  - [ ] CLAUDE.md taste rules respected.
  - [ ] Verify scripts / tests pass locally.

## Forbidden contributions

- **No automated formatters that rewrite every file.** PRs must be focused.
- **No "cleanup" PRs that touch unrelated files.** One concern per PR.
- **No third-party SDK additions without an ADR.** Add `DECISIONS/NNN-dependency-<name>.md` first.
- **No harvesting widget/Live Activity/Control Center code from unproven sources.** The template's widget scaffold is the gold standard; `/reliability-check` blocks WIP harvests in the wizard, and reviewers block them here.
- **No "I added emoji to make it friendly" PRs.** Avoid emoji unless the user explicitly requests them.

## Reviewing PRs

When reviewing a contribution:

1. **Does it match the architecture?** New thing goes in the right layer (see [ARCHITECTURE.md](ARCHITECTURE.md))?
2. **Does it respect taste rules?** Reduce Motion gating, AAA contrast, Sendable purity, no force-unwraps?
3. **Does it cross-reference?** New doc links back to relevant existing docs?
4. **Does it have proof?** New rule cites a real app. New delight cites a real shipped pattern. New identity cites a real shipped product.
5. **Is restraint visible?** Was the smallest change made that solves the problem? No incidental refactors?

If any answer is no, request a follow-up. Don't merge to "save time."

## License contribution

By contributing, you agree your contribution is licensed under the same MIT license as the repo. See [LICENSE](../LICENSE).
