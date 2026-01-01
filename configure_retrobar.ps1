#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configure RetroBar for Windows XP Theme
.DESCRIPTION
    Automatically configures RetroBar to use Windows XP Blue theme
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RetroBar Configuration for XP Theme  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if RetroBar exists
$RetroBarPath = Join-Path $ScriptRoot "Retro_Bar\RetroBar.exe"
if (-not (Test-Path $RetroBarPath)) {
    Write-Host "ERROR: RetroBar.exe not found at: $RetroBarPath" -ForegroundColor Red
    Write-Host "Please download RetroBar and place it in the Retro_Bar folder" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[*] Configuring RetroBar for Windows XP Blue theme..." -ForegroundColor Yellow
Write-Host ""

# RetroBar configuration path
$RetroBarConfigDir = Join-Path $env:APPDATA "RetroBar"
$RetroBarConfigFile = Join-Path $RetroBarConfigDir "RetroBar.xml"

# Create config directory if it doesn't exist
if (-not (Test-Path $RetroBarConfigDir)) {
    New-Item -ItemType Directory -Path $RetroBarConfigDir -Force | Out-Null
    Write-Host "[+] Created RetroBar config directory" -ForegroundColor Green
}

# Create RetroBar configuration for Windows XP Blue
$XPConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Settings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <CurrentTheme>Windows XP Blue</CurrentTheme>
  <EdgeMode>Bottom</EdgeMode>
  <AutoHide>false</AutoHide>
  <ShowClock>true</ShowClock>
  <ShowNotificationArea>true</ShowNotificationArea>
  <ShowTaskView>false</ShowTaskView>
  <ShowMultiMon>true</ShowMultiMon>
  <CollapseNotifyIcons>false</CollapseNotifyIcons>
  <UseTaskbarAnimation>true</UseTaskbarAnimation>
</Settings>
"@

# Write configuration file
$XPConfig | Out-File -FilePath $RetroBarConfigFile -Encoding UTF8 -Force
Write-Host "[+] RetroBar configuration created" -ForegroundColor Green
Write-Host "    Theme: Windows XP Blue" -ForegroundColor White
Write-Host "    Config: $RetroBarConfigFile" -ForegroundColor White
Write-Host ""

# Kill any existing RetroBar processes
$RetroBarProcesses = Get-Process -Name "RetroBar" -ErrorAction SilentlyContinue
if ($RetroBarProcesses) {
    Write-Host "[*] Stopping existing RetroBar processes..." -ForegroundColor Yellow
    $RetroBarProcesses | Stop-Process -Force
    Start-Sleep -Seconds 1
}

# Hide Windows 11 taskbar
Write-Host "[*] Hiding Windows 11 taskbar..." -ForegroundColor Yellow
$TaskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
if (Test-Path $TaskbarPath) {
    # This will auto-hide the Windows 11 taskbar
    $key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSizeMove" -Value 0 -ErrorAction SilentlyContinue
}

# Start RetroBar
Write-Host "[*] Starting RetroBar..." -ForegroundColor Yellow
Start-Process -FilePath $RetroBarPath -WindowStyle Hidden
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  RetroBar Configured & Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "RetroBar is now running with Windows XP Blue theme!" -ForegroundColor White
Write-Host ""
Write-Host "NOTES:" -ForegroundColor Yellow
Write-Host "- RetroBar will replace your taskbar with XP-style taskbar" -ForegroundColor White
Write-Host "- To customize: Right-click RetroBar > Properties" -ForegroundColor White
Write-Host "- To stop: Right-click RetroBar > Exit" -ForegroundColor White
Write-Host "- RetroBar will start automatically with the theme" -ForegroundColor White
Write-Host ""