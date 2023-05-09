@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem force re-install need "--force --force-dependencies -y" parameters

REM Test if Pandoc is installed
where pandoc >nul 2>&1
if %errorlevel%==0 (
    echo Pandoc is already installed.
) else (
    echo Installing Pandoc...
    choco install pandoc -y
)

REM Test if rsvg-convert is installed
where rsvg-convert >nul 2>&1
if %errorlevel%==0 (
    echo rsvg-convert is already installed.
) else (
    echo Installing rsvg-convert...
    choco install rsvg-convert -y
)

REM Test if Python is installed
where python >nul 2>&1
if %errorlevel%==0 (
    echo Python is already installed.
) else (
    echo Installing Python...
    choco install python -y
)


REM Test if Miktex is installed
where miktex >nul 2>&1
if %errorlevel%==0 (
    echo Miktex is already installed.
) else (
    echo Installing Miktex...
    choco install miktex -y
)

REM Test if CuRL is installed
where curl >nul 2>&1
if %errorlevel%==0 (
    echo curl is already installed.
) else (
    echo Installing CuRL...
    choco install curl -y
)

REM Test if MARP-CLI is installed
where marp >nul 2>&1
if %errorlevel%==0 (
    echo MARP-CLI is already installed.
) else (
    echo Installing MARP-CLI...
    choco install marp-cli -y
)

REM Test if Doxygen is installed
where doxygen >nul 2>&1
if %errorlevel%==0 (
    echo MARP-CLI is already installed.
) else (
    echo Installing Doxygen...
    choco install doxygen.install -y
)

REM Test if Doxygen is installed
where dot >nul 2>&1
if %errorlevel%==0 (
    echo Graphviz is already installed.
) else (
    echo Installing Graphviz...
    choco install graphviz -y
)

pip install mkdocs
pip install pymdown-extensions
pip install mkdocs-material
pip install mkdocs-material-extensions
pip install mkdocs-simple-hooks
pip install mkdocs-video
pip install mkdocs-minify-plugin
pip install mkdocs-git-revision-date-localized-plugin
pip install mkdocs-minify-plugin
pip install mkdocs-static-i18n
pip install mkdocs-with-pdf
pip install qrcode
pip install mkdocs-awesome-pages-plugin
pip install mkdocs-embed-external-markdown
pip install mkdocs-include-markdown-plugin
pip install mkdocs-ezlinks-plugin
pip install mkdocs-git-authors-plugin
pip install mkdocs-git-committers-plugin
pip install mkdocs-exclude

pip install pptx2md
pause