@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Installing coverxygen (turns Doxygen's XML output into an lcov file for documentation-coverage reports)...
echo.
echo NOTE: on machines with several Python installs, the plain "python" on PATH can resolve to an
echo unrelated interpreter that does not have pip packages installed into it (e.g. some vector-
echo graphics editors ship their own bundled python.exe earlier on PATH than a real Python
echo install). This script and 7-build-app.bat both prefer the Windows "py" launcher with an
echo explicit version (py -3.12) for that reason. See docs/guide/troubleshooting.en.md.

set "PY_CMD="
where py >nul 2>&1
if not errorlevel 1 (
    py -3.12 -c "print()" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=py -3.12"
)
if not defined PY_CMD (
    where python >nul 2>&1
    if not errorlevel 1 set "PY_CMD=python"
)
if not defined PY_CMD (
    echo [ERROR] No usable Python was found ^(tried "py -3.12" and "python"^).
    echo         Install Python 3 ^(e.g. choco install python -y^ or from python.org^) and re-run this script.
    exit /b 1
)

echo Using: %PY_CMD%
call %PY_CMD% -m pip install --user coverxygen
if errorlevel 1 (
    echo [ERROR] pip install coverxygen failed.
    exit /b 1
)

echo.
echo Verifying the install...
call %PY_CMD% -m coverxygen --help >nul 2>&1
if errorlevel 1 (
    echo [ERROR] "%PY_CMD% -m coverxygen" still does not work after installing. See
    echo         docs/guide/troubleshooting.en.md for the "wrong python on PATH" fix.
    exit /b 1
)

echo Done. 7-build-app.bat will pick this Python up automatically.
