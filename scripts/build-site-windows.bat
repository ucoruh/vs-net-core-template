@echo off
@setlocal enableextensions
@cd /d "%~dp0.."

rem Builds the main site (MkDocs Material) and everything around it. Called by 7-build-all-windows.bat
rem (and usable on its own after a build): mkdocs build -> copy reports\<platform>\* and the DocFX
rem sites into site\ -> check the links of our own pages -> pack the neutral release assets
rem (source zip, site zip, ASSETS.md, SHA256SUMS.txt).
call "%~dp0dotnet-env-windows.bat"
call "%~dp0detect-python-windows.bat"
if not defined PYTHON_CMD (
    echo [ERROR] No Python with mkdocs and coverxygen found. Run 4-install-tools-windows.bat.
    exit /b 1
)
if exist site rd /S /Q site
set "NO_MKDOCS_2_WARNING=true"
call %PYTHON_CMD% -m mkdocs build --site-dir site
if errorlevel 1 (
    echo [ERROR] mkdocs build failed.
    exit /b 1
)
call %PYTHON_CMD% scripts\site_tools.py assemble-site --platforms windows,linux
if errorlevel 1 exit /b 1
call %PYTHON_CMD% scripts\site_tools.py check-links --site site
if errorlevel 1 exit /b 1
call %PYTHON_CMD% scripts\site_tools.py pack-neutral
if errorlevel 1 exit /b 1
exit /b 0
