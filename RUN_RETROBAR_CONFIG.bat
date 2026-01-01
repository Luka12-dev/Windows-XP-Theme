@echo off
title RetroBar Auto-Configurator
color 1F

echo.
echo ============================================================================
echo              RETROBAR AUTO-CONFIGURATOR (PYTHON)
echo ============================================================================
echo.
echo This will automatically configure RetroBar to Windows XP Blue theme
echo and start it with the correct settings.
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

echo ============================================================================
echo Configuring and starting RetroBar...
echo ============================================================================
echo.

REM Run the Python configurator
python configure_retrobar_auto.py

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Configuration failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo [SUCCESS] RetroBar is running with Windows XP Blue theme!
echo ============================================================================
echo.
pause
