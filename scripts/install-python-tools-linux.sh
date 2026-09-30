#!/bin/bash
# Installs the Python tools from requirements.txt (MkDocs Material = the main site, coverxygen =
# documentation coverage) with `pip install --user`. Called by 4-install-tools-linux.sh.
set -e
cd "$(dirname "$0")/.."

PY_CMD=""
if command -v python3 >/dev/null 2>&1; then PY_CMD="python3"
elif command -v python >/dev/null 2>&1; then PY_CMD="python"
else
    echo "[ERROR] No Python 3 found. Install it: sudo apt-get install -y python3 python3-pip" >&2
    exit 1
fi
echo "Using: $PY_CMD"
"$PY_CMD" -m pip install --user -r requirements.txt

echo
echo "Verifying the install..."
"$PY_CMD" -c "import coverxygen, mkdocs, material; print('coverxygen, mkdocs and mkdocs-material import fine')"
