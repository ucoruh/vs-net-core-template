@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 7-build-all-windows.bat [--no-site]
rem   Builds EVERYTHING on Windows: Release build, unit tests + coverage, every report of both
rem   families, Doxygen and DocFX API docs, the app (dotnet publish), the release\ folder and -- unless
rem   --no-site is given (CI does that in the per-platform jobs) -- the MkDocs site.
rem
rem   Output (all gitignored, same layout on every template):
rem     build\windows-release\              compiler output
rem     publish\windows-x64\                the app
rem     reports\windows\<kind>-<tool>\      tests-trx, coverage-reportgenerator, coverage-lcov,
rem                                         doccoverage-reportgenerator, doccoverage-lcov, api-doxygen, api-docfx
rem     site\  site-native\  release\       the site, the DocFX site, every release asset
rem   Linux/WSL has its own twin: 7-build-all-linux.sh (reports there can differ, so they are kept apart).

set "NO_SITE=0"
if /I "%~1"=="--no-site" set "NO_SITE=1"

rem Call helpers by full path: some machines set NoDefaultCurrentDirectoryInExePath, which silently
rem breaks a bare "call script.bat" even right after "cd /d %~dp0" (docs/guide/troubleshooting.en.md).
call "%~dp0scripts\dotnet-env-windows.bat"
if errorlevel 1 exit /b 1
set "currentDir=%CD%"
set "currentDirFwd=%currentDir:\=/%"
set "R=reports\%PLATFORM_TOKEN%"

echo ============================================================
echo  %PROJECT_NAME% %VERSION% :: 7-build-all ^(%PLATFORM_TOKEN%^)
echo  Repo root: %currentDir%
echo ============================================================
echo.

goto :after_helpers

:check
if errorlevel 1 (
    echo.
    echo [ERROR] %~1 failed ^(exit code %ERRORLEVEL%^). Stopping.
    exit /b 1
)
exit /b 0

:check_robocopy
rem robocopy's own exit codes 0-7 are success/informational; 8+ is a real failure.
if errorlevel 8 (
    echo.
    echo [ERROR] %~1 failed ^(robocopy exit code %ERRORLEVEL%^). Stopping.
    exit /b 1
)
exit /b 0

:after_helpers

call "%~dp0scripts\detect-python-windows.bat"
if not defined PYTHON_CMD (
    echo [ERROR] No Python with BOTH coverxygen and mkdocs was found ^(tried py -3.12, python, py -3^).
    echo         Plain "python" on PATH can be an unrelated interpreter on machines with several Python
    echo         installs. Fix: run 4-install-tools-windows.bat ^(or "py -3.12 -m pip install --user -r requirements.txt"^).
    echo         See docs/guide/troubleshooting.en.md.
    exit /b 1
)
echo Python: %PYTHON_CMD%
call "%~dp0scripts\detect-genhtml-windows.bat"
where doxygen >nul 2>&1
if errorlevel 1 (
    echo [ERROR] doxygen not found. Run 4-install-tools-windows.bat first.
    exit /b 1
)
echo.

rem ---------------------------------------------------------------------------
echo [0/9] Cleaning this platform's previous output...
rem Every rd is guarded by an exist check so a fresh clone does not print a harmless error.
for %%D in (%R% build\doxygen site site-native) do (
    if exist "%%D" rd /S /Q "%%D"
)
mkdir %R%\_raw 2>nul
echo Done.
echo.

rem ---------------------------------------------------------------------------
echo [1/9] Restoring the local dotnet tools ^(ReportGenerator, DocFX^) and building the solution ^(Release^)...
call dotnet tool restore
call :check "dotnet tool restore" || exit /b 1
call dotnet build "%SOLUTION_FILE%" --configuration Release --artifacts-path "build\windows-release" --nologo
call :check "dotnet build" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
echo [2/9] Unit tests with coverage ^(TRX + native HTML; cobertura + lcov^)...
call dotnet test "%TEST_PROJECT%" ^
    --no-build --configuration Release --artifacts-path "build\windows-release" --verbosity normal ^
    --collect:"XPlat Code Coverage" --settings CalculatorLibrary.Tests\coverlet.runsettings ^
    --results-directory %R%\_raw\testresults ^
    --logger "trx;LogFileName=test-results.trx" ^
    --logger "html;LogFileName=test-results.html"
call :check "dotnet test" || exit /b 1
mkdir %R%\tests-trx 2>nul
copy /Y %R%\_raw\testresults\test-results.* %R%\tests-trx\ >nul
call :check "collect test results" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
echo [3/9] Doxygen API docs...
call doxygen Doxyfile
call :check "doxygen" || exit /b 1
robocopy build\doxygen\html %R%\api-doxygen /E /NFL /NDL /NJH /NJS /NP >nul
call :check_robocopy "copy Doxygen HTML" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
echo [4/9] Documentation coverage ^(coverxygen -^> lcov -^> genhtml AND ReportGenerator^)...
mkdir %R%\_raw\doccoverage 2>nul
rem --prefix is a FILTER matched against the forward-slash paths Doxygen records even on Windows.
call %PYTHON_CMD% -m coverxygen --xml-dir build\doxygen\xml --src-dir . --format lcov --output %R%\_raw\doccoverage\lcov.info --prefix "%currentDirFwd%/"
call :check "coverxygen" || exit /b 1

if "%GENHTML_FOUND%"=="1" (
    call "%PERL%" "%GENHTML_PATH%" --legend --title "Documentation Coverage Report" %R%\_raw\doccoverage\lcov.info -o %R%\doccoverage-lcov
    call :check "genhtml - documentation coverage" || exit /b 1
) else (
    echo   Skipping the genhtml documentation-coverage report ^(genhtml not available^).
)
call dotnet reportgenerator "-reports:%R%\_raw\doccoverage\lcov.info" "-targetdir:%R%\doccoverage-reportgenerator" "-reporttypes:Html;Badges"
call :check "reportgenerator - documentation coverage" || exit /b 1
copy /Y %R%\doccoverage-reportgenerator\badge_linecoverage.svg docs\assets\badge_doccoverage.svg >nul
echo.

rem ---------------------------------------------------------------------------
echo [5/9] Code coverage ^(ReportGenerator from cobertura AND genhtml from lcov^)...
call dotnet reportgenerator "-reports:%R%\_raw\testresults\**\coverage.cobertura.xml" "-targetdir:%R%\coverage-reportgenerator" "-reporttypes:Html;Badges" "-historydir:report_history\%PLATFORM_TOKEN%"
call :check "reportgenerator - code coverage" || exit /b 1
rem The four README/site badges are tracked files: refresh them from this run.
for %%B in (combined branchcoverage linecoverage methodcoverage) do copy /Y %R%\coverage-reportgenerator\badge_%%B.svg docs\assets\badge_%%B.svg >nul

rem NOTE: set and read of the same variable are separate top-level statements on purpose: cmd expands
rem %VAR% once per parsed block, so set-then-read inside one if/for block reads the OLD value.
set "LCOV_COVERAGE_FILE="
if "%GENHTML_FOUND%"=="1" for /f "delims=" %%F in ('dir /b /s "%R%\_raw\testresults\coverage.info" 2^>nul') do if not defined LCOV_COVERAGE_FILE set "LCOV_COVERAGE_FILE=%%F"
if "%GENHTML_FOUND%"=="1" if defined LCOV_COVERAGE_FILE (
    call "%PERL%" "%GENHTML_PATH%" --legend --title "Code Coverage Report - lcov via coverlet" "%LCOV_COVERAGE_FILE%" -o %R%\coverage-lcov
    call :check "genhtml - code coverage" || exit /b 1
)
if "%GENHTML_FOUND%"=="1" if not defined LCOV_COVERAGE_FILE echo   [WARN] No coverage.info ^(lcov^) found; skipping the genhtml code-coverage report.
if not "%GENHTML_FOUND%"=="1" echo   Skipping the genhtml code-coverage report ^(genhtml not available^).
echo.

rem ---------------------------------------------------------------------------
echo [6/9] DocFX API reference ^(a complete site of its own, kept under native\ -- never framed^)...
call dotnet docfx metadata docfx\docfx.json
call :check "docfx metadata" || exit /b 1
call dotnet docfx build docfx\docfx.json -o %R%\api-docfx
call :check "docfx build" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
echo [7/9] Publishing the app ^(self-contained win-x64^)...
if exist publish\windows-x64 rd /S /Q publish\windows-x64
call dotnet publish "%APP_PROJECT%" --configuration Release -r win-x64 --self-contained true --artifacts-path "build\windows-release" -o publish\windows-x64 --nologo
call :check "dotnet publish" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
echo [8/9] Packing this platform's release assets into release\ ...
call %PYTHON_CMD% scripts\site_tools.py pack-platform --platform windows --arch x64
call :check "pack-platform" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
if "%NO_SITE%"=="1" (
    echo [9/9] Skipping the site ^(--no-site^).
) else (
    echo [9/9] Building the MkDocs site, assembling reports, checking links...
    call "%~dp0scripts\build-site-windows.bat"
    call :check "build-site" || exit /b 1
)
echo.
echo ============================================================
echo  Done.
echo   Site ^(main^):             site\index.html          ^(open it with 9-open-site-windows.bat^)
echo   DocFX site ^(native^):     site-native\windows\index.html
echo   Reports:                 %R%\   tests-trx  coverage-*  doccoverage-*  api-*
echo   The app:                 publish\windows-x64\
echo   Every release asset:     release\   ^(ASSETS.md lists them^)
echo   What each report is:     docs\guide\reports-explained.en.md
echo ============================================================
exit /b 0
