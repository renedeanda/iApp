#!/usr/bin/env bash
#
# rename-template.sh — wizard plumbing
#
# Substitute every "Seed" identifier, "com.example.seed" bundle
# id, "iCloud.com.example.seed" container, and
# "group.com.example.seed" app-group throughout the tree with
# the new app's chosen values. Called by `make bootstrap` and by the
# Kindling wizard at /new-app --commit time.
#
# Substitution order matters — more-specific tokens first so we don't
# replace a substring of a longer token.
#
# Usage: bin/rename-template.sh <NewName> <bundle.id>

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <NewName> <bundle.id>"
  echo "Example: $0 MyApp com.example.myapp"
  exit 1
fi

NEW_NAME="$1"
BUNDLE_ID="$2"

if [ ! -d "Seed" ]; then
  echo "Seed/ not found. Run from the template root (where Brewfile lives)."
  exit 1
fi

echo "Renaming Seed -> ${NEW_NAME}"
echo "Bundle id  -> ${BUNDLE_ID}"
echo ""

# Files to substitute strings in (file types only, never binary).
# project.yml lives at the template root; SeedWidgets/ is a sibling of
# Seed/. The child app's own .claude/ skills cite Seed/ paths and the
# Seed scheme — they must be rewritten too or every skill points at a
# directory that no longer exists.
TEXT_FILES=$(find Seed SeedTests SeedWidgets .claude project.yml -type f \( \
    -name "*.swift" \
    -o -name "*.plist" \
    -o -name "*.yml" \
    -o -name "*.xcconfig" \
    -o -name "*.entitlements" \
    -o -name "*.xcprivacy" \
    -o -name "*.storekit" \
    -o -name "*.xcstrings" \
    -o -name "Contents.json" \
    -o -name "*.md" \
    -o -name "*.sh" \
\))

# Root-level config files that also carry "Seed" or the bundle id but
# live outside the source dirs. Listed explicitly because a blind find
# would catch bin/rename-template.sh itself — whose own "Seed" logic
# must survive. Every file below ships in the template.
ROOT_FILES="Makefile README.md CLAUDE.md .swiftlint.yml .bundle/config \
.github/workflows/ci.yml .githooks/pre-commit \
fastlane/Appfile fastlane/Fastfile fastlane/Gemfile fastlane/Matchfile \
bin/bump-version.sh bin/archive-ios.sh bin/check-bundle-resources.sh \
.release.json RELEASE.md"

TEXT_FILES="$TEXT_FILES $ROOT_FILES"

# 1. App-group identifier (most specific token first).
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|group\\.com\\.example\\.seed|group.${BUNDLE_ID}|g"

# 2. iCloud container identifier.
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|iCloud\\.com\\.example\\.seed|iCloud.${BUNDLE_ID}|g"

# 3. Plain bundle id (and the .pro.* product id stems).
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|com\\.example\\.seed|${BUNDLE_ID}|g"

# 3b. Lowercase app-id tokens (release conventions in .release.json /
# RELEASE.md: the appId field and the metadata filename stem).
LOWER_NAME=$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]')
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|seed-app-store-metadata|${LOWER_NAME}-app-store-metadata|g" \
    -e "s|\"appId\": \"seed\"|\"appId\": \"${LOWER_NAME}\"|g"

# 4. App entry type SeedApp (must precede the bare Seed substitution).
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|SeedApp|${NEW_NAME}App|g"

# 5. SeedWidgets (must precede Seed).
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|SeedWidgets|${NEW_NAME}Widgets|g"

# 6. SeedTests (must precede Seed).
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|SeedTests|${NEW_NAME}Tests|g"

# 7. Plain Seed -> NewName.
echo "$TEXT_FILES" | xargs sed -i.bak \
    -e "s|Seed|${NEW_NAME}|g"

# Clean up backup files from sed.
find Seed SeedTests SeedWidgets .claude -name "*.bak" -delete
rm -f project.yml.bak
for f in $ROOT_FILES; do rm -f "$f.bak"; done

# 8. Rename files + directories.
mv "Seed/SeedApp.swift" "Seed/${NEW_NAME}App.swift"
mv "Seed/Seed.entitlements" "Seed/${NEW_NAME}.entitlements"
mv "Seed/Seed-macOS.entitlements" "Seed/${NEW_NAME}-macOS.entitlements"
mv "Seed/Seed.storekit" "Seed/${NEW_NAME}.storekit"
mv "Seed/Intents/SeedIntents.swift" "Seed/Intents/${NEW_NAME}Intents.swift"
mv "Seed/Intents/SeedShortcutsProvider.swift" "Seed/Intents/${NEW_NAME}ShortcutsProvider.swift"

# Widget extension sources (the build target stays gated in project.yml
# until the wizard enables it, but the files are renamed either way so
# the wizard only has to uncomment, never rename).
mv "SeedWidgets/SeedActivityAttributes.swift" "SeedWidgets/${NEW_NAME}ActivityAttributes.swift"
mv "SeedWidgets/SeedLiveActivity.swift" "SeedWidgets/${NEW_NAME}LiveActivity.swift"
mv "SeedWidgets/SeedWidget.swift" "SeedWidgets/${NEW_NAME}Widget.swift"
mv "SeedWidgets/SeedWidgetBundle.swift" "SeedWidgets/${NEW_NAME}WidgetBundle.swift"
mv "SeedWidgets/SeedWidgets.entitlements" "SeedWidgets/${NEW_NAME}Widgets.entitlements"

mv "Seed" "${NEW_NAME}"
mv "SeedTests" "${NEW_NAME}Tests"
mv "SeedWidgets" "${NEW_NAME}Widgets"

echo ""
echo "Done. Next: make generate (or open ${NEW_NAME}.xcodeproj after xcodegen)."
