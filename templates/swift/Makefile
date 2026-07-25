# Seed Swift template — convenience entry points.
#
# Run `make bootstrap NAME=YourApp BUNDLE=com.example.yourapp` to
# rename the template and generate the Xcode project in one shot.
# All commands assume macOS + Homebrew.

.DEFAULT_GOAL := help
.PHONY: help bootstrap deps generate clean build test lint format \
        archive release-check bump-patch bump-minor bump-major

NAME   ?= Seed
BUNDLE ?= com.example.seed

help:
	@echo "Seed template — common tasks"
	@echo ""
	@echo "  make bootstrap NAME=<App> BUNDLE=<com.x.y>"
	@echo "      Rename Seed -> <App>, install Homebrew deps, generate .xcodeproj."
	@echo ""
	@echo "  make deps          Install Homebrew deps from Brewfile."
	@echo "  make generate      Run xcodegen to (re)generate the .xcodeproj."
	@echo "  make build         xcodebuild build for iPhone 17 Simulator."
	@echo "  make test          xcodebuild test (all 8 housekeeping tests)."
	@echo "  make lint          swiftlint."
	@echo "  make format        swiftformat (writes changes)."
	@echo "  make archive       Regenerate, preflight, archive, and open Organizer."
	@echo "  make release-check Verify version/signing/project readiness."
	@echo "  make clean         Remove DerivedData + generated project."
	@echo ""
	@echo "  make bump-patch    1.0.0 -> 1.0.1"
	@echo "  make bump-minor    1.0.0 -> 1.1.0"
	@echo "  make bump-major    1.0.0 -> 2.0.0"

bootstrap: deps
	@bin/rename-template.sh "$(NAME)" "$(BUNDLE)"
	@$(MAKE) generate
	@echo ""
	@echo "Template ready. Open $(NAME).xcodeproj in Xcode."

deps:
	@command -v brew >/dev/null 2>&1 || { \
		echo "Homebrew not found. Install from https://brew.sh first."; exit 1; \
	}
	@brew bundle --quiet

generate:
	@xcodegen generate

build:
	@xcodebuild -scheme $(NAME) \
		-destination 'platform=iOS Simulator,name=iPhone 17' \
		clean build

test:
	@xcodebuild -scheme $(NAME) \
		-destination 'platform=iOS Simulator,name=iPhone 17' \
		test

lint:
	@swiftlint

format:
	@swiftformat .

release-check:
	@bin/release-check.sh

archive:
	@bin/archive-ios.sh

clean:
	@rm -rf DerivedData
	@rm -rf *.xcodeproj
	@echo "Cleaned. Run make generate to regenerate the project."

bump-patch:
	@bin/bump-version.sh patch

bump-minor:
	@bin/bump-version.sh minor

bump-major:
	@bin/bump-version.sh major
