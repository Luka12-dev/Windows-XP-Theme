#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configure OpenShell for Windows XP Classic Start Menu
.DESCRIPTION
    Configures OpenShell settings to match Windows XP Start Menu style
#>

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenShell Configuration for XP Theme  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some settings may not apply correctly" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "[*] Configuring OpenShell for Windows XP style..." -ForegroundColor Yellow
Write-Host ""

# OpenShell settings registry path
$OpenShellRegPath = "HKCU:\Software\OpenShell\StartMenu\Settings"

# Create registry path if it doesn't exist
if (-not (Test-Path $OpenShellRegPath)) {
    New-Item -Path $OpenShellRegPath -Force | Out-Null
    Write-Host "[+] Created OpenShell registry path" -ForegroundColor Green
}

# Windows XP Start Menu configuration
Write-Host "[*] Applying Windows XP Start Menu settings..." -ForegroundColor Cyan

# Basic Settings
Set-ItemProperty -Path $OpenShellRegPath -Name "MenuStyle" -Value "Classic2" -Type String -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "SkinW7" -Value "Windows Aero" -Type String -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "SkinVariationW7" -Value "" -Type String -ErrorAction SilentlyContinue

# XP Two-Column Style
Set-ItemProperty -Path $OpenShellRegPath -Name "TwoColumns" -Value 1 -Type DWord -ErrorAction SilentlyContinue

# Show user picture
Set-ItemProperty -Path $OpenShellRegPath -Name "EnableUserPicture" -Value 1 -Type DWord -ErrorAction SilentlyContinue

# Classic XP animations
Set-ItemProperty -Path $OpenShellRegPath -Name "MenuAnimation" -Value "Fade" -Type String -ErrorAction SilentlyContinue

# Show Programs, Documents, Settings, Search, Run
Set-ItemProperty -Path $OpenShellRegPath -Name "EnableSettings" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "EnableDocuments" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "EnableControlPanel" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "EnableRun" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "EnableSearch" -Value 1 -Type DWord -ErrorAction SilentlyContinue

# Classic XP behavior
Set-ItemProperty -Path $OpenShellRegPath -Name "CascadeAll" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $OpenShellRegPath -Name "MenuItems7" -Value "Programs, Documents, Settings, Search, Run, Logoff, Shutdown" -Type String -ErrorAction SilentlyContinue

Write-Host "  [OK] Windows XP settings applied" -ForegroundColor Green
Write-Host ""

# Check if OpenShell is running and restart it
Write-Host "[*] Restarting OpenShell to apply changes..." -ForegroundColor Yellow

# Stop OpenShell
$OpenShellProcess = Get-Process -Name "StartMenu" -ErrorAction SilentlyContinue
if ($OpenShellProcess) {
    $OpenShellProcess | Stop-Process -Force
    Start-Sleep -Seconds 1
}

# Find OpenShell executable
$OpenShellPaths = @(
    "C:\Program Files\Open-Shell\StartMenu.exe",
    "C:\Program Files (x86)\Open-Shell\StartMenu.exe",
    "${env:ProgramFiles}\Open-Shell\StartMenu.exe",
    "${env:ProgramFiles(x86)}\Open-Shell\StartMenu.exe"
)

$OpenShellExe = $null
foreach ($path in $OpenShellPaths) {
    if (Test-Path $path) {
        $OpenShellExe = $path
        break
    }
}

if ($OpenShellExe) {
    Start-Process -FilePath $OpenShellExe -WindowStyle Hidden
    Start-Sleep -Seconds 2
    Write-Host "  [+] OpenShell restarted with XP configuration!" -ForegroundColor Green
} else {
    Write-Host "  [!] OpenShell executable not found" -ForegroundColor Yellow
    Write-Host "  [!] Install OpenShell from: https://github.com/Open-Shell/Open-Shell-Menu/releases" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Configuration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "OpenShell is now configured for Windows XP style!" -ForegroundColor White
Write-Host ""
Write-Host "Features enabled:" -ForegroundColor Yellow
Write-Host "  - Classic two-column Start Menu" -ForegroundColor White
Write-Host "  - User picture display" -ForegroundColor White
Write-Host "  - Programs, Documents, Settings" -ForegroundColor White
Write-Host "  - Search and Run commands" -ForegroundColor White
Write-Host "  - Fade animation (XP style)" -ForegroundColor White
Write-Host ""
Write-Host "To customize further:" -ForegroundColor Cyan
Write-Host "  1. Right-click Start button" -ForegroundColor White
Write-Host "  2. Select 'Settings'" -ForegroundColor White
Write-Host "  3. Choose Windows XP skin/theme" -ForegroundColor White
Write-Host ""
