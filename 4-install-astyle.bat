@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Checking if Astyle is installed...
where astyle >nul 2>&1
if %errorlevel%==0 (
    echo Astyle is already installed.
) else (
    echo Installing Astyle...
    choco install astyle -y
)

echo Done.
