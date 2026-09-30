#!/bin/bash
# Sourced. Sets GENHTML_FOUND (0/1). genhtml comes with the "lcov" apt package.
if command -v genhtml >/dev/null 2>&1; then
    GENHTML_FOUND=1
else
    GENHTML_FOUND=0
    echo "[WARN] genhtml not found. Run ./4-install-tools-linux.sh (installs lcov). Continuing without the native lcov HTML reports." >&2
fi
