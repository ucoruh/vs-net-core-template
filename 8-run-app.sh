#!/bin/bash
# Runs the sample app. With no arguments it prints a short built-in demo; with three arguments
# (operation a b) it computes that one operation. It never reads from stdin, so it is safe to call
# from another script or from CI without blocking.
set -e
cd "$(dirname "$0")"
. ./dotnet-env.sh

dotnet run --project CalculatorApp/CalculatorApp.csproj --configuration Release -- "$@"
