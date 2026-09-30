#!/bin/bash
# 9-open-site-linux.sh [port]
#   port   TCP port to serve on (default 8080). Pass another one if 8080 is already in use.
#
# Serves the built site (site/) over a small local HTTP server and opens the browser. Do not open
# site/index.html directly: many browsers block an <iframe> (every standalone report page under
# reports/<platform>/ frames its report) from loading another file when the parent page was opened via
# a bare file:// path. Runs in the foreground: press Ctrl+C to stop it -- that is the only way this
# server ever ends (never kill it by name). This is also how you show the whole project WITHOUT
# GitHub Pages (docs/guide/showing-without-pages.en.md).
set -e
cd "$(dirname "$0")"
. scripts/load-project-env-linux.sh
. scripts/detect-python-linux.sh

if [ ! -f "site/index.html" ]; then
    echo "[ERROR] site/index.html not found. Run ./7-build-all-linux.sh first." >&2
    exit 1
fi
PORT="${1:-8080}"
[ -n "$PYTHON_ANY" ] || { echo "[ERROR] No Python interpreter found. See docs/guide/install.en.md." >&2; exit 1; }

echo "============================================================"
echo " $PROJECT_NAME :: 9-open-site (linux)"
echo " Serving site/ at http://localhost:$PORT/"
echo " Press Ctrl+C to stop the server."
echo "============================================================"
echo

# Open the browser in the background so it does not block the server below (WSL: wslview if present).
(
    sleep 1
    if command -v wslview >/dev/null 2>&1; then wslview "http://localhost:$PORT/"
    elif command -v xdg-open >/dev/null 2>&1; then xdg-open "http://localhost:$PORT/" >/dev/null 2>&1
    elif command -v open >/dev/null 2>&1; then open "http://localhost:$PORT/"
    fi
) &

"$PYTHON_ANY" -m http.server "$PORT" --directory site || {
    echo "[ERROR] The local HTTP server exited with an error -- port $PORT may already be in use." >&2
    echo "        Try a different port: ./9-open-site-linux.sh 8081 (see docs/guide/troubleshooting.en.md)." >&2
    exit 1
}
