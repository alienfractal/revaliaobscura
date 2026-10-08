@echo off
setlocal

cd /d "%~dp0"

where dart >nul 2>nul
if errorlevel 1 (
    echo ERROR: Dart was not found on PATH.
    echo Make sure the Flutter SDK's bin directory is on PATH.
    exit /b 1
)

echo Generating Flutter asset references...
call dart run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo ERROR: Flutter asset generation failed.
    exit /b 1
)

echo.
echo Flutter asset generation completed successfully.
exit /b 0
