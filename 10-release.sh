#!/bin/bash
# 10-release.sh [version] [--dry-run]
#   version    e.g. "v1.2.0" or "1.2.0" (the "v" prefix is added if missing). If omitted, read
#              from the VERSION file.
#   --dry-run  builds and packages everything, prints the exact "gh release create" command and
#              the asset list, but does NOT publish anything. Use this to test the script.
#
# Builds everything locally (calls 7-build-app.sh), packages binaries + every report (both
# families) + the whole site as release/site.zip into release/, then publishes with the GitHub
# CLI. No GitHub Actions minutes are used; this works on GitHub Free with a private repository.
# See docs/guide/releases-and-private-repos.en.md.
set -e
cd "$(dirname "$0")"
. ./dotnet-env.sh

DRY_RUN=0
VERSION_ARG=""
for arg in "$@"; do
    if [ "$arg" = "--dry-run" ]; then
        DRY_RUN=1
    else
        VERSION_ARG="$arg"
    fi
done

if [ -n "$VERSION_ARG" ]; then
    RELEASE_VERSION="$VERSION_ARG"
elif [ -f VERSION ]; then
    RELEASE_VERSION="$(cat VERSION)"
else
    echo "[ERROR] No version given and no VERSION file found." >&2
    echo "        Usage: ./10-release.sh [version] [--dry-run], e.g. ./10-release.sh v1.0.0" >&2
    exit 1
fi
case "$RELEASE_VERSION" in
    v*) RELEASE_TAG="$RELEASE_VERSION" ;;
    *) RELEASE_TAG="v$RELEASE_VERSION" ;;
esac

echo "============================================================"
echo " 10-release :: $RELEASE_TAG"
[ "$DRY_RUN" = "1" ] && echo " Mode: DRY RUN -- nothing will be published"
echo "============================================================"
echo

# --- gh present? logged in? (hard requirement for a REAL release; --dry-run only warns) ---
if ! command -v gh >/dev/null 2>&1; then
    echo "[ERROR] GitHub CLI (gh) not found. Install it (see docs/guide/install.en.md), then run" >&2
    echo "        \"gh auth login\". See docs/guide/releases-and-private-repos.en.md." >&2
    [ "$DRY_RUN" = "0" ] && exit 1
fi

GH_LOGGED_IN=0
gh auth status >/dev/null 2>&1 && GH_LOGGED_IN=1
if [ "$GH_LOGGED_IN" = "0" ]; then
    echo "[WARN] gh is not logged in (run \"gh auth login\"). Fine for --dry-run; a real release needs it."
fi
if [ "$DRY_RUN" = "0" ] && [ "$GH_LOGGED_IN" = "0" ]; then
    echo "[ERROR] gh is not logged in. Run \"gh auth login\", then re-run this script." >&2
    exit 1
fi

# --- refuse a dirty working tree for a REAL release; --dry-run only warns ---
GIT_DIRTY=""
[ -n "$(git status --porcelain 2>/dev/null)" ] && GIT_DIRTY=1
if [ "$DRY_RUN" = "0" ] && [ -n "$GIT_DIRTY" ]; then
    echo "[ERROR] Working tree has uncommitted changes. Commit or stash them before a real release." >&2
    echo "        (--dry-run skips this check.)" >&2
    exit 1
fi
if [ "$DRY_RUN" = "1" ] && [ -n "$GIT_DIRTY" ]; then
    echo "[WARN] Working tree has uncommitted changes -- fine for --dry-run, a real release will refuse this."
fi
echo

# --- 1. Build everything ---
echo "[1/4] Building the project, tests, reports and site (7-build-app)..."
./7-build-app.sh
echo

# --- 2. Publish self-contained binaries for the three main RIDs (the APP project, not the
#        solution -- see 7-build-app.sh / docs/guide/troubleshooting.en.md, NETSDK1194) ---
echo "[2/4] Publishing binaries..."
rm -rf publish
mkdir -p publish
dotnet publish CalculatorApp/CalculatorApp.csproj -c Release -r linux-x64 --self-contained true -o publish/linux
dotnet publish CalculatorApp/CalculatorApp.csproj -c Release -r osx-x64 --self-contained true -o publish/macos
dotnet publish CalculatorApp/CalculatorApp.csproj -c Release -r win-x64 --self-contained true -o publish/windows
echo

# --- 3. Package everything into release/ ---
echo "[3/4] Packaging release assets..."
mkdir -p release
rm -f release/*

tar -czf release/linux-binaries.tar.gz -C publish/linux .
tar -czf release/macos-binaries.tar.gz -C publish/macos .
tar -czf release/windows-binaries.tar.gz -C publish/windows .

tar -czf release/unit-test-results.tar.gz -C docs/testresults .
tar -czf release/code-coverage-reportgenerator.tar.gz -C docs/coveragereport .
[ -d docs/coverage-genhtml ] && tar -czf release/code-coverage-genhtml.tar.gz -C docs/coverage-genhtml .
[ -d docs/coverxygen ] && tar -czf release/doc-coverage-genhtml.tar.gz -C docs/coverxygen .
[ -d docs/doccoverage-reportgenerator ] && tar -czf release/doc-coverage-reportgenerator.tar.gz -C docs/doccoverage-reportgenerator .
tar -czf release/doxygen-api-docs.tar.gz -C docs/doxygen/html .

if ! command -v zip >/dev/null 2>&1; then
    echo "Installing zip (needed to package the site as a real .zip, not .tar.gz)..."
    sudo apt-get install -y zip
fi
echo "Zipping the whole site (release/site.zip -- unzip, open index.html)..."
( cd site && zip -qr ../release/site.zip . )

echo "Packaging a source archive (release/source.zip)..."
git archive --format=zip --output=release/source.zip HEAD

# Best-effort "https://<owner>.github.io/<repo>/" derived from the "origin" remote, for the release
# notes and release/README.md below. Falls back to a generic instruction if "origin" is missing or
# not a recognized github.com URL -- a normal, expected outcome (e.g. no Pages configured yet).
originUrl="$(git config --get remote.origin.url 2>/dev/null || true)"
siteBaseUrl=""
if [ -n "$originUrl" ]; then
    repoPath="$(echo "$originUrl" | sed -E 's#^(https://github\.com/|git@github\.com:)##; s#\.git$##')"
    if [ "$repoPath" != "$originUrl" ]; then
        owner="${repoPath%%/*}"
        repo="${repoPath#*/}"
        siteBaseUrl="https://${owner}.github.io/${repo}/"
    fi
fi
[ -z "$siteBaseUrl" ] && siteBaseUrl="your repository's Pages URL -- Settings -> Pages / "

echo "Writing release notes..."
{
    echo "# $RELEASE_TAG"
    echo
    echo "Built and packaged locally by 10-release.sh. See docs/guide/reports-explained.en.md"
    echo "for what each packaged report is, and docs/guide/releases-and-private-repos.en.md for"
    echo "how to read this on GitHub Free with a private repository. If GitHub Pages is not"
    echo "enabled for this repository, open release/site.zip locally instead of the links below."
    echo
    echo "## Live site"
    echo
    echo "- Home: ${siteBaseUrl}"
    echo "- Unit test results: ${siteBaseUrl}docs/report-pages/unit-tests.html"
    echo "- Code coverage (ReportGenerator): ${siteBaseUrl}docs/report-pages/coverage-reportgenerator.html"
    echo "- Code coverage (genhtml): ${siteBaseUrl}docs/report-pages/coverage-genhtml.html"
    echo "- Documentation coverage (genhtml): ${siteBaseUrl}docs/report-pages/doccoverage-genhtml.html"
    echo "- Documentation coverage (ReportGenerator): ${siteBaseUrl}docs/report-pages/doccoverage-reportgenerator.html"
    echo "- Doxygen API docs: ${siteBaseUrl}docs/report-pages/doxygen-api.html"
    echo "- DocFX API reference: ${siteBaseUrl}docs/api/index.html"
    echo
    echo "See release/README.md (also attached below) for what every packaged archive contains."
    echo
    echo "## Commits"
    echo
    prevTag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
    if [ -n "$prevTag" ]; then
        git log "$prevTag"..HEAD --oneline
    else
        git log -n 20 --oneline
    fi
} > release/notes.md

echo "Writing release/README.md (lists every packaged archive)..."
{
    echo "# Release assets -- $RELEASE_TAG"
    echo
    echo "Everything in this folder is also attached to the GitHub Release. Unzip \`site.zip\`"
    echo "and open \`index.html\` for the full site, or open any archive below directly. Live"
    echo "site: ${siteBaseUrl}"
    echo
    echo "| Archive | Contents |"
    echo "|---|---|"
    echo "| \`windows-binaries.tar.gz\` | Self-contained \`win-x64\` publish of the sample app |"
    echo "| \`linux-binaries.tar.gz\` | Self-contained \`linux-x64\` publish of the sample app |"
    echo "| \`macos-binaries.tar.gz\` | Self-contained \`osx-x64\` publish of the sample app |"
    echo "| \`source.zip\` | Source archive at this commit (\`git archive\`) |"
    echo "| \`site.zip\` | The whole built site -- unzip, open \`index.html\` |"
    echo "| \`unit-test-results.tar.gz\` | Native VSTest HTML + TRX unit-test results |"
    echo "| \`code-coverage-reportgenerator.tar.gz\` | Code coverage, ReportGenerator HTML |"
    echo "| \`code-coverage-genhtml.tar.gz\` | Code coverage, native genhtml (lcov) |"
    echo "| \`doc-coverage-genhtml.tar.gz\` | Documentation coverage, native genhtml (lcov) |"
    echo "| \`doc-coverage-reportgenerator.tar.gz\` | Documentation coverage, ReportGenerator HTML |"
    echo "| \`doxygen-api-docs.tar.gz\` | Doxygen API reference (ecosystem-neutral; the DocFX-native API reference ships inside \`site.zip\`) |"
    echo "| \`notes.md\` | This release's GitHub Release description |"
    echo
    echo 'See docs/guide/reports-explained.en.md ("Which report is which?") for what each report shows.'
} > release/README.md
echo

# --- 4. Publish (or, in --dry-run, just show what would happen) ---
echo "[4/4] Assets:"
for f in release/*; do echo "  $f"; done
echo

if [ "$DRY_RUN" = "1" ]; then
    echo "[DRY RUN] Would run:"
    echo "  gh release create $RELEASE_TAG release/* --title \"$RELEASE_TAG\" --notes-file release/notes.md"
    echo "No release was created (--dry-run). Remove --dry-run to publish for real."
    exit 0
fi

echo "Publishing GitHub release $RELEASE_TAG ..."
gh release create "$RELEASE_TAG" release/* --title "$RELEASE_TAG" --notes-file release/notes.md
echo "Done. Add your instructor as a collaborator so they can see this private release (see"
echo "docs/guide/releases-and-private-repos.en.md)."
