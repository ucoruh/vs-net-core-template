#!/bin/bash
# 4-install-tools-linux.sh -- installs every tool the other scripts need (Ubuntu/Debian, native Linux
# or WSL). Safe to re-run. Asks for sudo once for apt.
#   .NET SDK (per user, version from global.json)   Doxygen + Graphviz   lcov (genhtml) + Perl + zip
#   astyle (code formatter)   ReportGenerator + DocFX (local dotnet tools)   MkDocs Material + coverxygen (pip)
set -e
cd "$(dirname "$0")"
. scripts/dotnet-env-linux.sh

echo "============================================================"
echo " $PROJECT_NAME :: 4-install-tools (linux)"
echo "============================================================"

if ! command -v apt-get >/dev/null 2>&1; then
    echo "[ERROR] apt-get not found. These scripts target Debian/Ubuntu (native or WSL). On another distro," >&2
    echo "        install doxygen graphviz lcov perl zip astyle python3-pip curl with its package manager." >&2
    exit 1
fi

echo; echo "[1/6] apt packages (Doxygen, Graphviz, lcov, Perl, zip, astyle, Python pip, curl)..."
sudo apt-get update -y
sudo apt-get install -y doxygen graphviz lcov perl zip astyle python3 python3-pip curl git

echo; echo "[2/6] .NET SDK pinned in global.json (per user, no sudo)..."
./scripts/install-dotnet-sdk-linux.sh
. scripts/dotnet-env-linux.sh

echo; echo "[3/6] Local dotnet tools (ReportGenerator + DocFX, versions pinned in .config/dotnet-tools.json)..."
dotnet tool restore

echo; echo "[4/6] Python tools (MkDocs Material + coverxygen, from requirements.txt)..."
./scripts/install-python-tools-linux.sh

echo; echo "[5/6] GitHub CLI (only needed for 10-release-linux.sh; optional)..."
if command -v gh >/dev/null 2>&1; then echo "gh is already installed."; else echo "Not installed. See docs/guide/releases-and-private-repos.en.md (sudo apt-get install gh, or the official instructions)."; fi

echo; echo "[6/6] Versions:"
dotnet --version; doxygen --version; genhtml --version | head -1
echo
echo "Done. Next: ./6-build-and-test-linux.sh (fast) or ./7-build-all-linux.sh (everything)."
