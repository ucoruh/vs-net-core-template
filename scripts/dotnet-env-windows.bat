@echo off
rem Shared environment for the numbered scripts, `call`-ed at the top of every script that needs
rem `dotnet`: loads project.env, then prefers the per-user .NET SDK installed by
rem 4-install-tools-windows.bat (%LocalAppData%\Microsoft\dotnet) over any machine-wide install, so
rem the template always builds with the SDK pinned in global.json.
call "%~dp0load-project-env-windows.bat"
if errorlevel 1 exit /b 1
if exist "%LocalAppData%\Microsoft\dotnet\dotnet.exe" (
    set "DOTNET_ROOT=%LocalAppData%\Microsoft\dotnet"
    set "PATH=%LocalAppData%\Microsoft\dotnet;%PATH%"
)
set "DOTNET_CLI_TELEMETRY_OPTOUT=1"
set "DOTNET_NOLOGO=1"
exit /b 0
