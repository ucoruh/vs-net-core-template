@echo off
@setlocal enableextensions
@cd /d "%~dp0"
echo Installing lcov (provides genhtml, used for the native code-coverage and documentation-coverage HTML reports)...
where genhtml >nul 2>&1
if %errorlevel%==0 (
    echo genhtml is already installed and on PATH.
) else (
    choco install lcov -y
    echo Installed. genhtml lives under C:\ProgramData\chocolatey\lib\lcov\tools\bin\ and is a Perl
    echo script; 7-build-app.bat finds it via PATH and runs it with perl automatically.
)
echo Done.
