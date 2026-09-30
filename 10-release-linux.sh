#!/bin/bash
# 10-release-linux.sh [--dry-run]
#   Builds everything locally (./7-build-all-linux.sh) and publishes the release/ folder as a GitHub
#   Release with the GitHub CLI. The version comes from project.env (VERSION=2.1.0 -> tag v2.1.0);
#   change it there, commit, then release. Works on private repositories and on GitHub Free; uses no
#   Actions minutes. Locally the release holds THIS platform's assets plus the neutral ones -- CI
#   builds both platforms (and macOS); if the tag's release already exists this script uploads its
#   assets to it instead of creating a new one.
#   --dry-run  builds and packs, prints the exact gh command and the asset list, publishes nothing.
# See docs/guide/releases-and-private-repos.en.md and docs/guide/showing-without-pages.en.md.
set -e
cd "$(dirname "$0")"
. scripts/dotnet-env-linux.sh

DRY_RUN=0
for a in "$@"; do [ "$a" = "--dry-run" ] && DRY_RUN=1; done
TAG="v$VERSION"

echo "============================================================"
echo " $PROJECT_NAME :: 10-release (linux) :: $TAG"
[ "$DRY_RUN" = "1" ] && echo " Mode: DRY RUN -- nothing will be published"
echo "============================================================"
echo

if ! command -v gh >/dev/null 2>&1; then
    echo "[ERROR] GitHub CLI (gh) not found. Install it (see docs/guide/install.en.md), then run \"gh auth login\"." >&2
    [ "$DRY_RUN" = "0" ] && exit 1
fi
GH_LOGGED_IN=0
command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && GH_LOGGED_IN=1
[ "$GH_LOGGED_IN" = "0" ] && echo "[WARN] gh is not logged in (run \"gh auth login\"). Fine for --dry-run; a real release needs it."
if [ "$DRY_RUN" = "0" ] && [ "$GH_LOGGED_IN" = "0" ]; then
    echo "[ERROR] gh is not logged in. Run \"gh auth login\", then re-run this script." >&2
    exit 1
fi
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    if [ "$DRY_RUN" = "0" ]; then
        echo "[ERROR] Working tree has uncommitted changes. Commit or stash them before a real release. (--dry-run skips this check.)" >&2
        exit 1
    fi
    echo "[WARN] Uncommitted changes -- fine for --dry-run, a real release refuses this."
fi
echo

echo "[1/2] Building everything (7-build-all-linux)..."
./7-build-all-linux.sh
echo

echo "[2/2] Assets in release/ :"
ls -1 release | sed 's/^/  release\//'
echo

RELEASE_EXISTS=0
[ "$GH_LOGGED_IN" = "1" ] && gh release view "$TAG" >/dev/null 2>&1 && RELEASE_EXISTS=1
if [ "$RELEASE_EXISTS" = "1" ]; then
    GH_ARGS=(release upload "$TAG" release/* --clobber)
else
    GH_ARGS=(release create "$TAG" release/* --title "$PROJECT_NAME $VERSION" --notes-file build/release-notes.md)
fi

if [ "$DRY_RUN" = "1" ]; then
    echo "[DRY RUN] Would run:"
    echo "  gh ${GH_ARGS[*]}"
    echo "No release was created (--dry-run). Remove --dry-run to publish for real."
    exit 0
fi
echo "Publishing $TAG ..."
gh "${GH_ARGS[@]}"
echo "Done. Add your instructor as a collaborator so they can see a private release."
