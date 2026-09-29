@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Call by full path, not bare filename: see docs/guide/troubleshooting.en.md
rem ("NoDefaultCurrentDirectoryInExePath").
call "%~dp0dotnet-env.bat"

rem Runs the sample app. With no arguments it prints a short built-in demo; with three arguments
rem (operation a b) it computes that one operation. It never reads from the console, so it is safe
rem to call from another script or from CI without blocking.
call dotnet run --project CalculatorApp\CalculatorApp.csproj --configuration Release -- %*
exit /b %ERRORLEVEL%
