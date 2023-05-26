@echo off
@setlocal enableextensions
@cd /d "%~dp0"
echo Installing Report Generator...
choco install lcov -y
echo lcov and genhtml located on C:\ProgramData\chocolatey\lib\lcov\tools\bin\
pause

