#!/bin/bash
# 7-build-all-linux.sh [--no-site]
#   Builds EVERYTHING on Linux (native Linux and WSL are the same platform, "linux"): Release build,
#   unit tests + coverage, every report of both families, Doxygen and DocFX API docs, the app
#   (dotnet publish), the release/ folder and -- unless --no-site is given (CI does that in the
#   per-platform jobs) -- the MkDocs site.
#
#   Output (all gitignored, same layout on every template):
#     build/linux-release/              compiler output
#     publish/linux-x64/                the app
#     reports/linux/<kind>-<tool>/      tests-trx, coverage-reportgenerator, coverage-lcov,
#                                       doccoverage-reportgenerator, doccoverage-lcov, api-doxygen, api-docfx
#     site/  site-native/  release/     the site, the DocFX site, every release asset
#   Windows has its own twin: 7-build-all-windows.bat (reports there can differ, so they are kept apart).
set -e
cd "$(dirname "$0")"
. scripts/dotnet-env-linux.sh
. scripts/detect-python-linux.sh

NO_SITE=0
[ "$1" = "--no-site" ] && NO_SITE=1
currentDir="$(pwd)"
R="reports/$PLATFORM_TOKEN"

echo "============================================================"
echo " $PROJECT_NAME $VERSION :: 7-build-all ($PLATFORM_TOKEN/$ARCH)"
echo " Repo root: $currentDir"
echo "============================================================"
echo

if [ -z "$PYTHON_CMD" ]; then
    echo "[ERROR] No Python with BOTH coverxygen and mkdocs was found. Run ./4-install-tools-linux.sh" >&2
    echo "        (or: python3 -m pip install --user -r requirements.txt). See docs/guide/troubleshooting.en.md." >&2
    exit 1
fi
echo "Python: $PYTHON_CMD"
command -v doxygen >/dev/null 2>&1 || { echo "[ERROR] doxygen not found. Run ./4-install-tools-linux.sh first." >&2; exit 1; }
. scripts/detect-genhtml-linux.sh
echo

echo "[0/9] Cleaning this platform's previous output..."
rm -rf "$R" build/doxygen site site-native
mkdir -p "$R/_raw"
echo "Done."; echo

echo "[1/9] Restoring the local dotnet tools (ReportGenerator, DocFX) and building the solution (Release)..."
dotnet tool restore
dotnet build "$SOLUTION_FILE" --configuration Release --artifacts-path build/linux-release --nologo
echo

echo "[2/9] Unit tests with coverage (TRX + native HTML; cobertura + lcov)..."
dotnet test "$TEST_PROJECT" \
    --no-build --configuration Release --artifacts-path build/linux-release --verbosity normal \
    --collect:"XPlat Code Coverage" --settings CalculatorLibrary.Tests/coverlet.runsettings \
    --results-directory "$R/_raw/testresults" \
    --logger "trx;LogFileName=test-results.trx" \
    --logger "html;LogFileName=test-results.html"
mkdir -p "$R/tests-trx"
cp "$R"/_raw/testresults/test-results.* "$R/tests-trx/"
echo

echo "[3/9] Doxygen API docs..."
doxygen Doxyfile
cp -r build/doxygen/html "$R/api-doxygen"
echo

echo "[4/9] Documentation coverage (coverxygen -> lcov -> genhtml AND ReportGenerator)..."
mkdir -p "$R/_raw/doccoverage"
# Doxygen records forward-slash paths natively on Linux, so no backslash conversion for --prefix.
"$PYTHON_CMD" -m coverxygen --xml-dir build/doxygen/xml --src-dir . --format lcov --output "$R/_raw/doccoverage/lcov.info" --prefix "$currentDir/"
if [ "$GENHTML_FOUND" = "1" ]; then
    genhtml --legend --title "Documentation Coverage Report" "$R/_raw/doccoverage/lcov.info" -o "$R/doccoverage-lcov"
fi
dotnet reportgenerator "-reports:$R/_raw/doccoverage/lcov.info" "-targetdir:$R/doccoverage-reportgenerator" "-reporttypes:Html;Badges"
cp "$R/doccoverage-reportgenerator/badge_linecoverage.svg" docs/assets/badge_doccoverage.svg
echo

echo "[5/9] Code coverage (ReportGenerator from cobertura AND genhtml from lcov)..."
dotnet reportgenerator "-reports:$R/_raw/testresults/**/coverage.cobertura.xml" "-targetdir:$R/coverage-reportgenerator" "-reporttypes:Html;Badges" "-historydir:report_history/$PLATFORM_TOKEN"
for b in combined branchcoverage linecoverage methodcoverage; do
    cp "$R/coverage-reportgenerator/badge_$b.svg" "docs/assets/badge_$b.svg"
done
if [ "$GENHTML_FOUND" = "1" ]; then
    lcovFile="$(find "$R/_raw/testresults" -name coverage.info -print -quit)"
    if [ -n "$lcovFile" ]; then
        genhtml --legend --title "Code Coverage Report - lcov via coverlet" "$lcovFile" -o "$R/coverage-lcov"
    else
        echo "  [WARN] No coverage.info (lcov) found; skipping the genhtml code-coverage report."
    fi
fi
echo

echo "[6/9] DocFX API reference (a complete site of its own, kept under native/ -- never framed)..."
dotnet docfx metadata docfx/docfx.json
dotnet docfx build docfx/docfx.json -o "$R/api-docfx"
echo

echo "[7/9] Publishing the app (self-contained linux-$ARCH)..."
rm -rf "publish/linux-$ARCH"
dotnet publish "$APP_PROJECT" --configuration Release -r "linux-$ARCH" --self-contained true --artifacts-path build/linux-release -o "publish/linux-$ARCH" --nologo
echo

echo "[8/9] Packing this platform's release assets into release/ ..."
"$PYTHON_CMD" scripts/site_tools.py pack-platform --platform linux --arch "$ARCH"
echo

if [ "$NO_SITE" = "1" ]; then
    echo "[9/9] Skipping the site (--no-site)."
else
    echo "[9/9] Building the MkDocs site, assembling reports, checking links..."
    ./scripts/build-site-linux.sh
fi
echo
echo "============================================================"
echo " Done."
echo "  Site (main):            site/index.html          (open it with ./9-open-site-linux.sh)"
echo "  DocFX site (native):    site-native/linux/index.html"
echo "  Reports:                $R/   tests-trx  coverage-*  doccoverage-*  api-*"
echo "  The app:                publish/linux-$ARCH/"
echo "  Every release asset:    release/   (ASSETS.md lists them)"
echo "  What each report is:    docs/guide/reports-explained.en.md"
echo "============================================================"
