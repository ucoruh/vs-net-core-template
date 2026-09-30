@echo off
@setlocal enableextensions
@cd /d "%~dp0"
call "%~dp0scripts\dotnet-env-windows.bat"

echo Formatting code with astyle ^(options in astyle-options.txt^)...
where astyle >nul 2>&1
if errorlevel 1 (
    echo [ERROR] astyle was not found on PATH. Run 4-install-tools-windows.bat first.
    exit /b 1
)

call astyle --options="astyle-options.txt" --exclude=obj --exclude=bin --ignore-exclude-errors --recursive "CalculatorApp/*.cs" "CalculatorLibrary/*.cs" "CalculatorLibrary.Tests/*.cs"
if errorlevel 1 (
    echo [ERROR] astyle reported a formatting error.
    exit /b 1
)
echo Done.
