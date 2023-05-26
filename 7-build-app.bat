@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Delete and Create the "release" folder and its contents
rd /S /Q "release"
mkdir release

echo Delete the "docs" folder and its contents
rd /S /Q "docs/coverxygen"
rd /S /Q "docs/coveragereport"
rd /S /Q "docs/doxygen"
mkdir docs
cd docs
mkdir coverxygen
mkdir coveragereport
mkdir doxygen
cd ..

echo Delete the "site" folder and its contents
rd /S /Q "site"
mkdir site

echo Folders are Recreated successfully.

echo Generate Documentation
call doxygen Doxyfile

echo Run Coverxygen
call python -m coverxygen --xml-dir ./docs/doxygen/xml --src-dir ./ --format lcov --output ./docs/coverxygen/lcov.info --prefix %currentDir%\

echo Run lcov genhtml
call perl C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml --legend --title "Documentation Coverage Report" ./docs/coverxygen/lcov.info -o docs/coverxygen

echo Testing Application with Coverage
cd CalculatorLibrary.Tests
call dotnet restore
call dotnet add package coverlet.msbuild
call dotnet build --configuration Release
call dotnet test --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage" --results-directory:./TestResults --logger:trx

echo Generate Test Report
cd ..
call reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:docs/coveragereport" -reporttypes:Html
call reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:assets" -reporttypes:Badges

echo Copy the "assets" folder and its contents to "docs" recursively
call robocopy assets "docs\assets" /E

echo Copy the "README.md" file to "docs\index.md"
call copy README.md "docs\index.md"

echo Files and folders copied successfully.

echo Generate Webpage
call mkdocs build

echo Publish Linux Binaries
call dotnet publish -c Release -r linux-x64 --self-contained true -o publish/linux

echo Publish MacOS Binaries
call dotnet publish -c Release -r osx-x64 --self-contained true -o publish/macos

echo Publish Windows Binaries
call dotnet publish -c Release -r win-x64 --self-contained true -o publish/windows

echo Package Linux Binaries
call tar -czvf release/linux-binaries.tar.gz -C publish/linux .

echo Package MacOS Binaries
call tar -czvf release/macos-binaries.tar.gz -C publish/macos .

echo Package Windows Binaries
call tar -czvf release/windows-binaries.tar.gz -C publish/windows .

echo Package Test Coverage Report
tar -czvf release/test-coverage-report.tar.gz -C docs/coveragereport .

echo Package Doc Coverage Report
tar -czvf release/doc-coverage-report.tar.gz -C docs/coverxygen .

echo Package Code Documentation
tar -czvf release/doxygen-documentation.tar.gz -C docs/doxygen .

echo ....................
echo Operation Completed!
echo Press Any Key to Continue...
pause