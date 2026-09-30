#!/bin/bash
# Runs the sample app. With no arguments it prints a short built-in demo; with three arguments
# (operation a b) it computes that one operation, e.g.  ./8-run-app-linux.sh add 2 3
# It never reads from stdin, so it is safe to call from another script or from CI.
set -e
cd "$(dirname "$0")"
. scripts/dotnet-env-linux.sh

dotnet run --project "$APP_PROJECT" --configuration Release --artifacts-path build/linux-release -- "$@"
