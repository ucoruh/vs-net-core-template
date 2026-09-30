@echo off
@setlocal enableextensions
@cd /d "%~dp0"
rem NOTE: delayed expansion is intentionally left OFF in this script: some .gitignore lines start
rem with "!" (negation patterns) and would be corrupted by delayed-expansion substitution.

rem Regenerates the toptal.com part of .gitignore. This is safe to re-run: everything from the
rem "## BEGIN project-specific ##" marker to the end of the file is this project's own additions
rem (generated-output folders like docs/coveragereport, site, release, ...) and is preserved across
rem regeneration instead of being overwritten by the downloaded template.

set API_URL=https://www.toptal.com/developers/gitignore/api/c,csharp,vs,visualstudio,visualstudiocode,java,maven,c++,cmake,eclipse,netbeans
set OUTPUT_FILE=.gitignore
set MARKER=## BEGIN project-specific (kept across regeneration by 2-create-gitignore-{windows.bat,linux.sh}) ##
set TEMP_BASE=%TEMP%\vs-net-core-template-gitignore.tmp
set TEMP_CUSTOM=%TEMP%\vs-net-core-template-gitignore.custom.tmp

if exist "%TEMP_CUSTOM%" del /f /q "%TEMP_CUSTOM%" >nul 2>&1
if exist "%OUTPUT_FILE%" (
    findstr /n /c:"%MARKER%" "%OUTPUT_FILE%" >nul 2>&1
    if not errorlevel 1 (
        echo Preserving the existing project-specific section of %OUTPUT_FILE% ...
        call :extract_from_marker
    )
)

echo Downloading .gitignore base from %API_URL% ...
curl -fsS -o "%TEMP_BASE%" "%API_URL%"
if errorlevel 1 (
    echo [ERROR] Could not download the .gitignore template. Check your internet connection.
    exit /b 1
)

copy /y "%TEMP_BASE%" "%OUTPUT_FILE%" >nul
if exist "%TEMP_CUSTOM%" (
    echo.>> "%OUTPUT_FILE%"
    type "%TEMP_CUSTOM%" >> "%OUTPUT_FILE%"
) else (
    echo No existing project-specific section found ^(first run^); re-run this script after
    echo 7-build-all-windows.bat has generated its output folders once, or restore the section from
    echo version control if you overwrote it by mistake.
)

del /f /q "%TEMP_BASE%" >nul 2>&1
if exist "%TEMP_CUSTOM%" del /f /q "%TEMP_CUSTOM%" >nul 2>&1

echo Wrote %OUTPUT_FILE%.
exit /b 0

:extract_from_marker
rem Copies everything from the marker line onward (inclusive) into TEMP_CUSTOM.
set "FOUND="
(for /f "usebackq delims=" %%L in ("%OUTPUT_FILE%") do (
    if defined FOUND (
        echo(%%L
    ) else if "%%L"=="%MARKER%" (
        set "FOUND=1"
        echo(%%L
    )
)) > "%TEMP_CUSTOM%"
exit /b 0
