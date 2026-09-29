#!/bin/bash
# 9-open-site.sh [port]
#   port   TCP port to serve on (default 8080). Pass a different one if 8080 is already in use
#          (see docs/guide/troubleshooting.en.md).
#
# Serves the built site over a small local HTTP server -- see 9-open-site.bat's comment for why
# (in short: report pages' <iframe>s, docs/guide/embed-html-in-site.en.md, are blocked by many browsers
# from a bare file:// page). Runs in the foreground; press Ctrl+C to stop it -- that is also the
# only way this script's server process ever ends (never kill it by name).
set -e
cd "$(dirname "$0")"

if [ ! -f "site/index.html" ]; then
    echo "[ERROR] site/index.html not found. Run ./7-build-app.sh first." >&2
    exit 1
fi

PORT="${1:-8080}"

SITE_PYTHON=""
if command -v python3 >/dev/null 2>&1; then
    SITE_PYTHON="python3"
elif command -v python >/dev/null 2>&1; then
    SITE_PYTHON="python"
else
    echo "[ERROR] No Python interpreter found (tried python3, python). Install one -- see" >&2
    echo "        docs/guide/install.en.md -- or open site/index.html directly (report pages'" >&2
    echo "        iframes will not load from a plain file:// path)." >&2
    exit 1
fi

echo "============================================================"
echo " vs-net-core-template :: 9-open-site"
echo " Serving site/ at http://localhost:$PORT/"
echo " Press Ctrl+C to stop the server."
echo "============================================================"
echo

# Open the browser in the background so it does not block the server below.
(
    sleep 1
    if command -v wslview >/dev/null 2>&1; then
        wslview "http://localhost:$PORT/"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "http://localhost:$PORT/" >/dev/null 2>&1
    elif command -v open >/dev/null 2>&1; then
        open "http://localhost:$PORT/"
    fi
) &

"$SITE_PYTHON" -m http.server "$PORT" --directory site || {
    echo "[ERROR] The local HTTP server exited with an error -- port $PORT may already be in use." >&2
    echo "        Try a different port: ./9-open-site.sh 8081 (see docs/guide/troubleshooting.en.md)." >&2
    exit 1
}
