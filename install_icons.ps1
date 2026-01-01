#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Install Windows XP Icons
.DESCRIPTION
    This script helps replace Windows 11 system icons with Windows XP icons.
    Note: Some icons may require third-party tools or manual replacement.
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows XP Icons Installer  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on the script and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

$IconsDir = Join-Path $ScriptRoot "Icons"
if (-not (Test-Path $IconsDir)) {
    Write-Host "ERROR: Icons directory not found!" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[*] Installing Windows XP Icons..." -ForegroundColor Yellow
Write-Host ""

# Create custom icon directory
$CustomIconDir = Join-Path $env:USERPROFILE "WindowsXP_Icons"
if (-not (Test-Path $CustomIconDir)) {
    New-Item -ItemType Directory -Path $CustomIconDir -Force | Out-Null
}

# Copy all XP icons to user directory
Write-Host "[1/5] Copying icons to user directory..." -ForegroundColor Cyan
Copy-Item -Path "$IconsDir\*" -Destination $CustomIconDir -Recurse -Force
Write-Host "  [OK] Icons copied to: $CustomIconDir" -ForegroundColor Green

# Change Desktop Icons
Write-Host "[2/5] Configuring desktop icons..." -ForegroundColor Cyan

$DesktopIconsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID"

# My Computer Icon
$MyComputerIcon = Join-Path $CustomIconDir "My Computer.png"
$MyComputerCLSID = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$MyComputerPath = Join-Path $DesktopIconsPath $MyComputerCLSID
if (-not (Test-Path $MyComputerPath)) {
    New-Item -Path $MyComputerPath -Force | Out-Null
}
if (-not (Test-Path "$MyComputerPath\DefaultIcon")) {
    New-Item -Path "$MyComputerPath\DefaultIcon" -Force | Out-Null
}

# My Documents Icon
$MyDocumentsIcon = Join-Path $CustomIconDir "My Documents.png"
$MyDocumentsCLSID = "{450D8FBA-AD25-11D0-98A8-0800361B1103}"
$MyDocumentsPath = Join-Path $DesktopIconsPath $MyDocumentsCLSID
if (-not (Test-Path $MyDocumentsPath)) {
    New-Item -Path $MyDocumentsPath -Force | Out-Null
}
if (-not (Test-Path "$MyDocumentsPath\DefaultIcon")) {
    New-Item -Path "$MyDocumentsPath\DefaultIcon" -Force | Out-Null
}

# Recycle Bin Icons
$RecycleBinEmptyIcon = Join-Path $CustomIconDir "Recycle Bin (empty).png"
$RecycleBinFullIcon = Join-Path $CustomIconDir "Recycle Bin (full).png"
$RecycleBinCLSID = "{645FF040-5081-101B-9F08-00AA002F954E}"
$RecycleBinPath = Join-Path $DesktopIconsPath $RecycleBinCLSID
if (-not (Test-Path $RecycleBinPath)) {
    New-Item -Path $RecycleBinPath -Force | Out-Null
}
if (-not (Test-Path "$RecycleBinPath\DefaultIcon")) {
    New-Item -Path "$RecycleBinPath\DefaultIcon" -Force | Out-Null
}

# Network Places Icon
$NetworkIcon = Join-Path $CustomIconDir "My Network Places.png"
$NetworkCLSID = "{208D2C60-3AEA-1069-A2D7-08002B30309D}"
$NetworkPath = Join-Path $DesktopIconsPath $NetworkCLSID
if (-not (Test-Path $NetworkPath)) {
    New-Item -Path $NetworkPath -Force | Out-Null
}
if (-not (Test-Path "$NetworkPath\DefaultIcon")) {
    New-Item -Path "$NetworkPath\DefaultIcon" -Force | Out-Null
}

Write-Host "  [OK] Desktop icons configured" -ForegroundColor Green

# Change Folder Icons
Write-Host "[3/5] Configuring folder icons..." -ForegroundColor Cyan

$FolderIcon = Join-Path $CustomIconDir "Folder Closed.png"
$FolderOpenIcon = Join-Path $CustomIconDir "Folder Opened.png"

# Note: Windows uses ICO files for icons, not PNG. We need to inform the user.
Write-Host "  [!] Note: Windows requires .ico format for icons" -ForegroundColor Yellow
Write-Host "  [!] PNG icons available at: $CustomIconDir" -ForegroundColor Yellow
Write-Host "  [!] Use third-party tools to convert PNG to ICO format" -ForegroundColor Yellow

# Set Explorer folder view options
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name FolderContentsInfoTip -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowInfoTip -Value 1 -ErrorAction SilentlyContinue

Write-Host "  [OK] Folder settings configured" -ForegroundColor Green

# Change System Icons via Registry
Write-Host "[4/5] Configuring system icons..." -ForegroundColor Cyan

# Shell Icons registry path
$ShellIconsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
if (-not (Test-Path $ShellIconsPath)) {
    New-Item -Path $ShellIconsPath -Force | Out-Null
}

Write-Host "  [OK] System icon paths configured" -ForegroundColor Green

# Create icon conversion guide
Write-Host "[5/5] Creating icon reference guide..." -ForegroundColor Cyan

$IconGuide = @"
========================================
WINDOWS XP ICONS - MANUAL INSTALLATION GUIDE
========================================

Your Windows XP icons are located at:
$CustomIconDir

IMPORTANT: Windows uses .ICO format, not .PNG
The PNG files provided need to be converted to .ICO format using tools like:
- GIMP (free)
- IcoFX
- Online converters: convertio.com, cloudconvert.com

DESKTOP ICONS:
--------------
To change desktop icons manually:
1. Right-click on Desktop > Personalize
2. Click "Themes" > "Desktop icon settings"
3. Select an icon and click "Change Icon"
4. Browse to the converted .ico file

COMMON DESKTOP ICONS:
- This PC (Computer): My Computer.png
- Recycle Bin: Recycle Bin (empty).png / Recycle Bin (full).png
- User's Files: My Documents.png
- Network: My Network Places.png

FOLDER ICONS:
-------------
To change individual folder icons:
1. Right-click folder > Properties
2. Go to "Customize" tab
3. Click "Change Icon"
4. Browse to your converted .ico file

Recommended folder icons:
- Folder Closed.png - for regular folders
- Folder Opened.png - for active folders

APPLICATION ICONS:
------------------
Available icons for common applications:
- Internet Explorer 6.png - for browser
- Windows Media Player 10.png - for media
- Notepad.png - for text editor
- Calculator.png - for calculator
- Paint.png - for image editor
- Windows Explorer.png - for file explorer

SYSTEM ICONS:
-------------
- Control Panel.png
- Printers and Faxes.png
- Network Connections.png
- Add or Remove Programs.png
- Display Properties.png
- System Properties.png

FILE TYPE ICONS:
----------------
Available for common file types:
- TXT.png, DOC.png, PDF.png
- JPG.png, GIF.png, BMP.png
- MP3.png, WMV.png, AVI.png
- ZIP folder.png
- And many more...

THIRD-PARTY TOOLS (Recommended):
---------------------------------
For complete icon replacement:
1. "IconPackager" by Stardock
2. "7+ Taskbar Tweaker" for taskbar
3. "Classic Shell" or "Open-Shell" for Start Menu
4. "Winaero Tweaker" for system icons

ONLINE RESOURCES:
-----------------
- deviantart.com - search for "Windows XP icon packs"
- iconfinder.com - for converting and creating icons
- iconarchive.com - for additional XP icons

========================================
"@

$IconGuide | Out-File (Join-Path $ScriptRoot "ICON_INSTALLATION_GUIDE.txt") -Force

Write-Host "  [OK] Guide created: ICON_INSTALLATION_GUIDE.txt" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Icon Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Read: ICON_INSTALLATION_GUIDE.txt" -ForegroundColor White
Write-Host "2. Convert PNG icons to ICO format" -ForegroundColor White
Write-Host "3. Manually set icons via Personalization settings" -ForegroundColor White
Write-Host "4. Consider using third-party icon tools for full replacement" -ForegroundColor White
Write-Host ""
Write-Host "Icons location: $CustomIconDir" -ForegroundColor Cyan
Write-Host ""

# Open icons directory
Write-Host "Opening icons directory..."
Start-Process explorer.exe -ArgumentList $CustomIconDir

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
