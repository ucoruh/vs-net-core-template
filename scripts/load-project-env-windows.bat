@echo off
rem Loads project.env (PROJECT_NAME, VERSION, SOLUTION_FILE, ...) into the calling script's
rem environment and sets PLATFORM_TOKEN / ARCH / ROOT_DIR. `call` this file; it deliberately has no
rem setlocal so the variables stay set in the caller. Plain KEY=VALUE lines; '#' lines are comments.
set "PLATFORM_TOKEN=windows"
set "ARCH=x64"
for %%I in ("%~dp0..") do set "ROOT_DIR=%%~fI"
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ROOT_DIR%\project.env") do set "%%A=%%B"
if not defined PROJECT_NAME (
    echo [ERROR] PROJECT_NAME is not defined -- is project.env missing or malformed?
    exit /b 1
)
exit /b 0
