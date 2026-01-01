@echo off
title Install Python Dependencies for Icon Converter
color 0A

echo.
echo ============================================================================
echo                  INSTALL PYTHON DEPENDENCIES
echo ============================================================================
echo.
echo This will install the required Python packages for high-quality icon conversion.
echo.
echo Requirements:
echo - Python 3.7 or higher must be installed
echo - pip (Python package installer)
echo.
echo ============================================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed!
    echo.
    echo Please install Python from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)

echo [+] Python is installed
python --version
echo.

REM Check if pip is available
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] pip is not available!
    echo.
    echo Please reinstall Python and make sure pip is included.
    echo.
    pause
    exit /b 1
)

echo [+] pip is available
pip --version
echo.

echo ============================================================================
echo Installing required packages...
echo ============================================================================
echo.

REM Install Pillow (PIL)
echo [*] Installing Pillow (PIL) for image processing...
pip install Pillow>=10.0.0

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to install Pillow!
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo [SUCCESS] All dependencies installed!
echo ============================================================================
echo.
echo You can now run: convert_icons_hq.py
echo.
pause
