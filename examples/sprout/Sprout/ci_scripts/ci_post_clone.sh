#!/bin/bash
#
# Xcode Cloud post-clone bootstrap.
#
# Xcode Cloud clones the repo fresh on every build and tries to open
# the .xcodeproj directly. Since we never commit the generated project
# (project.yml is the source of truth), this script runs the
# regeneration before Xcode looks for the project file.
#
# Source pattern: proven in a shipped production app (verbatim shape).

set -euxo pipefail

brew install xcodegen

cd "${CI_PRIMARY_REPOSITORY_PATH}/Sprout"
xcodegen generate
