---
name: update-config
description: Manage Kindling's .claude/settings.json — permission allowlist, hooks, env vars. Use when adding new bash commands the wizard needs, configuring SessionStart behavior, or troubleshooting hook failures.
---

> SOURCE: universal update-config skill, scoped to Kindling's settings

# /update-config

Kindling's `.claude/settings.json` controls what bash commands run without prompting and what fires on SessionStart. This skill makes safe edits to that file.

## When to use

- A new wizard skill needs to run a bash command that's currently prompting (e.g., adding `awk` or a new git subcommand to the allowlist).
- Changing the SessionStart hook output.
- Adding/removing hooks (PreToolUse, PostToolUse, etc.).
- Configuring env vars the wizard needs.

## When NOT to use

- Changing the *user's* settings (`~/.claude/settings.json`) — that's their concern.
- One-off permission grants — those should stay prompts.

## Safe edits

| Change | How |
|---|---|
| Add a bash command to allow | Add a pattern like `"Bash(<cmd>:*)"` to `permissions.allow` |
| Block a destructive command | Add a pattern to `permissions.deny` (already covers `rm -rf`, force-push, hard reset, etc.) |
| Modify the session-start banner | Edit `.claude/hooks/session-start.sh` (the hook itself, not settings.json) |
| Add a new hook event | Add a new top-level key under `hooks` (e.g., `PreToolUse`) |

## Defaults already enforced

The deny list already includes:
- `rm -rf:*`
- `git push --force:*`
- `git reset --hard:*`
- `git checkout .:*`
- `git restore .:*`
- `git clean -f:*`
- `git branch -D:*`
- `git config --global:*`
- `git commit --no-verify:*`

**Never remove an entry from the deny list.** If you genuinely need one of those operations, run it explicitly with user confirmation, don't pre-allow it.

## Steps

1. Read current `.claude/settings.json`.
2. Make the proposed change.
3. Validate JSON syntax (`jq . settings.json > /dev/null`).
4. Show the diff.
5. Surface for confirmation before saving.

## Cross-references

- Claude Code settings docs: search Anthropic docs for the latest `settings.json` schema
- [docs/CONTRIBUTING.md](../../../docs/CONTRIBUTING.md) — forbidden git operations list
