#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Stop RetroBar and restore Windows 11 taskbar
.DESCRIPTION
    Stops RetroBar process and restores the default Windows 11 taskbar
#>

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Stopping RetroBar  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kill RetroBar processes
$RetroBarProcesses = Get-Process -Name "RetroBar" -ErrorAction SilentlyContinue
if ($RetroBarProcesses) {
    Write-Host "[*] Stopping RetroBar..." -ForegroundColor Yellow
    $RetroBarProcesses | Stop-Process -Force
    Start-Sleep -Seconds 1
    Write-Host "[+] RetroBar stopped" -ForegroundColor Green
} else {
    Write-Host "[!] RetroBar is not running" -ForegroundColor Yellow
}

# Restart Explorer to restore Windows 11 taskbar
Write-Host "[*] Restarting Explorer to restore Windows 11 taskbar..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "[+] Windows 11 taskbar restored" -ForegroundColor Green
Write-Host ""
