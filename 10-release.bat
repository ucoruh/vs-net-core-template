@echo off
setlocal enableextensions enabledelayedexpansion
cd /d "%~dp0"

rem 10-release.bat [version] [--dry-run]
rem   version    e.g. "v1.2.0" or "1.2.0" (the "v" prefix is added if missing). If omitted, read
rem              from the VERSION file.
rem   --dry-run  builds and packages everything, prints the exact "gh release create" command and
rem              the asset list, but does NOT publish anything. Use this to test the script.
rem
rem Builds everything locally (calls 7-build-app), packages binaries + every report (both
rem families) + the whole site as release\site.zip into release\, then publishes with the GitHub
rem CLI. No GitHub Actions minutes are used; this works on GitHub Free with a private repository.
rem See docs\guide\releases-and-private-repos.en.md.

call "%~dp0dotnet-env.bat"

set "DRY_RUN=0"
set "VERSION_ARG="
:parse_args
if "%~1"=="" goto :after_parse_args
if /I "%~1"=="--dry-run" (
    set "DRY_RUN=1"
) else (
    set "VERSION_ARG=%~1"
)
shift
goto :parse_args
:after_parse_args

if defined VERSION_ARG (
    set "RELEASE_VERSION=%VERSION_ARG%"
) else (
    if not exist VERSION (
        echo [ERROR] No version given and no VERSION file found.
        echo         Usage: 10-release.bat [version] [--dry-run], e.g. 10-release.bat v1.0.0
        exit /b 1
    )
    set /p RELEASE_VERSION=<VERSION
)
set "RELEASE_TAG=%RELEASE_VERSION%"
if not "%RELEASE_TAG:~0,1%"=="v" set "RELEASE_TAG=v%RELEASE_TAG%"

echo ============================================================
echo  10-release :: %RELEASE_TAG%
if "%DRY_RUN%"=="1" echo  Mode: DRY RUN -- nothing will be published
echo ============================================================
echo.

rem --- gh present? logged in? (hard requirement for a REAL release; --dry-run only warns, so you
rem     can rehearse packaging before installing/logging in to gh) ---
where gh >nul 2>&1
if errorlevel 1 (
    echo [ERROR] GitHub CLI ^(gh^) not found. Install it, e.g. "winget install GitHub.cli", then
    echo         run "gh auth login". See docs\guide\releases-and-private-repos.en.md.
    if "%DRY_RUN%"=="0" exit /b 1
)

set "GH_LOGGED_IN=0"
gh auth status >nul 2>&1
if not errorlevel 1 set "GH_LOGGED_IN=1"
if "%GH_LOGGED_IN%"=="0" (
    echo [WARN] gh is not logged in ^(run "gh auth login"^). Fine for --dry-run; a real release needs it.
)
if "%DRY_RUN%"=="0" if "%GH_LOGGED_IN%"=="0" (
    echo [ERROR] gh is not logged in. Run "gh auth login", then re-run this script.
    exit /b 1
)

rem --- refuse a dirty working tree for a REAL release (a release should match one exact commit);
rem     --dry-run skips this so packaging can be rehearsed mid-work ---
set "GIT_DIRTY="
for /f "delims=" %%s in ('git status --porcelain 2^>nul') do set "GIT_DIRTY=1"
if "%DRY_RUN%"=="0" if defined GIT_DIRTY (
    echo [ERROR] Working tree has uncommitted changes. Commit or stash them before a real release.
    echo         ^(--dry-run skips this check.^)
    exit /b 1
)
if "%DRY_RUN%"=="1" if defined GIT_DIRTY (
    echo [WARN] Working tree has uncommitted changes -- fine for --dry-run, a real release will refuse this.
)
echo.

rem --- 1. Build everything (also refreshes docs\, site\) ---
echo [1/4] Building the project, tests, reports and site ^(7-build-app^)...
call "%~dp07-build-app.bat"
if errorlevel 1 (
    echo [ERROR] 7-build-app.bat failed; aborting release.
    exit /b 1
)
echo.

rem --- 2. Publish self-contained binaries for the three main RIDs (the APP project, not the
rem     solution: "dotnet publish" on a .sln with -o errors NETSDK1194, multiple projects would
rem     collide in one output folder) ---
echo [2/4] Publishing binaries...
if exist publish rd /S /Q publish
mkdir publish
call dotnet publish CalculatorApp\CalculatorApp.csproj -c Release -r linux-x64 --self-contained true -o publish\linux
if errorlevel 1 exit /b 1
call dotnet publish CalculatorApp\CalculatorApp.csproj -c Release -r osx-x64 --self-contained true -o publish\macos
if errorlevel 1 exit /b 1
call dotnet publish CalculatorApp\CalculatorApp.csproj -c Release -r win-x64 --self-contained true -o publish\windows
if errorlevel 1 exit /b 1
echo.

rem --- 3. Package everything into release\ ---
echo [3/4] Packaging release assets...
if not exist release mkdir release
del /Q release\*.* >nul 2>&1

tar -czf release\linux-binaries.tar.gz -C publish\linux .
if errorlevel 1 exit /b 1
tar -czf release\macos-binaries.tar.gz -C publish\macos .
if errorlevel 1 exit /b 1
tar -czf release\windows-binaries.tar.gz -C publish\windows .
if errorlevel 1 exit /b 1

tar -czf release\unit-test-results.tar.gz -C docs\testresults .
tar -czf release\code-coverage-reportgenerator.tar.gz -C docs\coveragereport .
if exist docs\coverage-genhtml tar -czf release\code-coverage-genhtml.tar.gz -C docs\coverage-genhtml .
if exist docs\coverxygen tar -czf release\doc-coverage-genhtml.tar.gz -C docs\coverxygen .
if exist docs\doccoverage-reportgenerator tar -czf release\doc-coverage-reportgenerator.tar.gz -C docs\doccoverage-reportgenerator .
tar -czf release\doxygen-api-docs.tar.gz -C docs\doxygen\html .

echo Zipping the whole site ^(release\site.zip -- unzip, open index.html^)...
powershell -NoProfile -Command "Compress-Archive -Path 'site\*' -DestinationPath 'release\site.zip' -Force"
if errorlevel 1 exit /b 1

echo Packaging a source archive ^(release\source.zip^)...
call git archive --format=zip --output=release\source.zip HEAD
if errorlevel 1 exit /b 1

echo Writing release notes...
> release\notes.md echo # %RELEASE_TAG%
>> release\notes.md echo.
>> release\notes.md echo Built and packaged locally by 10-release.bat. See docs\guide\reports-explained.en.md
>> release\notes.md echo for what each packaged report is, and docs\guide\releases-and-private-repos.en.md for
>> release\notes.md echo how to read this on GitHub Free with a private repository. If GitHub Pages is
>> release\notes.md echo enabled for this repository, the live site is also at your repository's Pages
>> release\notes.md echo URL ^(Settings -^> Pages^) -- otherwise open site.zip locally.
>> release\notes.md echo.
>> release\notes.md echo ## Commits
>> release\notes.md echo.
set "PREV_TAG="
for /f "delims=" %%t in ('git describe --tags --abbrev=0 2^>nul') do set "PREV_TAG=%%t"
if defined PREV_TAG (
    git log %PREV_TAG%..HEAD --oneline >> release\notes.md
) else (
    git log -n 20 --oneline >> release\notes.md
)
echo.

rem --- 4. Publish (or, in --dry-run, just show what would happen) ---
echo [4/4] Assets:
set "ASSET_ARGS="
for %%F in (release\*) do (
    echo   %%F
    set "ASSET_ARGS=!ASSET_ARGS! "%%F""
)
echo.

if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would run:
    echo   gh release create %RELEASE_TAG% !ASSET_ARGS! --title "%RELEASE_TAG%" --notes-file release\notes.md
    echo No release was created ^(--dry-run^). Remove --dry-run to publish for real.
    exit /b 0
)

echo Publishing GitHub release %RELEASE_TAG% ...
call gh release create %RELEASE_TAG% !ASSET_ARGS! --title "%RELEASE_TAG%" --notes-file release\notes.md
if errorlevel 1 (
    echo [ERROR] gh release create failed. See docs\guide\releases-and-private-repos.en.md for troubleshooting
    echo         ^(private repo 403/404, asset too large, not logged in^).
    exit /b 1
)
echo Done. Add your instructor as a collaborator so they can see this private release ^(see
echo docs\guide\releases-and-private-repos.en.md^).
