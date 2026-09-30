@echo off
@setlocal enableextensions
@cd /d "%~dp0"
call "%~dp0scripts\load-project-env-windows.bat"

rem 9-open-site-windows.bat [port]
rem   port   TCP port to serve on (default 8080). Pass another one if 8080 is already in use.
rem
rem Serves the built site (site\) over a small local HTTP server and opens the browser. Do not
rem double-click site\index.html: many browsers block an <iframe> (every standalone report page under
rem reports\<platform>\ frames its report) from loading another file when the parent page was opened via
rem a bare file:// path. A real, even tiny, HTTP server avoids that. Runs in the foreground: press
rem Ctrl+C to stop it -- that is the only way this server ever ends (never kill it by name).
rem This is also how you show the whole project WITHOUT GitHub Pages (docs\guide\showing-without-pages.en.md).

if not exist "site\index.html" (
    echo [ERROR] site\index.html not found. Run 7-build-all-windows.bat first.
    exit /b 1
)

set "PORT=%~1"
if "%PORT%"=="" set "PORT=8080"

call "%~dp0scripts\detect-python-windows.bat"
if not defined PYTHON_ANY (
    echo [ERROR] No Python interpreter found ^(tried py -3.12, python, py -3^). Install one -- see
    echo         docs\guide\install.en.md.
    exit /b 1
)

echo ============================================================
echo  %PROJECT_NAME% :: 9-open-site ^(windows^)
echo  Serving site\ at http://localhost:%PORT%/
echo  Press Ctrl+C to stop the server.
echo ============================================================
echo.

rem Open the browser first (non-blocking); the server below then blocks in the foreground.
start "" "http://localhost:%PORT%/"

%PYTHON_ANY% -m http.server %PORT% --directory site
if errorlevel 1 (
    echo.
    echo [ERROR] The local HTTP server exited with an error -- port %PORT% may already be in use.
    echo         Try a different port: 9-open-site-windows.bat 8081  ^(see docs\guide\troubleshooting.en.md^).
    exit /b 1
)
