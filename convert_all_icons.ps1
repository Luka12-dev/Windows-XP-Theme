#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Convert ALL PNG Icons to ICO Format
.DESCRIPTION
    Converts all 500+ PNG icons from Icons folder to ICO format for Windows compatibility
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Mass PNG to ICO Converter  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some operations may fail without admin rights" -ForegroundColor Yellow
    Write-Host ""
}

$IconsDir = Join-Path $ScriptRoot "Icons"
if (-not (Test-Path $IconsDir)) {
    Write-Host "ERROR: Icons directory not found!" -ForegroundColor Red
    pause
    exit 1
}

# Create output directory for ICO files
$ICODir = Join-Path $ScriptRoot "Icons_ICO"
if (-not (Test-Path $ICODir)) {
    New-Item -ItemType Directory -Path $ICODir -Force | Out-Null
    Write-Host "[+] Created output directory: Icons_ICO" -ForegroundColor Green
} else {
    Write-Host "[*] Using existing directory: Icons_ICO" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[*] Loading System.Drawing assembly..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Drawing

# Function to convert PNG to ICO with multiple sizes
function Convert-PNGtoICO {
    param(
        [string]$PNGPath,
        [string]$ICOPath
    )
    
    try {
        # Load the PNG image
        $img = [System.Drawing.Image]::FromFile($PNGPath)
        
        # Determine best size (if image is small, use its size, otherwise 32x32)
        $size = 32
        if ($img.Width -lt 32 -or $img.Height -lt 32) {
            $size = [Math]::Min($img.Width, $img.Height)
        }
        
        # Create bitmap with appropriate size
        $bitmap = New-Object System.Drawing.Bitmap($img, $size, $size)
        
        # Convert to icon
        $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
        
        # Save as ICO file
        $fs = [System.IO.FileStream]::new($ICOPath, [System.IO.FileMode]::Create)
        $icon.Save($fs)
        $fs.Close()
        
        # Cleanup
        $img.Dispose()
        $bitmap.Dispose()
        
        return $true
    } catch {
        return $false
    }
}

# Get all PNG files
Write-Host "[*] Scanning for PNG files..." -ForegroundColor Yellow
$PNGFiles = Get-ChildItem -Path $IconsDir -Filter "*.png" -File
$TotalFiles = $PNGFiles.Count

Write-Host "[+] Found $TotalFiles PNG files to convert" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Conversion Process..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$SuccessCount = 0
$FailCount = 0
$CurrentFile = 0

foreach ($pngFile in $PNGFiles) {
    $CurrentFile++
    $PercentComplete = [math]::Round(($CurrentFile / $TotalFiles) * 100)
    
    # Create ICO filename (keep same name, change extension)
    $icoFileName = [System.IO.Path]::GetFileNameWithoutExtension($pngFile.Name) + ".ico"
    $icoPath = Join-Path $ICODir $icoFileName
    
    # Show progress
    Write-Host "[$CurrentFile/$TotalFiles] ($PercentComplete%) Converting: $($pngFile.Name)" -NoNewline -ForegroundColor Cyan
    
    # Convert
    if (Convert-PNGtoICO -PNGPath $pngFile.FullName -ICOPath $icoPath) {
        Write-Host " [OK]" -ForegroundColor Green
        $SuccessCount++
    } else {
        Write-Host " [FAIL]" -ForegroundColor Red
        $FailCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Conversion Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "RESULTS:" -ForegroundColor Cyan
Write-Host "  Total files:      $TotalFiles" -ForegroundColor White
Write-Host "  Successful:       $SuccessCount" -ForegroundColor Green
Write-Host "  Failed:           $FailCount" -ForegroundColor $(if ($FailCount -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "OUTPUT LOCATION:" -ForegroundColor Cyan
Write-Host "  $ICODir" -ForegroundColor White
Write-Host ""

# Create a mapping file for icon names
Write-Host "[*] Creating icon mapping file..." -ForegroundColor Yellow
$MappingContent = @"
========================================
WINDOWS XP ICONS - ICO FORMAT
========================================

This directory contains all Windows XP icons converted to ICO format.
Total icons: $SuccessCount

USAGE:
------
These icons can be used to customize Windows 11:
1. Right-click on any folder/shortcut
2. Select Properties > Customize
3. Click "Change Icon"
4. Browse to this folder and select an icon

DESKTOP ICONS:
--------------
My Computer.ico
Recycle Bin (empty).ico
Recycle Bin (full).ico
My Documents.ico
My Network Places.ico

COMMON ICONS:
-------------
Folder Closed.ico
Folder Opened.ico
Control Panel.ico
Internet Explorer 6.ico
Windows Media Player 10.ico
Notepad.ico
Calculator.ico
Paint.ico

And 500+ more icons!

========================================
"@

$MappingContent | Out-File (Join-Path $ICODir "README.txt") -Force
Write-Host "[+] Mapping file created: Icons_ICO\README.txt" -ForegroundColor Green
Write-Host ""

# Open the output folder
Write-Host "[*] Opening output folder..." -ForegroundColor Yellow
Start-Process explorer.exe -ArgumentList $ICODir

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Done! All Icons Converted!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. All icons are in: Icons_ICO folder" -ForegroundColor White
Write-Host "  2. Run 'apply_icons.ps1' to apply them automatically" -ForegroundColor White
Write-Host "  3. Or manually use icons from Icons_ICO folder" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
