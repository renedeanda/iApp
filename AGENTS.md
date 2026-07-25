# AGENTS.md — iApp

> Instructions for AI coding agents (Codex, and any agent that reads AGENTS.md).
> Claude Code reads [CLAUDE.md](CLAUDE.md) natively — that file is the **canonical constitution** for this repo. This file tells every other agent to honor the same contract.

## First, read the constitution

Read [CLAUDE.md](CLAUDE.md) in full before doing anything else. It defines:

- **The eight taste rules** (services default off, earned haptics, design-before-tech, visual-identity novelty, palette departure deltas, the mandatory overnight pause, the NOT_FOR philosophy, source-grounding for new app picks).
- **The design philosophy** (no pure `#000`/`#FFF`, AAA contrast, Reduce Motion/Haptics respect, i18n from day 1, widget strings in the extension's own bundle).
- **The code-quality rules** (no force-unwraps, no hardcoded UI strings, views ≤300 lines, one `@Observable` per concern, no new deps without an ADR).
- **The Forbidden list** (never commit secrets, never force-push main, never edit outside task scope, never create stray status/report files in the repo root).

Treat every rule there as binding in this session, exactly as a Claude Code session would.

## Skills are contracts, not suggestions

Reusable workflows live as plain-Markdown contracts in `.claude/skills/<name>/SKILL.md` (and per-template under `templates/*/.claude/skills/`). A mirror entry point for non-Claude agents exists at `.agents/skills/`. You can execute any of them: open the SKILL.md, follow its steps in order, and produce the artifacts it names. Highlights:

| Skill | Purpose |
|---|---|
| `start` | Route a new user by experience level (novice → tutorial; idea-ready → the wizard) |
| `new-app` | The 21-step design-first wizard: `--draft` writes 17 ADRs, `--commit` renders a template *after a mandatory overnight pause* |
| `pick-palette`, `pick-visual-identity`, `pick-signature-motion`, `pick-typography`, `pick-haptic-vocabulary`, `pick-delight-moments`, `pick-tech`, `pick-monetization` | The individual design decisions, each writing a numbered ADR |
| `review`, `security-review`, `reliability-check`, `validate-template` | Quality gates |
| `apple-app-review`, `analytics-audit`, `app-store-aso`, `record-app-store-video` | Release readiness |

Two contract points agents must not shortcut:

1. **When a SKILL.md says to ask the user a question, actually stop and ask.** Do not answer design questions on the user's behalf to save time — the audit trail is the product.
2. **The overnight pause is structural.** `/new-app --commit` runs `check-draft-mtime.sh` and refuses drafts younger than 12 hours. Do not work around it.

## Repo map

- `templates/swift/`, `templates/rn/` — the two runnable starter scaffolds (see each one's `CLAUDE.md`/`AGENTS.md` + `README.md`).
- `DECISIONS/` — the ADR library the wizard copies into child apps.
- `recipes/` — ~50 feature guides; read the "When NOT to use" section first.
- `portfolio/` — the user's own portfolio memory (starter state); several skills read/write it.
- `docs/` — philosophy, checklists, glossary, and the first-app tutorial for novices.
- `scripts/` — template verification; run these after touching `templates/`.

## Verification before you finish any templates/ change

```sh
./scripts/check-recipe-sources.sh     # recipe citations resolve
./scripts/verify-rn-template.sh       # RN template renders + tests green
./scripts/verify-swift-template.sh    # Swift template renders + tests green (needs macOS)
```
