#!/bin/bash
set -e
echo "Installing lcov (provides genhtml, used for the native code-coverage and documentation-coverage HTML reports)..."
if command -v genhtml >/dev/null 2>&1; then
    echo "genhtml is already installed and on PATH."
else
    sudo apt-get install -y lcov perl
fi
echo "Done."
