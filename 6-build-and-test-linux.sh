#!/bin/bash
# 6-build-and-test-linux.sh -- the FAST loop: restore, build (Debug) and run the unit tests. No
# coverage, no reports, no docs -- use ./7-build-all-linux.sh for those. Works on native Linux and WSL
# (both are the "linux" platform). Output goes to build/linux-debug/.
set -e
cd "$(dirname "$0")"
. scripts/dotnet-env-linux.sh

echo "============================================================"
echo " $PROJECT_NAME $VERSION :: 6-build-and-test (linux, Debug)"
echo "============================================================"

dotnet build "$SOLUTION_FILE" --configuration Debug --artifacts-path build/linux-debug --nologo
echo
dotnet test "$TEST_PROJECT" --no-build --configuration Debug --artifacts-path build/linux-debug --nologo --verbosity minimal
echo
echo "Done: build and unit tests passed. Next: ./7-build-all-linux.sh (reports, API docs, site, release/)."
