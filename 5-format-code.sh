#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Formatting Code with Astyle..."
if ! command -v astyle >/dev/null 2>&1; then
    echo "[ERROR] astyle was not found on PATH. Run 4-install-astyle.sh first." >&2
    exit 1
fi

astyle --options="astyle-options.txt" --exclude=obj --exclude=bin --recursive "CalculatorApp/*.cs" "CalculatorLibrary/*.cs" "CalculatorLibrary.Tests/*.cs"

echo "Done."
