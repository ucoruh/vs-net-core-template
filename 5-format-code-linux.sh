#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Formatting code with astyle (options in astyle-options.txt)..."
if ! command -v astyle >/dev/null 2>&1; then
    echo "[ERROR] astyle was not found on PATH. Run ./4-install-tools-linux.sh first." >&2
    exit 1
fi
astyle --options="astyle-options.txt" --exclude=obj --exclude=bin --ignore-exclude-errors --recursive "CalculatorApp/*.cs" "CalculatorLibrary/*.cs" "CalculatorLibrary.Tests/*.cs"
echo "Done."
