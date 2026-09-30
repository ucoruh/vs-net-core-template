#!/bin/bash
# 11-clean-linux.sh -- deletes every generated folder (all of them are gitignored):
# build/ publish/ reports/ site/ site-native/ release/ plus docfx/api, TestResults, bin/ and obj/.
# Nothing tracked by git is touched. Add "all" to also drop ReportGenerator's history (report_history/).
cd "$(dirname "$0")"
echo "Cleaning generated output..."
for d in build publish reports site site-native release docfx/api TestResults; do
    [ -e "$d" ] && { echo "  removing $d"; rm -rf "$d"; }
done
find . -type d \( -name bin -o -name obj \) -not -path "./.git/*" -prune -exec rm -rf {} + 2>/dev/null || true
if [ "$1" = "all" ] && [ -d report_history ]; then echo "  removing report_history"; rm -rf report_history; fi
echo "Done."
