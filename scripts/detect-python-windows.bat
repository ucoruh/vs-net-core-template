@echo off
rem Sets PYTHON_CMD to the first interpreter that has BOTH coverxygen and mkdocs (py -3.12, then
rem python, then py -3), and PYTHON_ANY to the first interpreter that runs at all (enough for
rem `-m http.server`). Why not just "python": on machines with several Python installs the plain
rem `python` on PATH can be an unrelated one (e.g. bundled with a vector-graphics editor) that has
rem none of the pip packages -- see docs/guide/troubleshooting.en.md.
set "PYTHON_CMD="
set "PYTHON_ANY="
call :try "py -3.12"
call :try "python"
call :try "py -3"
exit /b 0

:try
if not defined PYTHON_ANY (
    %~1 -c "import sys" >nul 2>&1
    if not errorlevel 1 set "PYTHON_ANY=%~1"
)
if not defined PYTHON_CMD (
    %~1 -c "import coverxygen, mkdocs" >nul 2>&1
    if not errorlevel 1 set "PYTHON_CMD=%~1"
)
exit /b 0
