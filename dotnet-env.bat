@echo off
rem Shared environment setup, `call`-ed at the top of the numbered scripts that need `dotnet`.
rem
rem Prefers the per-user .NET SDK installed by 4-install-dotnet-sdk.bat (dotnet-install.ps1's own
rem default install directory, %LocalAppData%\Microsoft\dotnet) over any machine-wide install in
rem "Program Files\dotnet", so the template always builds with the SDK pinned in global.json even
rem on a machine whose machine-wide SDK is older (this machine, for example, only had SDK 9.0.201
rem in Program Files before 4-install-dotnet-sdk.bat was run).
if exist "%LocalAppData%\Microsoft\dotnet\dotnet.exe" (
    set "DOTNET_ROOT=%LocalAppData%\Microsoft\dotnet"
    set "PATH=%LocalAppData%\Microsoft\dotnet;%PATH%"
)

set "DOTNET_CLI_TELEMETRY_OPTOUT=1"
set "DOTNET_NOLOGO=1"
exit /b 0
