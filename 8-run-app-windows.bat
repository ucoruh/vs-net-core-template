@echo off
@setlocal enableextensions
@cd /d "%~dp0"
call "%~dp0scripts\dotnet-env-windows.bat"

rem Runs the sample app. With no arguments it prints a short built-in demo; with three arguments
rem (operation a b) it computes that one operation, e.g.  8-run-app-windows.bat add 2 3
rem It never reads from the console, so it is safe to call from another script or from CI.
call dotnet run --project "%APP_PROJECT%" --configuration Release --artifacts-path "build\windows-release" -- %*
exit /b %ERRORLEVEL%
