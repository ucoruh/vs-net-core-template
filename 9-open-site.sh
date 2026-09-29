#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ ! -f "site/index.html" ]; then
    echo "[ERROR] site/index.html not found. Run ./7-build-app.sh first." >&2
    exit 1
fi

echo "Opening site/index.html..."
if command -v wslview >/dev/null 2>&1; then
    # WSL: hands the path to the Windows default browser via wslu's wslview.
    wslview "site/index.html"
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "site/index.html" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
    open "site/index.html"
else
    echo "No browser opener found (tried wslview, xdg-open, open)."
    echo "Open this file manually: $(pwd)/site/index.html"
fi
