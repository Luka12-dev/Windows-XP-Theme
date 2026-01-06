@echo off
title Windows XP Theme for Windows 11 - Launcher
color 1F
mode con: cols=80 lines=30

:MENU
cls
echo.
echo ============================================================================
echo                     WINDOWS XP THEME FOR WINDOWS 11
echo ============================================================================
echo.
echo   Transform your Windows 11 into Windows XP classic experience!
echo.
echo ============================================================================
echo.
echo   [0] CONVERT Icons (PNG to ICO) - RUN THIS FIRST!
echo   [1] TEST Theme (30 seconds, auto-restore)  - RECOMMENDED
echo   [2] APPLY Theme (Permanent until you restore)
echo   [3] RESTORE Windows 11 (Revert to default)
echo   [4] Configure OpenShell (Classic Start Menu)
echo   [5] Stop RetroBar Only
echo   [6] View README
echo   [7] Exit
echo.
echo ============================================================================
echo.
set /p choice="   Enter your choice (0-7): "

if "%choice%"=="0" goto CONVERT
if "%choice%"=="1" goto TEST
if "%choice%"=="2" goto APPLY
if "%choice%"=="3" goto RESTORE
if "%choice%"=="4" goto OPENSHELL
if "%choice%"=="5" goto STOPRETROBAR
if "%choice%"=="6" goto README
if "%choice%"=="7" goto EXIT
echo   Invalid choice! Please try again.
timeout /t 2 >nul
goto MENU

:CONVERT
cls
echo.
echo ============================================================================
echo                      CONVERT ICONS (PNG TO ICO)
echo ============================================================================
echo.
echo   This will convert all 500+ Windows XP PNG icons to ICO format
echo   with HIGH QUALITY preservation!
echo.
echo   Choose conversion method:
echo   [1] Python Converter (HIGH QUALITY - RECOMMENDED)
echo   [2] PowerShell Converter (Fast but lower quality)
echo   [3] Back to menu
echo.
echo ============================================================================
echo.
set /p convert_choice="   Enter your choice (1-3): "

if "%convert_choice%"=="1" goto CONVERT_PYTHON
if "%convert_choice%"=="2" goto CONVERT_PS
if "%convert_choice%"=="3" goto MENU
echo   Invalid choice!
timeout /t 2 >nul
goto CONVERT

:CONVERT_PYTHON
cls
echo.
echo ============================================================================
echo           HIGH-QUALITY PYTHON ICON CONVERTER
echo ============================================================================
echo.
echo   Using Python + Pillow for maximum quality
echo   - Multiple icon sizes (16x16 to 256x256)
echo   - High-quality scaling
echo   - Original quality preserved
echo.
echo   Requirements: Python 3.7+ with Pillow
echo.
echo ============================================================================
echo.
pause
call "%~dp0RUN_ICON_CONVERTER.bat"
goto MENU

:CONVERT_PS
cls
echo.
echo ============================================================================
echo              POWERSHELL ICON CONVERTER
echo ============================================================================
echo.
echo   Using PowerShell for quick conversion
echo   Note: Quality may be lower than Python version
echo.
echo ============================================================================
echo.
pause
powershell -ExecutionPolicy Bypass -File "%~dp0convert_all_icons.ps1"
goto MENU

:TEST
cls
echo.
echo ============================================================================
echo                           TEST MODE (30 SECONDS)
echo ============================================================================
echo.
echo   This will apply Windows XP theme for 30 seconds, then automatically
echo   restore Windows 11 theme. Perfect for trying it out!
echo.
echo   IMPORTANT: This requires Administrator privileges!
echo.
echo ============================================================================
echo.
pause
powershell -ExecutionPolicy Bypass -File "%~dp0run-test.ps1"
goto MENU

:APPLY
cls
echo.
echo ============================================================================
echo                        APPLY WINDOWS XP THEME
echo ============================================================================
echo.
echo   This will apply Windows XP theme to your Windows 11 system.
echo.
echo   What gets changed:
echo   - Wallpaper (Windows XP Bliss)
echo   - Colors (XP Blue theme)
echo   - Cursors (XP style)
echo   - Sounds (XP startup, shutdown, etc.)
echo   - Visual effects
echo.
echo   Your current settings will be backed up automatically!
echo   You can restore anytime using option [3]
echo.
echo   IMPORTANT: Requires Administrator privileges and restart recommended!
echo.
echo ============================================================================
echo.
pause
powershell -ExecutionPolicy Bypass -File "%~dp0run.ps1"
goto MENU

:RESTORE
cls
echo.
echo ============================================================================
echo                     RESTORE WINDOWS 11 DEFAULT THEME
echo ============================================================================
echo.
echo   This will restore your original Windows 11 theme from backup.
echo.
echo   All Windows XP customizations will be removed:
echo   - Original wallpaper restored
echo   - Windows 11 colors restored
echo   - Default cursors restored
echo   - Default sounds restored
echo   - Modern visual effects restored
echo.
echo   IMPORTANT: Requires Administrator privileges and restart recommended!
echo.
echo ============================================================================
echo.
pause
powershell -ExecutionPolicy Bypass -File "%~dp0back_to_win11.ps1"
goto MENU

:OPENSHELL
cls
echo.
echo ============================================================================
echo                   CONFIGURE OPENSHELL (CLASSIC START MENU)
echo ============================================================================
echo.
echo   This will configure OpenShell for Windows XP style Start Menu.
echo.
echo   What this does:
echo   - Sets classic two-column layout
echo   - Configures Windows XP-style animations
echo   - Enables Programs, Documents, Settings, Search, Run
echo   - Restarts OpenShell with XP configuration
echo.
echo   NOTE: OpenShell must be installed first!
echo   Download from: https://github.com/Open-Shell/Open-Shell-Menu/releases
echo.
echo   IMPORTANT: Requires Administrator privileges!
echo.
echo ============================================================================
echo.
pause
powershell -ExecutionPolicy Bypass -File "%~dp0configure_openshell.ps1"
goto MENU

:STOPRETROBAR
cls
echo.
echo ============================================================================
echo                         STOP RETROBAR TASKBAR
echo ============================================================================
echo.
echo   This will stop the RetroBar XP-style taskbar.
echo.
echo   What gets stopped:
echo   - RetroBar process
echo   - Windows 11 taskbar will be restored
echo.
echo   Note: This only stops RetroBar, theme stays applied
echo         To restore full Windows 11, use option [3]
echo.
echo   IMPORTANT: Requires Administrator privileges!
echo.
echo ============================================================================
echo.
pause
powershell -ExecutionPolicy Bypass -File "%~dp0stop_retrobar.ps1"
goto MENU

:README
cls
echo.
echo ============================================================================
echo                          OPENING README FILE
echo ============================================================================
echo.
start notepad.exe "%~dp0README.txt"
timeout /t 2 >nul
goto MENU

:EXIT
cls
echo.
echo ============================================================================
echo                            THANK YOU!
echo ============================================================================
echo.
echo   Enjoy your Windows XP experience on Windows 11!
echo.
echo   Remember:
echo   - All changes are reversible
echo   - Backups are created automatically
echo   - Run this launcher anytime to manage your theme
echo.
echo ============================================================================
echo.
timeout /t 3 >nul
exit

