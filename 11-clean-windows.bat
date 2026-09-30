@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 11-clean-windows.bat -- deletes every generated folder (all of them are gitignored):
rem build\  publish\  reports\  site\  site-native\  release\  plus docfx\api, TestResults, bin\ and obj\.
rem Nothing tracked by git is touched. Add "all" to also drop ReportGenerator's history (report_history\).
echo Cleaning generated output...
for %%D in (build publish reports site site-native release docfx\api TestResults) do (
    if exist "%%D" ( echo   removing %%D & rd /S /Q "%%D" )
)
for /d /r %%D in (bin obj) do (
    if exist "%%D" rd /S /Q "%%D" 2>nul
)
if /I "%~1"=="all" if exist report_history ( echo   removing report_history & rd /S /Q report_history )
echo Done.
exit /b 0
