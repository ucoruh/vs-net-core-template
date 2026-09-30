@echo off
setlocal enableextensions enabledelayedexpansion
cd /d "%~dp0"

rem 10-release-windows.bat [--dry-run]
rem   Builds everything locally (7-build-all-windows.bat) and publishes the release\ folder as a GitHub
rem   Release with the GitHub CLI. The version comes from project.env (VERSION=2.1.0 -> tag v2.1.0);
rem   change it there, commit, then release. Works on private repositories and on GitHub Free; uses no
rem   Actions minutes. Locally the release holds THIS platform's assets plus the neutral ones -- CI
rem   builds both platforms (and macOS); if the tag's release already exists this script uploads its
rem   assets to it instead of creating a new one.
rem   --dry-run  builds and packs, prints the exact gh command and the asset list, publishes nothing.
rem See docs\guide\releases-and-private-repos.en.md and docs\guide\showing-without-pages.en.md.

call "%~dp0scripts\dotnet-env-windows.bat"
if errorlevel 1 exit /b 1

set "DRY_RUN=0"
if /I "%~1"=="--dry-run" set "DRY_RUN=1"
if /I "%~2"=="--dry-run" set "DRY_RUN=1"
set "TAG=v%VERSION%"

echo ============================================================
echo  %PROJECT_NAME% :: 10-release ^(windows^) :: %TAG%
if "%DRY_RUN%"=="1" echo  Mode: DRY RUN -- nothing will be published
echo ============================================================
echo.

where gh >nul 2>&1
if errorlevel 1 (
    echo [ERROR] GitHub CLI ^(gh^) not found. Install it, e.g. "winget install GitHub.cli", then run
    echo         "gh auth login". See docs\guide\releases-and-private-repos.en.md.
    if "%DRY_RUN%"=="0" exit /b 1
)
set "GH_LOGGED_IN=0"
gh auth status >nul 2>&1
if not errorlevel 1 set "GH_LOGGED_IN=1"
if "%GH_LOGGED_IN%"=="0" echo [WARN] gh is not logged in ^(run "gh auth login"^). Fine for --dry-run; a real release needs it.
if "%DRY_RUN%"=="0" if "%GH_LOGGED_IN%"=="0" (
    echo [ERROR] gh is not logged in. Run "gh auth login", then re-run this script.
    exit /b 1
)

set "GIT_DIRTY="
for /f "delims=" %%s in ('git status --porcelain 2^>nul') do set "GIT_DIRTY=1"
if "%DRY_RUN%"=="0" if defined GIT_DIRTY (
    echo [ERROR] Working tree has uncommitted changes. Commit or stash them before a real release.
    echo         ^(--dry-run skips this check.^)
    exit /b 1
)
if "%DRY_RUN%"=="1" if defined GIT_DIRTY echo [WARN] Uncommitted changes -- fine for --dry-run, a real release refuses this.
echo.

echo [1/2] Building everything ^(7-build-all-windows^)...
call "%~dp07-build-all-windows.bat"
if errorlevel 1 (
    echo [ERROR] 7-build-all-windows.bat failed; aborting the release.
    exit /b 1
)
echo.

echo [2/2] Assets in release\ :
set "ASSET_ARGS="
for %%F in (release\*) do (
    echo   %%F
    set ASSET_ARGS=!ASSET_ARGS! "%%F"
)
echo.

set "RELEASE_EXISTS=0"
if "%GH_LOGGED_IN%"=="1" (
    gh release view %TAG% >nul 2>&1
    if not errorlevel 1 set "RELEASE_EXISTS=1"
)
if "%RELEASE_EXISTS%"=="1" (
    set "GH_CMD=gh release upload %TAG% !ASSET_ARGS! --clobber"
) else (
    set GH_CMD=gh release create %TAG% !ASSET_ARGS! --title "%PROJECT_NAME% %VERSION%" --notes-file build\release-notes.md
)

if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would run:
    echo   !GH_CMD!
    echo No release was created ^(--dry-run^). Remove --dry-run to publish for real.
    exit /b 0
)

echo Publishing %TAG% ...
call !GH_CMD!
if errorlevel 1 (
    echo [ERROR] gh failed. See docs\guide\releases-and-private-repos.en.md ^(private repo 403/404, asset too large, not logged in^).
    exit /b 1
)
echo Done. Add your instructor as a collaborator so they can see a private release.
exit /b 0
