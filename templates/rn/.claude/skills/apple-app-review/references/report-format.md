# Report format

## Decision

`SHIP`, `SHIP WITH MANUAL CHECKS`, or `BLOCK` — one-sentence rationale.

## Scope and freshness

- repo/ref and dirty state
- archive path, bundle ID, version/build, targets
- device/OS used
- Apple guideline access date/revision
- release-tooling version/commit and commands run

## Findings

| Severity | Confidence | Evidence | Finding | Guideline | Fix / verify |
|---|---:|---|---|---|---|

Use exact clickable file paths or archive keys. Quote errors verbatim but keep excerpts short. Mark inference as inference.

## Verified passes

List only checks performed with their evidence source.

## Manual review matrix

| Check | Status | Observation / required action |
|---|---|---|

Use `PASS`, `FAIL`, or `NOT RUN`; never assume.

## Tooling follow-ups

| Gap | Proposed rule | Signal + guard | Fixture | Severity |
|---|---|---|---|---|

Write `None` if deterministic tooling caught every mechanically detectable finding.

## Submission checklist

Give the shortest ordered list that turns the current decision into `SHIP`. Keep App Store Connect/manual owner actions separate from code changes.
