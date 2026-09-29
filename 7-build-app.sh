#!/bin/bash
# Linux/WSL equivalent of 7-build-app.bat -- see that file's comments for the "why" behind each
# step; this script keeps the same 8 steps and the same output layout so docs/guide content and
# 9-open-site/10-release work unchanged on either OS.
set -e
cd "$(dirname "$0")"
. ./dotnet-env.sh

currentDir="$(pwd)"

echo "============================================================"
echo " vs-net-core-template :: 7-build-app"
echo " Repo root: $currentDir"
echo "============================================================"
echo

find_genhtml() {
    if command -v genhtml >/dev/null 2>&1; then
        GENHTML_FOUND=1
    else
        GENHTML_FOUND=0
        echo "[WARN] genhtml not found. Run 4-install-lcov.sh, then re-run this script to also get" >&2
        echo "       the native lcov HTML reports. Continuing without them for now." >&2
    fi
}

find_python() {
    COVERXYGEN_PYTHON=""
    if command -v python3 >/dev/null 2>&1 && python3 -c "import coverxygen" >/dev/null 2>&1; then
        COVERXYGEN_PYTHON="python3"
    elif command -v python >/dev/null 2>&1 && python -c "import coverxygen" >/dev/null 2>&1; then
        COVERXYGEN_PYTHON="python"
    fi
}

# --- 0. Clean and recreate the folders this script (re-)generates. Idempotent: `rm -rf` on a
#        missing folder is a silent no-op in bash, unlike a bare `rd` on Windows, so no extra
#        guard is needed here. ---
echo "[0/9] Cleaning previous output..."
rm -rf docs/doxygen docs/coverxygen docs/doccoverage-reportgenerator docs/coveragereport docs/coverage-genhtml docs/testresults assets/doccoverage site
mkdir -p docs/doxygen docs/coverxygen docs/doccoverage-reportgenerator docs/coveragereport docs/coverage-genhtml docs/testresults assets/doccoverage site
echo "Done."
echo

# --- 1. Restore + build (Release) ---
echo "[1/9] Restoring and building the solution (Release, \$DOTNET_ROOT=$DOTNET_ROOT)..."
dotnet restore CalculatorLibrary.sln
dotnet build CalculatorLibrary.sln --configuration Release
echo

# --- 2. Tests with coverage: TRX + native HTML logger, cobertura + lcov coverage in one run ---
echo "[2/9] Running tests with coverage..."
dotnet test CalculatorLibrary.Tests/CalculatorLibrary.Tests.csproj \
    --no-build --configuration Release --verbosity normal \
    --collect:"XPlat Code Coverage" --settings CalculatorLibrary.Tests/coverlet.runsettings \
    --results-directory docs/testresults \
    --logger "trx;LogFileName=test-results.trx" \
    --logger "html;LogFileName=test-results.html"
echo

# --- 3. Doxygen: ecosystem-neutral API docs ---
echo "[3/9] Generating Doxygen documentation..."
if ! command -v doxygen >/dev/null 2>&1; then
    echo "[ERROR] doxygen not found. Run 6-install-docfx-and-report-tools.sh first." >&2
    exit 1
fi
doxygen Doxyfile
echo

# --- 4. Documentation coverage: coverxygen -> lcov -> genhtml AND ReportGenerator ---
echo "[4/9] Documentation coverage (coverxygen)..."
find_python
if [ -z "$COVERXYGEN_PYTHON" ]; then
    echo "[ERROR] No Python interpreter with the \"coverxygen\" module was found." >&2
    echo "        Fix: run 4-install-coverxygen.sh (or \"python3 -m pip install --user coverxygen\")," >&2
    echo "        then re-run this script. See docs/guide/troubleshooting.en.md." >&2
    echo "        Skipping the documentation-coverage report for now." >&2
else
    echo "  Using: $COVERXYGEN_PYTHON"
    # Unlike on Windows, Doxygen already records forward-slash paths natively on Linux, so no
    # backslash-to-forward-slash conversion is needed for --prefix here (see 7-build-app.bat).
    "$COVERXYGEN_PYTHON" -m coverxygen --xml-dir docs/doxygen/xml --src-dir . --format lcov --output docs/coverxygen/lcov.info --prefix "$currentDir/"

    find_genhtml
    if [ "$GENHTML_FOUND" = "1" ]; then
        genhtml --legend --title "Documentation Coverage Report" docs/coverxygen/lcov.info -o docs/coverxygen
    else
        echo "  Skipping genhtml documentation-coverage report (genhtml not available)."
    fi

    dotnet reportgenerator "-reports:docs/coverxygen/lcov.info" "-targetdir:docs/doccoverage-reportgenerator" "-reporttypes:Html;Badges"

    # Doc-coverage badges into their own assets/doccoverage/ subfolder -- see 7-build-app.bat's
    # comment: ReportGenerator writes the same fixed filenames every time, so sharing plain
    # assets/ with the code-coverage badges (step 5 below) would silently overwrite them.
    dotnet reportgenerator "-reports:docs/coverxygen/lcov.info" "-targetdir:assets/doccoverage" -reporttypes:Badges
fi
echo

# --- 5. Code coverage: ReportGenerator (cobertura, + badges + history) AND genhtml (lcov) ---
echo "[5/9] Code coverage reports..."
dotnet reportgenerator "-reports:docs/testresults/**/coverage.cobertura.xml" "-targetdir:docs/coveragereport" "-reporttypes:Html;Badges" -historydir:report_history

# Badges-only pass into the tracked assets/ folder, same as 7-build-app.bat -- see its comment.
dotnet reportgenerator "-reports:docs/testresults/**/coverage.cobertura.xml" "-targetdir:assets" -reporttypes:Badges

find_genhtml
if [ "$GENHTML_FOUND" = "1" ]; then
    lcovCoverageFile="$(find docs/testresults -name coverage.info -print -quit)"
    if [ -n "$lcovCoverageFile" ]; then
        genhtml --legend --title "Code Coverage Report - lcov via coverlet" "$lcovCoverageFile" -o docs/coverage-genhtml
    else
        echo "  [WARN] No coverage.info (lcov) file found under docs/testresults; skipping genhtml code-coverage report."
    fi
else
    echo "  Skipping genhtml code-coverage report (genhtml not available)."
fi
echo

# --- 6. Copy assets and build the site's home page content ---
echo "[6/9] Copying assets and building the site's home page content..."
# docs/assets is for pages that already live under docs/ (e.g. docs/developers.md's image); the
# top-level assets/ resource mapping in docfx.json covers the root index.md below.
mkdir -p docs/assets
cp -r assets/. docs/assets/
# A root-level index.md, not docs/index.md: this is the site's actual home page (site/index.html)
# and what lets the shipped site.zip work as "unzip, open index.html" (see
# docs/guide/releases-and-private-repos.en.md). docs/home.md (not README.md -- README.md is the
# separate, plain GitHub-facing page) is the polished landing-page source; its relative links
# (docs/guide/..., assets/...) resolve correctly from the repository root, which is also where
# this copy lives.
cp docs/home.md index.md
echo

# --- 7. Zip each report's own folder for the site's "Download (zip)" buttons. Dropped INSIDE
#        each report's own output folder, so docfx.json's existing "<folder>/**" resource globs
#        pick them up automatically -- except testresults, whose glob is deliberately narrow
#        (*.html only), so it also lists *.zip explicitly. See 7-build-app.bat's comment. ---
echo "[7/9] Zipping reports for the site's \"Download (zip)\" buttons..."
if ! command -v zip >/dev/null 2>&1; then
    echo "  Installing zip (needed to package each report as a real .zip)..."
    sudo apt-get install -y zip
fi
( cd docs/testresults && zip -qr unit-test-results.zip . -x unit-test-results.zip )
( cd docs/coveragereport && zip -qr coverage-reportgenerator-report.zip . -x coverage-reportgenerator-report.zip )
[ -f docs/coverage-genhtml/index.html ] && ( cd docs/coverage-genhtml && zip -qr coverage-genhtml-report.zip . -x coverage-genhtml-report.zip )
[ -f docs/coverxygen/index.html ] && ( cd docs/coverxygen && zip -qr doccoverage-genhtml-report.zip . -x doccoverage-genhtml-report.zip )
[ -f docs/doccoverage-reportgenerator/index.html ] && ( cd docs/doccoverage-reportgenerator && zip -qr doccoverage-reportgenerator-report.zip . -x doccoverage-reportgenerator-report.zip )
( cd docs/doxygen/html && zip -qr doxygen-api-docs.zip . -x doxygen-api-docs.zip )
echo

# --- 8. DocFX site ---
echo "[8/9] Building the DocFX site..."
dotnet tool restore
dotnet docfx metadata docfx.json
dotnet docfx build docfx.json
echo

# --- 9. Summary ---
echo "[9/9] Done."
echo
echo "  Site:                              site/index.html            (open with ./9-open-site.sh)"
echo "  Unit test results (native):        docs/testresults/test-results.html"
echo "  Code coverage (ReportGenerator):   docs/coveragereport/index.html"
echo "  Code coverage (genhtml/lcov):      docs/coverage-genhtml/index.html"
echo "  Doc coverage (genhtml/lcov):       docs/coverxygen/index.html"
echo "  Doc coverage (ReportGenerator):    docs/doccoverage-reportgenerator/index.html"
echo "  Doxygen API docs:                  docs/doxygen/html/index.html"
echo
echo "  See docs/guide/reports-explained.en.md (\"Which report is which?\") for what each one shows."
echo "============================================================"
