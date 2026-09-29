@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 9-open-site.bat [port]
rem   port   TCP port to serve on (default 8080). Pass a different one if 8080 is already in use
rem          (see docs\guide\troubleshooting.en.md).
rem
rem Serves the built site over a small local HTTP server instead of opening site\index.html
rem directly with "start": many browsers block an <iframe> (used by every page under
rem docs\report-pages\, see docs\guide\embed-html-in-site.en.md) from loading another local file when
rem the parent page itself was opened via a bare file:// path. A real, even tiny, HTTP server
rem avoids that restriction entirely. Runs in the foreground -- press Ctrl+C to stop it; that is
rem also the only way this script's server process ever ends (never taskkill it by name).

if not exist "site\index.html" (
    echo [ERROR] site\index.html not found. Run 7-build-app.bat first.
    exit /b 1
)

set "PORT=%~1"
if "%PORT%"=="" set "PORT=8080"

rem Prefer the same py -3.12 the other scripts standardize on; fall back gracefully so this still
rem works on a machine that only has a bare "python" on PATH.
set "SITE_PYTHON="
where py >nul 2>&1
if not errorlevel 1 (
    py -3.12 -c "1" >nul 2>&1
    if not errorlevel 1 set "SITE_PYTHON=py -3.12"
)
if not defined SITE_PYTHON (
    where py >nul 2>&1
    if not errorlevel 1 set "SITE_PYTHON=py -3"
)
if not defined SITE_PYTHON (
    where python >nul 2>&1
    if not errorlevel 1 set "SITE_PYTHON=python"
)
if not defined SITE_PYTHON (
    echo [ERROR] No Python interpreter found ^(tried py -3.12, py -3, python^). Install one -- see
    echo         docs\guide\install.en.md -- or open site\index.html directly ^(report pages'
    echo         iframes will not load from a plain file:// path^).
    exit /b 1
)

echo ============================================================
echo  vs-net-core-template :: 9-open-site
echo  Serving site\ at http://localhost:%PORT%/
echo  Press Ctrl+C to stop the server.
echo ============================================================
echo.

rem Open the browser first (non-blocking); the server below then blocks in the foreground.
start "" "http://localhost:%PORT%/"

%SITE_PYTHON% -m http.server %PORT% --directory site
if errorlevel 1 (
    echo.
    echo [ERROR] The local HTTP server exited with an error -- port %PORT% may already be in use.
    echo         Try a different port: 9-open-site.bat 8081  ^(see docs\guide\troubleshooting.en.md^).
    exit /b 1
)
