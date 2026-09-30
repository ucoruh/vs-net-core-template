@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 6-build-and-test-windows.bat -- the FAST loop: restore, build (Debug) and run the unit tests.
rem No coverage, no reports, no docs -- use 7-build-all-windows.bat for those. Output goes to
rem build\windows-debug\ (dotnet --artifacts-path), so Windows and WSL builds of the same folder
rem never overwrite each other's obj\ files.
call "%~dp0scripts\dotnet-env-windows.bat"
if errorlevel 1 exit /b 1

echo ============================================================
echo  %PROJECT_NAME% %VERSION% :: 6-build-and-test ^(windows, Debug^)
echo ============================================================

call dotnet build "%SOLUTION_FILE%" --configuration Debug --artifacts-path "build\windows-debug" --nologo
if errorlevel 1 (
    echo [ERROR] dotnet build failed.
    exit /b 1
)
echo.
call dotnet test "%TEST_PROJECT%" --no-build --configuration Debug --artifacts-path "build\windows-debug" --nologo --verbosity minimal
if errorlevel 1 (
    echo [ERROR] Unit tests failed.
    exit /b 1
)
echo.
echo Done: build and unit tests passed. Next: 7-build-all-windows.bat ^(reports, API docs, site, release\^).
exit /b 0
