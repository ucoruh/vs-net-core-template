@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Installs the pre-commit hook (scripts\hooks\pre-commit: formats staged .cs files with astyle and
rem checks that .gitignore / README.md / Doxyfile exist). Git runs hooks with its own bash, so the
rem hook file is the same on every platform. Safe to re-run: an existing hook is backed up once.
for /f "delims=" %%H in ('git rev-parse --git-path hooks 2^>nul') do set "HOOKS_DIR=%%H"
if not defined HOOKS_DIR (
    echo [ERROR] This folder is not a git repository ^(no .git^). Clone your repository first.
    exit /b 1
)
if not exist "%HOOKS_DIR%" mkdir "%HOOKS_DIR%"

if exist "%HOOKS_DIR%\pre-commit" if not exist "%HOOKS_DIR%\pre-commit.backup" (
    echo Backing up the current pre-commit hook to pre-commit.backup ...
    copy /Y "%HOOKS_DIR%\pre-commit" "%HOOKS_DIR%\pre-commit.backup" >nul
)
copy /Y "scripts\hooks\pre-commit" "%HOOKS_DIR%\pre-commit" >nul
if errorlevel 1 (
    echo [ERROR] Could not copy the hook into %HOOKS_DIR%.
    exit /b 1
)
echo Installed the pre-commit hook into %HOOKS_DIR%.
