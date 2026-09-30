@echo off
rem Sets GENHTML_FOUND (0/1), GENHTML_PATH and PERL. genhtml (from the Chocolatey "lcov" package) is
rem a Perl script. `where perl` often lists Git's bundled MSYS perl (...\Git\usr\bin\perl.exe) FIRST;
rem that perl fails on genhtml with "genhtml: ERROR: cannot read C:/...File.cs" (MSYS path handling),
rem so a Windows-native perl (Strawberry, ActiveState, ...) is required: skip every match under
rem "\usr\bin\" and take the first remaining one.
set "GENHTML_PATH="
set "GENHTML_FOUND=0"
set "PERL="
for /f "delims=" %%G in ('where genhtml 2^>nul') do if not defined GENHTML_PATH set "GENHTML_PATH=%%G"
if not defined GENHTML_PATH if exist "C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml" set "GENHTML_PATH=C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml"
if defined GENHTML_PATH (
    for /f "delims=" %%P in ('where perl 2^>nul ^| findstr /V /I /L /C:"\usr\bin"') do if not defined PERL set "PERL=%%P"
    if defined PERL set "GENHTML_FOUND=1"
)
if "%GENHTML_FOUND%"=="0" (
    echo [WARN] genhtml / a Windows-native perl was not found. Run 4-install-tools-windows.bat ^(installs lcov^)
    echo        and, if only Git's MSYS perl is on PATH, "choco install strawberryperl -y". Continuing
    echo        without the native lcov HTML reports.
)
exit /b 0
