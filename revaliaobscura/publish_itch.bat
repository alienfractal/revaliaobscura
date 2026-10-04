@echo off
setlocal

cd /d "%~dp0"

if not defined ITCH_API_KEY (
    echo ERROR: ITCH_API_KEY is not set.
    echo.
    echo In Command Prompt, run:
    echo   set "ITCH_API_KEY=your-itch-api-key"
    echo   publish_itch.bat
    exit /b 1
)

where flutter >nul 2>nul
if errorlevel 1 (
    echo ERROR: Flutter was not found on PATH.
    exit /b 1
)

where python >nul 2>nul
if errorlevel 1 (
    echo ERROR: Python was not found on PATH.
    exit /b 1
)

if not exist "%~dp0butler.exe" (
    echo ERROR: butler.exe was not found in the project directory.
    exit /b 1
)

python -c "import requests, yaml" >nul 2>nul
if errorlevel 1 (
    echo Installing the Python publishing dependencies...
    python -m pip install requests pyyaml
    if errorlevel 1 (
        echo ERROR: Could not install the Python publishing dependencies.
        exit /b 1
    )
)

echo Building the web release...
call flutter build web --release
if errorlevel 1 (
    echo ERROR: The Flutter web build failed. Nothing was uploaded.
    exit /b 1
)

echo Publishing to itch.io...
python publish_itch.py
if errorlevel 1 (
    echo ERROR: The itch.io upload failed.
    exit /b 1
)

echo.
echo Publish completed successfully.
exit /b 0
