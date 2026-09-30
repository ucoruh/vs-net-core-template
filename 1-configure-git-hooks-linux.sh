#!/bin/bash
# Installs the pre-commit hook (scripts/hooks/pre-commit: formats staged .cs files with astyle and
# checks that .gitignore / README.md / Doxyfile exist). Safe to re-run: an existing hook is backed up once.
set -e
cd "$(dirname "$0")"

HOOKS_DIR="$(git rev-parse --git-path hooks 2>/dev/null)" || { echo "[ERROR] Not a git repository. Clone your repository first." >&2; exit 1; }
mkdir -p "$HOOKS_DIR"
if [ -f "$HOOKS_DIR/pre-commit" ] && [ ! -f "$HOOKS_DIR/pre-commit.backup" ]; then
    echo "Backing up the current pre-commit hook to pre-commit.backup ..."
    cp "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.backup"
fi
cp scripts/hooks/pre-commit "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo "Installed the pre-commit hook into $HOOKS_DIR."
