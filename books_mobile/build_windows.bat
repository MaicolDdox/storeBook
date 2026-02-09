@echo off
REM Setup Visual Studio environment and build Flutter Windows app
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
cd /d "%~dp0"
flutter clean
flutter pub get
flutter build windows
pause
