@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Installing the .NET SDK pinned in global.json, per-user (no admin rights needed)...
echo This does NOT touch any machine-wide .NET install in "Program Files\dotnet".
echo.

set "DOTNET_INSTALL_SCRIPT=%TEMP%\dotnet-install.ps1"

echo Downloading the official installer script from https://dot.net/v1/dotnet-install.ps1 ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://dot.net/v1/dotnet-install.ps1' -OutFile '%DOTNET_INSTALL_SCRIPT%'"
if errorlevel 1 (
    echo [ERROR] Could not download dotnet-install.ps1. Check your internet connection and try again.
    exit /b 1
)

for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "(Get-Content 'global.json' -Raw | ConvertFrom-Json).sdk.version"`) do set "SDK_VERSION=%%V"
if not defined SDK_VERSION (
    echo [ERROR] Could not read sdk.version from global.json.
    exit /b 1
)

rem dotnet-install.ps1's own default per-user install directory (no -InstallDir given) is
rem %LocalAppData%\Microsoft\dotnet -- NOT %USERPROFILE%\.dotnet (that folder only ever holds the
rem CLI's telemetry/tool cache, never an SDK). Do not "fix" this to look more like the Linux
rem script's default ($HOME/.dotnet, see 4-install-dotnet-sdk.sh) -- keep each OS's official default
rem so this stays in sync with dotnet-install.ps1 if Microsoft ever changes it.
echo Installing .NET SDK %SDK_VERSION% into %%LocalAppData%%\Microsoft\dotnet ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%DOTNET_INSTALL_SCRIPT%" -Version %SDK_VERSION%
if errorlevel 1 (
    echo [ERROR] dotnet-install.ps1 failed. See the messages above.
    exit /b 1
)

echo.
echo Installed. The other numbered scripts pick this SDK up automatically via dotnet-env.bat
echo (it is preferred over any older SDK in "Program Files\dotnet").
echo.
"%LocalAppData%\Microsoft\dotnet\dotnet.exe" --version
if errorlevel 1 (
    echo [ERROR] The newly installed dotnet.exe did not run correctly.
    exit /b 1
)

echo.
echo Done.
