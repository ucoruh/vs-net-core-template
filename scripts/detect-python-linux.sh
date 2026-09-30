#!/bin/bash
# Sourced. Sets PYTHON_CMD to the first interpreter that has BOTH coverxygen and mkdocs, and
# PYTHON_ANY to the first one that runs at all (enough for `-m http.server`).
PYTHON_CMD=""
PYTHON_ANY=""
for c in python3 python; do
    command -v "$c" >/dev/null 2>&1 || continue
    [ -z "$PYTHON_ANY" ] && "$c" -c "import sys" >/dev/null 2>&1 && PYTHON_ANY="$c"
    if [ -z "$PYTHON_CMD" ] && "$c" -c "import coverxygen, mkdocs" >/dev/null 2>&1; then PYTHON_CMD="$c"; fi
done
