#!/bin/bash
set -e
cd "$(dirname "$0")"
. ./dotnet-env.sh

echo "Installing Doxygen (API docs, all three templates) and Graphviz (optional Doxygen diagrams)..."
if command -v doxygen >/dev/null 2>&1; then
    echo "Doxygen is already installed."
else
    sudo apt-get install -y doxygen
fi

if command -v dot >/dev/null 2>&1; then
    echo "Graphviz is already installed."
else
    sudo apt-get install -y graphviz
fi

echo
echo "Restoring the local .NET tool manifest (ReportGenerator + DocFX; versions pinned in"
echo ".config/dotnet-tools.json, so every machine builds with the same tool versions)..."
dotnet tool restore

echo
echo "Done. reportgenerator and docfx are now available as local tools: 'dotnet reportgenerator ...'"
echo "and 'dotnet docfx ...' (only from this repository folder)."
