@echo off
@setlocal enableextensions
@cd /d "%~dp0"
set "currentDir=%CD%"
set "currentDirFwd=%currentDir:\=/%"

rem Call by full path, not bare filename: some machines set NoDefaultCurrentDirectoryInExePath,
rem which silently breaks a bare "call dotnet-env.bat" even right after "cd /d %~dp0". See
rem docs/guide/troubleshooting.en.md.
call "%~dp0dotnet-env.bat"

echo ============================================================
echo  vs-net-core-template :: 7-build-app
echo  Repo root: %currentDir%
echo ============================================================
echo.

rem ---------------------------------------------------------------------------
rem Helper subroutines (defined at the bottom, jumped over here)
rem ---------------------------------------------------------------------------
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

:find_genhtml
set "GENHTML_PATH="
set "GENHTML_FOUND=0"
for /f "delims=" %%G in ('where genhtml 2^>nul') do if not defined GENHTML_PATH set "GENHTML_PATH=%%G"
if not defined GENHTML_PATH if exist "C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml" set "GENHTML_PATH=C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml"
if defined GENHTML_PATH (
    where perl >nul 2>&1
    if not errorlevel 1 set "GENHTML_FOUND=1"
)
if "%GENHTML_FOUND%"=="0" (
    echo [WARN] genhtml/perl not found. Run 4-install-lcov.bat, then re-run this script to also
    echo        get the native lcov HTML reports. Continuing without them for now.
)
exit /b 0

:find_python
set "COVERXYGEN_PYTHON="
where py >nul 2>&1
if not errorlevel 1 (
    py -3.12 -c "import coverxygen" >nul 2>&1
    if not errorlevel 1 set "COVERXYGEN_PYTHON=py -3.12"
)
if not defined COVERXYGEN_PYTHON (
    python -c "import coverxygen" >nul 2>&1
    if not errorlevel 1 set "COVERXYGEN_PYTHON=python"
)
if not defined COVERXYGEN_PYTHON (
    where py >nul 2>&1
    if not errorlevel 1 (
        py -3 -c "import coverxygen" >nul 2>&1
        if not errorlevel 1 set "COVERXYGEN_PYTHON=py -3"
    )
)
exit /b 0

:after_helpers

rem ---------------------------------------------------------------------------
rem 0. Clean and recreate the folders this script (re-)generates. Idempotent:
rem    guard every rd with an exist check so a fresh clone (nothing to delete
rem    yet) does not print a scary, harmless error.
rem ---------------------------------------------------------------------------
echo [0/8] Cleaning previous output...
for %%D in (docs\doxygen docs\coverxygen docs\doccoverage-reportgenerator docs\coveragereport docs\coverage-genhtml docs\testresults site) do (
    if exist "%%D" rd /S /Q "%%D"
)
mkdir docs\doxygen 2>nul
mkdir docs\coverxygen 2>nul
mkdir docs\doccoverage-reportgenerator 2>nul
mkdir docs\coveragereport 2>nul
mkdir docs\coverage-genhtml 2>nul
mkdir docs\testresults 2>nul
mkdir site 2>nul
echo Done.
echo.

rem ---------------------------------------------------------------------------
rem 1. Restore + build (Release)
rem ---------------------------------------------------------------------------
echo [1/8] Restoring and building the solution (Release, .NET %DOTNET_ROOT%)...
call dotnet restore CalculatorLibrary.sln
call :check "dotnet restore" || exit /b 1
call dotnet build CalculatorLibrary.sln --configuration Release
call :check "dotnet build" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
rem 2. Tests with coverage: TRX + native HTML logger, cobertura + lcov coverage
rem    in one run (see CalculatorLibrary.Tests\coverlet.runsettings)
rem ---------------------------------------------------------------------------
echo [2/8] Running tests with coverage...
call dotnet test CalculatorLibrary.Tests\CalculatorLibrary.Tests.csproj ^
    --no-build --configuration Release --verbosity normal ^
    --collect:"XPlat Code Coverage" --settings CalculatorLibrary.Tests\coverlet.runsettings ^
    --results-directory docs\testresults ^
    --logger "trx;LogFileName=test-results.trx" ^
    --logger "html;LogFileName=test-results.html"
call :check "dotnet test" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
rem 3. Doxygen: ecosystem-neutral API docs (same tool the C/C++ and Java
rem    templates use), reads the same XML doc comments DocFX reads later.
rem ---------------------------------------------------------------------------
echo [3/8] Generating Doxygen documentation...
where doxygen >nul 2>&1
if errorlevel 1 (
    echo [ERROR] doxygen not found. Run 6-install-docfx-and-report-tools.bat first.
    exit /b 1
)
call doxygen Doxyfile
call :check "doxygen" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
rem 4. Documentation coverage: coverxygen -> lcov -> genhtml AND ReportGenerator
rem ---------------------------------------------------------------------------
echo [4/8] Documentation coverage (coverxygen)...
call :find_python
if not defined COVERXYGEN_PYTHON (
    echo [ERROR] No Python interpreter with the "coverxygen" module was found.
    echo         Plain "python" on PATH can resolve to an unrelated interpreter on machines with
    echo         several Python installs ^(e.g. some vector-graphics editors ship their own
    echo         python.exe earlier on PATH than a real Python install^) -- that interpreter will
    echo         not have coverxygen, and this step would otherwise silently produce nothing.
    echo         Fix: run "py -3.12 -m pip install --user coverxygen" ^(or 4-install-coverxygen.bat^),
    echo         then re-run this script. See docs/guide/troubleshooting.en.md.
    echo         Skipping the documentation-coverage report for now.
    goto :after_doc_coverage
)
echo   Using: %COVERXYGEN_PYTHON%
rem coverxygen's --prefix is a FILTER (keep only files under this path), matched against the
rem forward-slash paths Doxygen records internally even on Windows -- currentDirFwd, not
rem currentDir, or every file is filtered out and lcov.info comes out empty.
call %COVERXYGEN_PYTHON% -m coverxygen --xml-dir docs\doxygen\xml --src-dir . --format lcov --output docs\coverxygen\lcov.info --prefix "%currentDirFwd%/"
call :check "coverxygen" || exit /b 1

call :find_genhtml
if "%GENHTML_FOUND%"=="1" (
    call perl "%GENHTML_PATH%" --legend --title "Documentation Coverage Report" docs\coverxygen\lcov.info -o docs\coverxygen
    call :check "genhtml - documentation coverage" || exit /b 1
) else (
    echo   Skipping genhtml documentation-coverage report ^(genhtml not available^).
)

call dotnet reportgenerator "-reports:docs\coverxygen\lcov.info" "-targetdir:docs\doccoverage-reportgenerator" -reporttypes:Html
call :check "reportgenerator - documentation coverage" || exit /b 1
:after_doc_coverage
echo.

rem ---------------------------------------------------------------------------
rem 5. Code coverage: ReportGenerator (cobertura, + badges + history) AND
rem    genhtml (lcov) -- both read from the SAME coverlet run (step 2).
rem ---------------------------------------------------------------------------
echo [5/8] Code coverage reports...
call dotnet reportgenerator "-reports:docs\testresults\**\coverage.cobertura.xml" "-targetdir:docs\coveragereport" "-reporttypes:Html;Badges" -historydir:report_history
call :check "reportgenerator - code coverage HTML" || exit /b 1

rem A second, badges-only pass writes into the tracked assets/ folder, so the README's coverage
rem badges are up to date the next time this repository is committed (everything else under
rem docs/ and site/ is generated and gitignored -- the badges are the one exception, see
rem .gitignore and docs/guide/daily-workflow.en.md).
call dotnet reportgenerator "-reports:docs\testresults\**\coverage.cobertura.xml" "-targetdir:assets" -reporttypes:Badges
call :check "reportgenerator - code coverage badges" || exit /b 1

rem NOTE: the "set" and its "%LCOV_COVERAGE_FILE%" reads are deliberately three SEPARATE top-level
rem statements, not nested inside one if(...)-block together: cmd.exe expands %VAR% once, when a
rem block is PARSED, not per execution, so a set-then-read of the same variable inside one shared
rem if(...)/for(...) block silently reads the value from BEFORE the block started (empty, here) --
rem this bit us during testing (genhtml received an empty path). Keeping every read in its own
rem statement, evaluated after the for loop's statement has already finished, avoids the whole
rem class of bug without needing setlocal enabledelayedexpansion. See docs/guide/troubleshooting.en.md.
set "LCOV_COVERAGE_FILE="
if "%GENHTML_FOUND%"=="1" for /f "delims=" %%F in ('dir /b /s "docs\testresults\coverage.info" 2^>nul') do if not defined LCOV_COVERAGE_FILE set "LCOV_COVERAGE_FILE=%%F"

if "%GENHTML_FOUND%"=="1" if defined LCOV_COVERAGE_FILE (
    call perl "%GENHTML_PATH%" --legend --title "Code Coverage Report - lcov via coverlet" "%LCOV_COVERAGE_FILE%" -o docs\coverage-genhtml
    call :check "genhtml - code coverage" || exit /b 1
)
if "%GENHTML_FOUND%"=="1" if not defined LCOV_COVERAGE_FILE (
    echo   [WARN] No coverage.info ^(lcov^) file found under docs\testresults; skipping genhtml code-coverage report.
)
if not "%GENHTML_FOUND%"=="1" (
    echo   Skipping genhtml code-coverage report ^(genhtml not available^).
)
echo.

rem ---------------------------------------------------------------------------
rem 6. Copy assets and README for the site
rem ---------------------------------------------------------------------------
echo [6/8] Copying assets and building the site's home page content...
rem docs\assets is for pages that already live under docs\ (e.g. docs\developers.md's image);
rem the top-level assets\ resource mapping in docfx.json covers the root index.md below.
robocopy assets docs\assets /E /NFL /NDL /NJH /NJS >nul
call :check_robocopy "robocopy assets -> docs\assets" || exit /b 1
rem A root-level index.md, not docs\index.md: this is the site's actual home page (site\index.html)
rem and what lets the shipped site.zip work as "unzip, open index.html" (see
rem docs/guide/releases-and-private-repos.en.md). Its relative links (docs/guide/..., assets/...)
rem are written to resolve correctly from the repository root -- which is also where this file
rem lives -- so, unlike an earlier docs\index.md copy, no link needs an extra "../".
copy /Y README.md index.md >nul
call :check "copy README.md -> index.md" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
rem 7. DocFX site: API reference (from XML doc comments) + conceptual guide
rem    articles + every report linked (see toc.yml / docs\toc.yml).
rem ---------------------------------------------------------------------------
echo [7/8] Building the DocFX site...
call dotnet tool restore
call :check "dotnet tool restore" || exit /b 1
call dotnet docfx metadata docfx.json
call :check "docfx metadata" || exit /b 1
call dotnet docfx build docfx.json
call :check "docfx build" || exit /b 1
echo.

rem ---------------------------------------------------------------------------
rem 8. Summary
rem ---------------------------------------------------------------------------
echo [8/8] Done.
echo.
echo   Site:                              site\index.html            (open with 9-open-site.bat)
echo   Unit test results (native):        docs\testresults\test-results.html
echo   Code coverage (ReportGenerator):   docs\coveragereport\index.html
echo   Code coverage (genhtml/lcov):      docs\coverage-genhtml\index.html
echo   Doc coverage (genhtml/lcov):       docs\coverxygen\index.html
echo   Doc coverage (ReportGenerator):    docs\doccoverage-reportgenerator\index.html
echo   Doxygen API docs:                  docs\doxygen\html\index.html
echo.
echo   See docs\guide\reports-explained.en.md ("Which report is which?") for what each one shows.
echo ============================================================
