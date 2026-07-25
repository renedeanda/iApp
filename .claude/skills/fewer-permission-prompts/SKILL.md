---
name: fewer-permission-prompts
description: Scan recent transcripts for common Bash and MCP tool calls that triggered prompts, then propose a prioritized allowlist addition to .claude/settings.json. Reduces friction without weakening safety.
---

> SOURCE: universal fewer-permission-prompts skill

# /fewer-permission-prompts

When a wizard skill prompts the user for permission on the same bash command 5+ times, that's friction worth removing. This skill identifies those patterns and proposes settings.json updates.

## When to use

- After running a wizard end-to-end (`/new-app`) and noticing repeated prompts.
- Periodically as new skills land and shake out new prompt-heavy operations.

## When NOT to use

- For commands in the deny list — those exist for a reason.
- For one-off operations — not worth allowlisting.

## Steps

1. Read recent shell history / transcript.
2. Count Bash invocations per pattern.
3. For patterns invoked ≥5 times that aren't in `permissions.allow` or `permissions.deny`:
   - Classify safety (read-only ✓ / write-local ⚠️ / write-remote ⛔)
   - Propose addition only for read-only or local-write-where-the-context-makes-sense
4. Show proposed `settings.json` diff.
5. Cross-check against `/update-config` safety rules before applying.

## Example output

```
Recent prompt patterns (top 10):

  47×  Bash(xcodegen generate)     — local write, safe-to-allow ✓
  31×  Bash(jq '.foo' file.json)   — read-only, safe-to-allow ✓
  18×  Bash(grep -rn ...)           — read-only, already allowed
  9×   Bash(git push origin ...)    — remote write, KEEP PROMPTING ⛔

Proposed addition to permissions.allow:
  + "Bash(xcodegen:*)",
  + "Bash(jq:*)"

These cut 78 prompts/session. Apply?
```

## Cross-references

- [`.claude/settings.json`](../../../.claude/settings.json)
- [/update-config](../update-config/SKILL.md) — for applying the change
