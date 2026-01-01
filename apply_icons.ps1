#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Apply Windows XP Icons to System
.DESCRIPTION
    This script applies Windows XP icons to common system locations and creates .ico files from PNG images
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows XP Icon Applier  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    pause
    exit 1
}

$IconsDir = Join-Path $ScriptRoot "Icons"
if (-not (Test-Path $IconsDir)) {
    Write-Host "ERROR: Icons directory not found!" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[*] Applying Windows XP Icons..." -ForegroundColor Yellow
Write-Host ""

# Function to convert PNG to ICO (simplified - using built-in .NET)
function Convert-PNGtoICO {
    param(
        [string]$PNGPath,
        [string]$ICOPath
    )
    
    try {
        Add-Type -AssemblyName System.Drawing
        $img = [System.Drawing.Image]::FromFile($PNGPath)
        
        # Create icon from image (resize to 32x32 for compatibility)
        $bitmap = New-Object System.Drawing.Bitmap($img, 32, 32)
        $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
        
        # Save as ICO
        $fs = [System.IO.FileStream]::new($ICOPath, [System.IO.FileMode]::Create)
        $icon.Save($fs)
        $fs.Close()
        
        $img.Dispose()
        $bitmap.Dispose()
        return $true
    } catch {
        return $false
    }
}

# Check if Icons_ICO directory exists (from convert_all_icons.ps1)
$ICODir = Join-Path $ScriptRoot "Icons_ICO"
if (-not (Test-Path $ICODir)) {
    Write-Host "[!] Icons_ICO folder not found!" -ForegroundColor Yellow
    Write-Host "[*] Running icon converter first..." -ForegroundColor Cyan
    $ConverterScript = Join-Path $ScriptRoot "convert_all_icons.ps1"
    if (Test-Path $ConverterScript) {
        & $ConverterScript
    } else {
        Write-Host "[ERROR] convert_all_icons.ps1 not found!" -ForegroundColor Red
        Write-Host "Please run convert_all_icons.ps1 first to create ICO files" -ForegroundColor Yellow
        pause
        exit 1
    }
}

Write-Host "[1/4] Using pre-converted ICO files..." -ForegroundColor Cyan
$ICOFiles = Get-ChildItem -Path $ICODir -Filter "*.ico" -File
Write-Host "  [+] Found $($ICOFiles.Count) ICO files ready to use" -ForegroundColor Green
Write-Host ""

# Apply Desktop Icons
Write-Host "[2/4] Applying desktop icons..." -ForegroundColor Cyan

# My Computer
$ComputerIcon = Join-Path $ICODir "My Computer.ico"
if (Test-Path $ComputerIcon) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "(Default)" -Value $ComputerIcon
    Write-Host "  [+] My Computer icon applied" -ForegroundColor Green
}

# Recycle Bin
$RecycleBinEmpty = Join-Path $ICODir "Recycle Bin (empty).ico"
$RecycleBinFull = Join-Path $ICODir "Recycle Bin (full).ico"
if ((Test-Path $RecycleBinEmpty) -and (Test-Path $RecycleBinFull)) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "Empty" -Value $RecycleBinEmpty
    Set-ItemProperty -Path $path -Name "Full" -Value $RecycleBinFull
    Write-Host "  [+] Recycle Bin icons applied" -ForegroundColor Green
}

# My Documents
$DocumentsIcon = Join-Path $ICODir "My Documents.ico"
if (Test-Path $DocumentsIcon) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\DefaultIcon"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "(Default)" -Value $DocumentsIcon
    Write-Host "  [+] My Documents icon applied" -ForegroundColor Green
}

# Network
$NetworkIcon = Join-Path $ICODir "My Network Places.ico"
if (Test-Path $NetworkIcon) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\DefaultIcon"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "(Default)" -Value $NetworkIcon
    Write-Host "  [+] Network icon applied" -ForegroundColor Green
}

Write-Host "  [OK] Desktop icons configured" -ForegroundColor Green
Write-Host ""

# Apply Folder Icons
Write-Host "[3/6] Applying folder icons..." -ForegroundColor Cyan
$FolderIcon = Join-Path $ICODir "Folder Closed.ico"
if (Test-Path $FolderIcon) {
    # Shell Icons
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "3" -Value $FolderIcon  # Closed folder
    Set-ItemProperty -Path $path -Name "4" -Value $FolderIcon  # Open folder
    Write-Host "  [+] Folder icons applied" -ForegroundColor Green
} else {
    Write-Host "  [!] Folder icon not found" -ForegroundColor Yellow
}

Write-Host ""

# Backup original icon registry settings before changing
Write-Host "[4/6] Backing up current icon settings..." -ForegroundColor Cyan
$IconBackupDir = Join-Path $ScriptRoot "Backup_Win11"
if (-not (Test-Path $IconBackupDir)) {
    New-Item -ItemType Directory -Path $IconBackupDir -Force | Out-Null
}

$IconBackup = @{}

# Backup Shell Icons
try {
    $shellIconsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    if (Test-Path $shellIconsPath) {
        $props = Get-ItemProperty -Path $shellIconsPath
        $props.PSObject.Properties | Where-Object { $_.Name -match '^\d+$' } | ForEach-Object {
            $IconBackup["ShellIcon_$($_.Name)"] = $_.Value
        }
    }
} catch {}

# Backup Desktop icon locations
$desktopIconPaths = @{
    "MyComputer" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon"
    "RecycleBin" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
    "MyDocuments" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\DefaultIcon"
    "Network" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\DefaultIcon"
}

foreach ($key in $desktopIconPaths.Keys) {
    $path = $desktopIconPaths[$key]
    if (Test-Path $path) {
        try {
            $default = (Get-ItemProperty -Path $path -Name "(Default)" -ErrorAction SilentlyContinue).'(Default)'
            if ($default) { $IconBackup[$key] = $default }
        } catch {}
    }
}

$IconBackup | ConvertTo-Json | Out-File (Join-Path $IconBackupDir "icon_backup.json") -Force
Write-Host "  [+] Icon settings backed up" -ForegroundColor Green
Write-Host ""

# Apply System Application Icons
Write-Host "[5/6] Applying system application icons..." -ForegroundColor Cyan

# Windows Explorer
$ExplorerIcon = Join-Path $ICODir "Explorer.ico"
if (Test-Path $ExplorerIcon) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "2" -Value $ExplorerIcon  # My Computer in Explorer
    Write-Host "  [+] Windows Explorer icon applied" -ForegroundColor Green
}

# Control Panel
$ControlPanelIcon = Join-Path $ICODir "Control Panel.ico"
if (Test-Path $ControlPanelIcon) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    Set-ItemProperty -Path $path -Name "34" -Value $ControlPanelIcon
    Write-Host "  [+] Control Panel icon applied" -ForegroundColor Green
}

# Command Prompt (cmd.exe)
$CmdIcon = Join-Path $ICODir "Command Prompt.ico"
if (Test-Path $CmdIcon) {
    # Note: This requires modifying file associations - more complex
    Write-Host "  [!] CMD icon available at: $CmdIcon" -ForegroundColor Yellow
}

# Internet Explorer / Edge
$IEIcon = Join-Path $ICODir "Internet Explorer 6.ico"
if (Test-Path $IEIcon) {
    # Note: Edge icon is protected by Windows - cannot be easily changed
    Write-Host "  [!] IE icon available at: $IEIcon" -ForegroundColor Yellow
    Write-Host "      (Edge icon is system-protected)" -ForegroundColor Yellow
}

# Notepad
$NotepadIcon = Join-Path $ICODir "Notepad.ico"
if (Test-Path $NotepadIcon) {
    Write-Host "  [!] Notepad icon available at: $NotepadIcon" -ForegroundColor Yellow
}

Write-Host "  [OK] System icons configured (some require manual setup)" -ForegroundColor Green
Write-Host ""

# Refresh icon cache
Write-Host "[6/6] Refreshing icon cache..." -ForegroundColor Cyan
$IconCache = Join-Path $env:LOCALAPPDATA "IconCache.db"
if (Test-Path $IconCache) {
    Remove-Item -Path $IconCache -Force -ErrorAction SilentlyContinue
}

# Use ie4uinit to refresh
ie4uinit.exe -show 2>$null

Write-Host "  [OK] Icon cache refreshed" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Icons Applied Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "- Icons saved to: $ICODir" -ForegroundColor White
Write-Host "- Desktop icons have been configured" -ForegroundColor White
Write-Host "- RESTART or LOGOUT for all icons to take effect" -ForegroundColor White
Write-Host "- Some icons may require Explorer restart" -ForegroundColor White
Write-Host ""

# Restart Explorer
Write-Host "[*] Restarting Explorer to apply icons..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
