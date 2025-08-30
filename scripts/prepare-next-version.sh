#!/usr/bin/env bash
#
# Adds a [Unreleased] section to the CHANGELOG.md and commits the update.

set -euo pipefail

readonly REPO_URL="https://github.com/jnk22/libreelec-git-command"
readonly CHANGELOG_FILE="CHANGELOG.md"
readonly BUMP_VERSION_FILE=".bumpversion.toml"
readonly COMMIT_MESSAGE="docs(changelog): add [Unreleased] section"
readonly UNRELEASED_SECTION="## [Unreleased]"

function error() {
  echo "ERROR: $1" >&2
  exit 1
}

# Verify preconditions.
[[ -f "$CHANGELOG_FILE" ]] || error "File $CHANGELOG_FILE not found"
[[ -f "$BUMP_VERSION_FILE" ]] || error "File $BUMP_VERSION_FILE not found"
[[ -z "$(git status --porcelain)" ]] || error "Git working directory is dirty. Commit or stash changes first."
grep -Fq "$UNRELEASED_SECTION" "$CHANGELOG_FILE" && error "[Unreleased] section already exists in $CHANGELOG_FILE"

current_version=$(grep -Po '^\s*current_version\s*=\s*"\K[^"]+' "$BUMP_VERSION_FILE")
unreleased_section_full="$UNRELEASED_SECTION\n\n...\n"
unreleased_link="[Unreleased]: $REPO_URL/compare/v${current_version}...HEAD"

tmp_file=$(mktemp) || error "Failed to create temporary file"

# Prepend [Unreleased] before first ## header.
awk -v section="$unreleased_section_full" '
    BEGIN { inserted = 0 }
    /^## / && !inserted { print section; inserted = 1 }
    { print }
' "$CHANGELOG_FILE" >"$tmp_file"

# Add comparison link above current version link.
awk -v link="$unreleased_link" -v version="$current_version" '
    BEGIN { inserted = 0 }
    $0 ~ "\\[" version "\\]:" && !inserted { print link; inserted = 1 }
    { print }
' "$tmp_file" >"$CHANGELOG_FILE"

rm -f "$tmp_file"

git add "$CHANGELOG_FILE"
git commit --message "$COMMIT_MESSAGE"

echo "SUCCESS: [Unreleased] section added and committed"
