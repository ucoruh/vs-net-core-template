@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Generate Documentation
doxygen Doxyfile
cd CalculatorLibrary.Tests
dotnet restore
dotnet add package coverlet.msbuild
dotnet build --configuration Release
dotnet test --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage" --results-directory:./TestResults --logger:trx
cd ..
reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:coveragereport" -reporttypes:Html
reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:assets" -reporttypes:Badges
dotnet publish -c Release -r win-x64 --self-contained true -o publish/windows
tar -czvf windows-binaries.tar.gz -C publish/windows .
tar -czvf test-coverage-html.tar.gz -C coveragereport .
tar -czvf doxygen-output-html-xml-latex-rtf.tar.gz -C doxygen-output .

pause