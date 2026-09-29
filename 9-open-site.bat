@echo off
@setlocal enableextensions
@cd /d "%~dp0"

if not exist "site\index.html" (
    echo [ERROR] site\index.html not found. Run 7-build-app.bat first.
    exit /b 1
)

echo Opening site\index.html in your default browser...
rem "start" is safe here: opening the browser is the last, non-blocking action of this script and
rem nothing later depends on it finishing first (unlike inside 7-build-app, where "start" must
rem never be used for a step a later step depends on).
start "" "site\index.html"
