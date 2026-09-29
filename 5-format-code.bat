@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Formatting Code with Astyle...
where astyle >nul 2>&1
if errorlevel 1 (
    echo [ERROR] astyle was not found on PATH. Run 4-install-astyle.bat first.
    exit /b 1
)

call astyle --options="astyle-options.txt" --exclude=obj --exclude=bin --recursive "CalculatorApp/*.cs" "CalculatorLibrary/*.cs" "CalculatorLibrary.Tests/*.cs"
if errorlevel 1 (
    echo [ERROR] astyle reported a formatting error.
    exit /b 1
)

echo Done.
