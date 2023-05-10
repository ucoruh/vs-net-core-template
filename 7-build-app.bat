@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Generate Documentation
doxygen Doxyfile

echo Testing Application with Coverage
cd CalculatorLibrary.Tests
dotnet restore
dotnet add package coverlet.msbuild
dotnet build --configuration Release
dotnet test --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage" --results-directory:./TestResults --logger:trx

echo Generate Test Report
cd ..
reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:coveragereport" -reporttypes:Html
reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:assets" -reporttypes:Badges

echo Publish Linux Binaries
dotnet publish -c Release -r linux-x64 --self-contained true -o publish/linux
echo Publish MacOS Binaries
dotnet publish -c Release -r osx-x64 --self-contained true -o publish/macos
echo Publish Windows Binaries
dotnet publish -c Release -r win-x64 --self-contained true -o publish/windows

echo Package Linux Binaries
tar -czvf linux-binaries.tar.gz -C publish/linux .
echo Package MacOS Binaries
tar -czvf macos-binaries.tar.gz -C publish/macos .
echo Package Windows Binaries
tar -czvf windows-binaries.tar.gz -C publish/windows .

echo Package Coverage Report
tar -czvf test-coverage-html.tar.gz -C coveragereport .
echo Package Code Documentation
tar -czvf doxygen-output-html-xml-latex-rtf.tar.gz -C docs .

echo Operation Completed!
pause