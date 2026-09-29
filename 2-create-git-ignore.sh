#!/bin/bash
# Regenerates the toptal.com part of .gitignore. Safe to re-run: everything from the
# "## BEGIN project-specific ##" marker to the end of the file is this project's own additions
# (generated-output folders) and is preserved instead of being overwritten by the downloaded
# template. See 2-create-git-ignore.bat for the Windows equivalent (same behavior).
set -e
cd "$(dirname "$0")"

API_URL="https://www.toptal.com/developers/gitignore/api/c,csharp,vs,visualstudio,visualstudiocode,java,maven,c++,cmake,eclipse,netbeans"
OUTPUT_FILE=".gitignore"
MARKER="## BEGIN project-specific (kept across regeneration by 2-create-git-ignore.{bat,sh}) ##"
TMP_BASE="$(mktemp)"
TMP_CUSTOM="$(mktemp)"
trap 'rm -f "$TMP_BASE" "$TMP_CUSTOM"' EXIT

HAVE_CUSTOM=0
if [ -f "$OUTPUT_FILE" ] && grep -qF "$MARKER" "$OUTPUT_FILE"; then
    echo "Preserving the existing project-specific section of $OUTPUT_FILE ..."
    awk -v marker="$MARKER" 'found || $0==marker {found=1; print}' "$OUTPUT_FILE" > "$TMP_CUSTOM"
    HAVE_CUSTOM=1
fi

echo "Downloading .gitignore base from $API_URL ..."
curl -fsS -o "$TMP_BASE" "$API_URL"

cp "$TMP_BASE" "$OUTPUT_FILE"
if [ "$HAVE_CUSTOM" -eq 1 ]; then
    cat "$TMP_CUSTOM" >> "$OUTPUT_FILE"
else
    echo "No existing project-specific section found (first run); re-run this script after"
    echo "7-build-app.sh has generated its output folders once, or restore the section from"
    echo "version control if you overwrote it by mistake."
fi

echo "Wrote $OUTPUT_FILE."
