@echo off
@setlocal enableextensions
@cd /d "%~dp0.."

rem Installs the Python tools from requirements.txt (MkDocs Material = the main site, coverxygen =
rem documentation coverage) with `pip install --user`. Called by 4-install-tools-windows.bat.
rem NOTE: on machines with several Python installs the plain "python" on PATH can be an unrelated
rem interpreter (e.g. one bundled with a vector-graphics editor), so this prefers the Windows "py"
rem launcher with an explicit version. See docs/guide/troubleshooting.en.md.

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
    echo         Install Python 3 ^(e.g. "choco install python -y" or from python.org^) and re-run.
    exit /b 1
)

echo Using: %PY_CMD%
call %PY_CMD% -m pip install --user -r requirements.txt
if errorlevel 1 (
    echo [ERROR] pip install -r requirements.txt failed.
    exit /b 1
)

echo.
echo Verifying the install...
call %PY_CMD% -c "import coverxygen, mkdocs, material; print('coverxygen, mkdocs and mkdocs-material import fine')"
if errorlevel 1 (
    echo [ERROR] The modules still do not import with "%PY_CMD%". See docs/guide/troubleshooting.en.md
    echo         for the "wrong python on PATH" fix.
    exit /b 1
)
exit /b 0
