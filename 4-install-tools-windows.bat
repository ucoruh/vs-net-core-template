@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 4-install-tools-windows.bat -- installs every tool the other scripts need. Safe to re-run.
rem   .NET SDK (per user, version from global.json)   Doxygen + Graphviz   lcov (genhtml) + Perl
rem   astyle (code formatter)   ReportGenerator + DocFX (local dotnet tools)   MkDocs Material + coverxygen (pip)
rem Needs Chocolatey for Doxygen/Graphviz/lcov/astyle: run 3-install-package-manager-windows.bat first
rem (as Administrator) if `choco` is not found.

call "%~dp0scripts\dotnet-env-windows.bat"
echo ============================================================
echo  %PROJECT_NAME% :: 4-install-tools ^(windows^)
echo ============================================================

echo.
echo [1/6] .NET SDK pinned in global.json ^(per user, no admin rights^)...
call "%~dp0scripts\install-dotnet-sdk-windows.bat"
if errorlevel 1 exit /b 1
call "%~dp0scripts\dotnet-env-windows.bat"

where choco >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Chocolatey ^(choco^) was not found. Run 3-install-package-manager-windows.bat as
    echo         Administrator first, open a NEW terminal, then re-run this script.
    exit /b 1
)

echo.
echo [2/6] Doxygen ^(API docs^) and Graphviz ^(optional Doxygen diagrams^)...
where doxygen >nul 2>&1
if errorlevel 1 ( choco install doxygen.install -y ) else ( echo Doxygen is already installed. )
where dot >nul 2>&1
if errorlevel 1 ( choco install graphviz -y ) else ( echo Graphviz is already installed. )

echo.
echo [3/6] lcov ^(provides genhtml, the native coverage HTML^) and a Windows-native Perl...
where genhtml >nul 2>&1
if errorlevel 1 (
    if not exist "C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml" choco install lcov -y
)
call "%~dp0scripts\detect-genhtml-windows.bat"
if "%GENHTML_FOUND%"=="0" (
    echo Only Git's MSYS perl was found ^(genhtml cannot use it^): installing Strawberry Perl...
    choco install strawberryperl -y
)

echo.
echo [4/6] astyle ^(code formatter, used by 5-format-code and the pre-commit hook^)...
where astyle >nul 2>&1
if errorlevel 1 ( choco install astyle -y ) else ( echo astyle is already installed. )

echo.
echo [5/6] Local dotnet tools ^(ReportGenerator + DocFX, versions pinned in .config\dotnet-tools.json^)...
call dotnet tool restore
if errorlevel 1 (
    echo [ERROR] "dotnet tool restore" failed.
    exit /b 1
)

echo.
echo [6/6] Python tools ^(MkDocs Material + coverxygen, from requirements.txt^)...
call "%~dp0scripts\install-python-tools-windows.bat"
if errorlevel 1 exit /b 1

echo.
echo Done. Open a NEW terminal if a tool is still not found ^(PATH changes only apply to new terminals^).
echo Next: 6-build-and-test-windows.bat ^(fast^) or 7-build-all-windows.bat ^(everything^).
exit /b 0
