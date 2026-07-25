#!/usr/bin/env bash
# Session-start hook for Kindling.
# Prints a short banner so every session starts with the most-important
# context without scrolling.
set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo "unknown")

cat <<EOF
====================================================================
Kindling session — read CLAUDE.md first, then proceed.

Active branch: ${BRANCH}
Last commit:   ${LAST_COMMIT}

PORTFOLIO
  Your portfolio at a glance lives in portfolio/PORTFOLIO.md — fill it
  in as you ship apps from this repo.

RELIABILITY
  Check portfolio/REUSE_INDEX.md before harvesting any capability;
  the templates ship the gold-standard scaffolds.

WHEN IN DOUBT
  Read CLAUDE.md → relevant ADR in DECISIONS/ → portfolio/REUSE_INDEX.md
====================================================================
EOF
