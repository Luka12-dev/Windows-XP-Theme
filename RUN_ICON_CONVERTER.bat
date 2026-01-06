@echo off
title Windows XP Icon Converter - High Quality
color 1F

echo.
echo ============================================================================
echo              HIGH-QUALITY ICON CONVERTER (PYTHON)
echo ============================================================================
echo.
echo This will convert all Windows XP PNG icons to ICO format with
echo MAXIMUM QUALITY preservation!
echo.
echo ============================================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed!
    echo.
    echo Please install Python first:
    echo 1. Download from: https://www.python.org/downloads/
    echo 2. Run installer and CHECK "Add Python to PATH"
    echo 3. Restart this script
    echo.
    pause
    exit /b 1
)

echo [+] Python detected
python --version
echo.

REM Check if Pillow is installed
python -c "import PIL" >nul 2>&1
if not %errorlevel% == 0 (
    echo [!] Pillow ^(PIL^) is not installed!
    echo [*] Installing Pillow now...
    echo.
    pip install Pillow
    echo.
    if not %errorlevel% == 0 (
        echo [ERROR] Failed to install Pillow!
        echo Please run: INSTALL_PYTHON.bat
        echo.
        pause
        exit /b 1
    )
    echo [+] Pillow installed successfully!
    echo.
)

echo [+] All dependencies ready
echo.
echo ============================================================================
echo Starting conversion...
echo ============================================================================
echo.

REM Run the Python converter
python convert_icons_hq.py

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Conversion failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo [SUCCESS] Conversion complete!
echo ============================================================================
echo.
