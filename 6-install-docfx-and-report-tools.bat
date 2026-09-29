@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Call by full path (not bare filename): some machines set NoDefaultCurrentDirectoryInExePath,
rem which silently breaks a bare "call dotnet-env.bat" even right after "cd /d %~dp0" (see
rem docs/guide/troubleshooting.en.md).
call "%~dp0dotnet-env.bat"

echo Installing Doxygen (API docs, all three templates) and Graphviz (optional Doxygen diagrams)...

where doxygen >nul 2>&1
if %errorlevel%==0 (
    echo Doxygen is already installed.
) else (
    echo Installing Doxygen...
    choco install doxygen.install -y
)

where dot >nul 2>&1
if %errorlevel%==0 (
    echo Graphviz is already installed.
) else (
    echo Installing Graphviz...
    choco install graphviz -y
)

echo.
echo Restoring the local .NET tool manifest (ReportGenerator + DocFX; versions pinned in
echo .config\dotnet-tools.json, so every machine builds with the same tool versions)...
call dotnet tool restore
if errorlevel 1 (
    echo [ERROR] "dotnet tool restore" failed. Make sure 4-install-dotnet-sdk.bat has been run.
    exit /b 1
)

echo.
echo Done. reportgenerator and docfx are now available as local tools: "dotnet reportgenerator ..."
echo and "dotnet docfx ..." (only from this repository folder).
