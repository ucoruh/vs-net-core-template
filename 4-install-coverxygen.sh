#!/bin/bash
# Installs coverxygen (turns Doxygen's XML output into an lcov file for documentation-coverage
# reports). See 4-install-coverxygen.bat for the Windows notes on the "wrong python on PATH" trap
# (less common on WSL, but the same --user, explicit-interpreter approach is used here too).
set -e

PY_CMD=""
if command -v python3 >/dev/null 2>&1; then
    PY_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PY_CMD="python"
else
    echo "[ERROR] No Python 3 interpreter found. Install one (sudo apt-get install -y python3 python3-pip) and re-run this script." >&2
    exit 1
fi

echo "Using: $PY_CMD"
"$PY_CMD" -m pip install --user coverxygen

echo
echo "Verifying the install..."
"$PY_CMD" -m coverxygen --help >/dev/null

echo "Done. 7-build-app.sh will pick this Python up automatically."
