# Seed RN template — convenience entry points.
#
# CLAUDE.md's "Bumping version" section references these targets, so
# anything documented there belongs here. RN-side conventions otherwise
# defer to npm scripts (see package.json).

.DEFAULT_GOAL := help
.PHONY: help dev prebuild ios android archive test lint format typecheck \
        bump-patch bump-minor bump-major

help:
	@echo "Seed template — common tasks"
	@echo ""
	@echo "  make dev           Start the Expo dev server (telemetry off)."
	@echo "  make prebuild      Generate ios/ + android/ from app.json."
	@echo "  make ios           expo run:ios (Simulator)."
	@echo "  make android       expo run:android (Emulator)."
	@echo "  make archive       Prebuild iOS, install pods, archive, and open Organizer."
	@echo "  make test          jest (housekeeping + suite)."
	@echo "  make typecheck     tsc --noEmit."
	@echo "  make lint          expo lint."
	@echo "  make format        prettier --write ."
	@echo ""
	@echo "  make bump-patch    1.0.0 -> 1.0.1"
	@echo "  make bump-minor    1.0.0 -> 1.1.0"
	@echo "  make bump-major    1.0.0 -> 2.0.0"

dev:
	@npm run dev

prebuild:
	@npm run prebuild:clean

ios:
	@npm run ios

android:
	@npm run android

archive:
	@npm run archive

test:
	@npm test

typecheck:
	@npm run typecheck

lint:
	@npm run lint

format:
	@npm run format

bump-patch:
	@bin/bump-version.sh patch

bump-minor:
	@bin/bump-version.sh minor

bump-major:
	@bin/bump-version.sh major
