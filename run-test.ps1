#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Test Windows XP Theme for 30 seconds
.DESCRIPTION
    Applies Windows XP theme for 30 seconds, then automatically reverts to Windows 11
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows XP Theme - 30 Second Test  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on the script and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[*] This will apply Windows XP theme for 30 seconds, then automatically restore Windows 11 theme" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to start the test..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# Create a special backup directory for test
$TestBackupDir = Join-Path $ScriptRoot "Backup_Win11_Test"
$OriginalBackupDir = Join-Path $ScriptRoot "Backup_Win11"

# If test backup exists, remove it
if (Test-Path $TestBackupDir) {
    Remove-Item -Path $TestBackupDir -Recurse -Force
}

# Temporarily rename original backup if it exists
$BackupRenamed = $false
if (Test-Path $OriginalBackupDir) {
    Rename-Item -Path $OriginalBackupDir -NewName "Backup_Win11_Test" -Force
    $BackupRenamed = $true
}

try {
    # Apply Windows XP Theme
    Write-Host "[*] Applying Windows XP theme..." -ForegroundColor Green
    & "$ScriptRoot\run.ps1"
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  TESTING - Theme applied for 30 seconds" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    # Countdown timer
    for ($i = 30; $i -gt 0; $i--) {
        Write-Host "`r  Time remaining: $i seconds... " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }
    
    Write-Host ""
    Write-Host ""
    Write-Host "[*] Test period complete! Restoring Windows 11 theme..." -ForegroundColor Yellow
    
    # Restore Windows 11 theme
    & "$ScriptRoot\back_to_win11.ps1"
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Test Complete - Theme Restored!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
} finally {
    # Clean up test backup
    if (Test-Path $TestBackupDir) {
        # If we renamed the original backup, rename it back
        if ($BackupRenamed) {
            Remove-Item -Path $TestBackupDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "RESULTS:" -ForegroundColor Yellow
Write-Host "- If you liked the theme, run: run.ps1" -ForegroundColor White
Write-Host "- The theme has been reverted to Windows 11 default" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
