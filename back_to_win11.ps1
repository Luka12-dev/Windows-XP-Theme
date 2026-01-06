#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Restore Windows 11 Default Theme
.DESCRIPTION
    This script restores the original Windows 11 theme by reverting all changes made by run.ps1
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Restore Windows 11 Default Theme  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on the script and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Check if backup exists
$BackupDir = Join-Path $ScriptRoot "Backup_Win11"
if (-not (Test-Path $BackupDir)) {
    Write-Host "ERROR: Backup directory not found!" -ForegroundColor Red
    Write-Host "Cannot restore without backup. The Windows XP theme may not have been applied yet." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[*] Restoring Windows 11 default settings from backup..." -ForegroundColor Yellow
Write-Host ""

# Restore wallpaper
Write-Host "[1/6] Restoring original wallpaper..." -ForegroundColor Cyan
$WallpaperBackup = Join-Path $BackupDir "original_wallpaper.txt"
if (Test-Path $WallpaperBackup) {
    $OriginalWallpaper = Get-Content $WallpaperBackup
    if ($OriginalWallpaper -and (Test-Path $OriginalWallpaper)) {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $OriginalWallpaper
        
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $OriginalWallpaper, 0x0001 -bor 0x0002)
        Write-Host "  [OK] Wallpaper restored" -ForegroundColor Green
    } else {
        Write-Host "  [!] Using Windows 11 default wallpaper" -ForegroundColor Yellow
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value ""
    }
} else {
    Write-Host "  [!] No wallpaper backup found, using default" -ForegroundColor Yellow
}

# Restore cursors
Write-Host "[2/6] Restoring original cursors..." -ForegroundColor Cyan
$CursorBackupFile = Join-Path $BackupDir "cursor_backup.json"
if (Test-Path $CursorBackupFile) {
    $CursorBackup = Get-Content $CursorBackupFile | ConvertFrom-Json
    $CursorBackup.PSObject.Properties | ForEach-Object {
        Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name $_.Name -Value $_.Value -ErrorAction SilentlyContinue
    }
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(Default)" -Value "Windows Default" -ErrorAction SilentlyContinue
    
    # Force cursor refresh using SystemParametersInfo
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CursorRestorer {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
}
"@
    [CursorRestorer]::SystemParametersInfo(0x0057, 0, 0, 0x0001 -bor 0x0002) | Out-Null
    Write-Host "  [OK] Cursors restored (logout/restart recommended for full effect)" -ForegroundColor Green
} else {
    Write-Host "  [!] No cursor backup found, resetting to Windows defaults" -ForegroundColor Yellow
    # Reset to default Windows cursors
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(Default)" -Value "Windows Default" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Arrow" -Value "" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Hand" -Value "" -ErrorAction SilentlyContinue
    
    # Force cursor refresh
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CursorRestorer2 {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
}
"@
    [CursorRestorer2]::SystemParametersInfo(0x0057, 0, 0, 0x0001 -bor 0x0002) | Out-Null
}

# Restore sounds
Write-Host "[3/6] Restoring original sound scheme..." -ForegroundColor Cyan
$SoundBackupFile = Join-Path $BackupDir "sound_backup.json"
if (Test-Path $SoundBackupFile) {
    $SoundBackup = Get-Content $SoundBackupFile | ConvertFrom-Json
    $SoundBackup.PSObject.Properties | ForEach-Object {
        $regPath = "HKCU:\AppEvents\Schemes\Apps\.Default\$($_.Name)\.Current"
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name "(Default)" -Value $_.Value -ErrorAction SilentlyContinue
        }
    }
    Write-Host "  [OK] Sound scheme restored" -ForegroundColor Green
} else {
    Write-Host "  [!] No sound backup found" -ForegroundColor Yellow
}

# Restore Windows 11 colors
Write-Host "[4/6] Restoring Windows 11 color scheme..." -ForegroundColor Cyan

$Win11Colors = @{
    "ActiveBorder" = "180 180 180"
    "ActiveTitle" = "0 120 215"
    "AppWorkSpace" = "171 171 171"
    "Background" = "0 0 0"
    "ButtonFace" = "240 240 240"
    "ButtonHilight" = "255 255 255"
    "ButtonLight" = "227 227 227"
    "ButtonShadow" = "160 160 160"
    "ButtonText" = "0 0 0"
    "GradientActiveTitle" = "0 120 215"
    "GradientInactiveTitle" = "191 205 219"
    "GrayText" = "109 109 109"
    "Hilight" = "0 120 215"
    "HilightText" = "255 255 255"
    "InactiveBorder" = "244 247 252"
    "InactiveTitle" = "191 205 219"
    "InactiveTitleText" = "0 0 0"
    "InfoText" = "0 0 0"
    "InfoWindow" = "255 255 255"
    "Menu" = "240 240 240"
    "MenuText" = "0 0 0"
    "Scrollbar" = "200 200 200"
    "TitleText" = "255 255 255"
    "Window" = "255 255 255"
    "WindowFrame" = "100 100 100"
    "WindowText" = "0 0 0"
}

foreach ($colorName in $Win11Colors.Keys) {
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name $colorName -Value $Win11Colors[$colorName] -ErrorAction SilentlyContinue
}

Write-Host "  [OK] Color scheme restored" -ForegroundColor Green

# Restore Windows 11 visual features
Write-Host "[5/6] Restoring Windows 11 visual features..." -ForegroundColor Cyan

# Enable transparency
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name EnableTransparency -Value 1 -ErrorAction SilentlyContinue

# Restore visual effects
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 3 -ErrorAction SilentlyContinue

# Restore modern context menu
Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue

# Restore DWM settings
$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
Set-ItemProperty -Path $DWMPath -Name EnableWindowColorization -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $DWMPath -Name ColorizationColor -Value 0xC40078D7 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $DWMPath -Name ColorizationAfterglow -Value 0xC40078D7 -ErrorAction SilentlyContinue

# Restore taskbar settings (FIX AUTO-HIDE BUG - COMPLETE RESTORATION)
$TaskbarBackupFile = Join-Path $BackupDir "taskbar_backup.json"
if (Test-Path $TaskbarBackupFile) {
    try {
        $TaskbarBackup = Get-Content $TaskbarBackupFile | ConvertFrom-Json
        
        # Restore StuckRects3 settings (this controls auto-hide)
        if ($TaskbarBackup.StuckRects3_Settings) {
            $bytes = [Convert]::FromBase64String($TaskbarBackup.StuckRects3_Settings)
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -Value ([byte[]]$bytes) -ErrorAction SilentlyContinue
        }
        
        # Restore Advanced settings
        $TaskbarBackup.PSObject.Properties | ForEach-Object {
            if ($_.Name -ne "StuckRects3_Settings") {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name $_.Name -Value $_.Value -ErrorAction SilentlyContinue
            }
        }
        
        Write-Host "  [+] Taskbar settings restored (auto-hide fixed)" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Could not restore some taskbar settings" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [!] No taskbar backup found, using defaults" -ForegroundColor Yellow
}

Write-Host "  [OK] Visual features restored" -ForegroundColor Green

# Restore Icons
Write-Host ""
Write-Host "[*] Restoring original icons..." -ForegroundColor Cyan
$IconBackupFile = Join-Path $BackupDir "icon_backup.json"
if (Test-Path $IconBackupFile) {
    try {
        $IconBackup = Get-Content $IconBackupFile | ConvertFrom-Json
        
        # Restore Shell Icons
        $shellIconsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
        if (Test-Path $shellIconsPath) {
            $IconBackup.PSObject.Properties | Where-Object { $_.Name -like "ShellIcon_*" } | ForEach-Object {
                $iconNumber = $_.Name -replace "ShellIcon_", ""
                Set-ItemProperty -Path $shellIconsPath -Name $iconNumber -Value $_.Value -ErrorAction SilentlyContinue
            }
        }
        
        # Restore Desktop Icons
        $desktopIconPaths = @{
            "MyComputer" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon"
            "RecycleBin" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
            "MyDocuments" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\DefaultIcon"
            "Network" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\DefaultIcon"
        }
        
        foreach ($key in $desktopIconPaths.Keys) {
            if ($IconBackup.$key) {
                $path = $desktopIconPaths[$key]
                if (Test-Path $path) {
                    Set-ItemProperty -Path $path -Name "(Default)" -Value $IconBackup.$key -ErrorAction SilentlyContinue
                }
            }
        }
        
        # Clear icon cache
        $IconCache = Join-Path $env:LOCALAPPDATA "IconCache.db"
        if (Test-Path $IconCache) {
            Remove-Item -Path $IconCache -Force -ErrorAction SilentlyContinue
        }
        
        # Refresh icons
        ie4uinit.exe -show 2>$null
        
        Write-Host "  [+] Original icons restored" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Could not restore some icon settings" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [!] No icon backup found" -ForegroundColor Yellow
}

# Import backed up registry files
Write-Host "[6/6] Importing registry backups..." -ForegroundColor Cyan
$BackupFiles = Get-ChildItem -Path $BackupDir -Filter "*.reg" -ErrorAction SilentlyContinue
if ($BackupFiles) {
    foreach ($file in $BackupFiles) {
        $null = Start-Process -FilePath "reg.exe" -ArgumentList "import `"$($file.FullName)`"" -Wait -WindowStyle Hidden -PassThru
    }
    Write-Host "  [OK] Registry settings restored" -ForegroundColor Green
} else {
    Write-Host "  [!] No registry backup files found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Windows 11 Theme Restored Successfully! " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "NOTES:" -ForegroundColor Yellow
Write-Host "- A RESTART is recommended for complete restoration" -ForegroundColor White
Write-Host "- Backup files are preserved in: $BackupDir" -ForegroundColor White
Write-Host ""

# Restore Windows 11 Boot Screen (HackBGRT)
Write-Host ""
Write-Host "[*] Restoring Windows 11 boot screen..." -ForegroundColor Cyan

# Check if HackBGRT is installed
$HackBGRTPaths = @(
    "C:\HackBGRT",
    "${env:SystemDrive}\HackBGRT",
    "${env:ProgramFiles}\HackBGRT",
    "${env:ProgramFiles(x86)}\HackBGRT"
)

$HackBGRTFound = $false
$HackBGRTPath = $null

foreach ($path in $HackBGRTPaths) {
    if (Test-Path $path) {
        $HackBGRTFound = $true
        $HackBGRTPath = $path
        break
    }
}

if ($HackBGRTFound) {
    Write-Host "  [+] HackBGRT installation found at: $HackBGRTPath" -ForegroundColor Green
    
    try {
        # Look for HackBGRT config file
        $configFile = Join-Path $HackBGRTPath "config.txt"
        $splashFile = Join-Path $HackBGRTPath "splash.bmp"
        
        # Check if Windows 11 default splash exists in backup
        $backupSplash = Join-Path $BackupDir "windows11_splash.bmp"
        
        if (Test-Path $backupSplash) {
            # Restore original Windows 11 splash
            Copy-Item -Path $backupSplash -Destination $splashFile -Force -ErrorAction Stop
            Write-Host "  [+] Windows 11 boot screen restored from backup" -ForegroundColor Green
        } else {
            # Remove custom splash to use Windows default
            if (Test-Path $splashFile) {
                Remove-Item -Path $splashFile -Force -ErrorAction SilentlyContinue
                Write-Host "  [+] Custom boot screen removed (will use Windows default)" -ForegroundColor Green
            }
            
            # Reset HackBGRT config to defaults
            if (Test-Path $configFile) {
                $defaultConfig = @"
# HackBGRT Configuration
# Restored to Windows 11 defaults

resolution=0x0
boot_menu=1
"@
                $defaultConfig | Out-File -FilePath $configFile -Encoding ASCII -Force
                Write-Host "  [+] HackBGRT config reset to defaults" -ForegroundColor Green
            }
        }
        
        Write-Host "  [OK] Boot screen restoration complete" -ForegroundColor Green
        Write-Host "      Reboot to see Windows 11 default boot screen" -ForegroundColor Cyan
        
    } catch {
        Write-Host "  [!] Could not restore boot screen: $_" -ForegroundColor Yellow
        Write-Host "      You may need to manually reconfigure HackBGRT" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "  [!] HackBGRT not found (boot screen unchanged)" -ForegroundColor Yellow
    Write-Host "      If you modified boot screen, restore it manually" -ForegroundColor Yellow
}

# Stop OpenShell if running
Write-Host ""
Write-Host "[*] Stopping OpenShell (Classic Start Menu)..." -ForegroundColor Cyan

# Find ALL OpenShell processes
$OpenShellProcessNames = @("StartMenu", "ClassicStartMenu", "OpenShellMenu", "StartMenuHost")
$foundProcesses = @()

foreach ($processName in $OpenShellProcessNames) {
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($processes) {
        $foundProcesses += $processes
        Write-Host "  [*] Found $processName (PID: $($processes.Id -join ', '))" -ForegroundColor Yellow
    }
}

if ($foundProcesses.Count -gt 0) {
    Write-Host "  [*] Attempting to close OpenShell gracefully..." -ForegroundColor Cyan
    
    # Method 1: Try CloseMainWindow (graceful close)
    foreach ($proc in $foundProcesses) {
        try {
            if ($proc.CloseMainWindow()) {
                Write-Host "  [*] Sent close signal to PID $($proc.Id)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  [!] Could not send close signal to PID $($proc.Id)" -ForegroundColor Yellow
        }
    }
    
    # Wait for graceful close
    Start-Sleep -Seconds 2
    
    # Method 2: Force terminate any remaining processes
    $remainingProcesses = @()
    foreach ($processName in $OpenShellProcessNames) {
        $remaining = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($remaining) {
            $remainingProcesses += $remaining
        }
    }
    
    if ($remainingProcesses.Count -gt 0) {
        Write-Host "  [*] Force closing remaining processes..." -ForegroundColor Yellow
        
        foreach ($proc in $remainingProcesses) {
            try {
                Write-Host "  [*] Force stopping PID $($proc.Id)..." -ForegroundColor Yellow
                Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            } catch {
                Write-Host "  [!] Error stopping PID $($proc.Id), trying taskkill..." -ForegroundColor Red
                taskkill /F /PID $proc.Id 2>$null | Out-Null
            }
        }
        
        Start-Sleep -Seconds 1
    }
    
    # Method 3: Final verification and nuclear option
    $stillRunning = @()
    foreach ($processName in $OpenShellProcessNames) {
        $check = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($check) {
            $stillRunning += $check
        }
    }
    
    if ($stillRunning.Count -gt 0) {
        Write-Host "  [!] Some processes still running, using taskkill /F..." -ForegroundColor Red
        foreach ($proc in $stillRunning) {
            taskkill /F /PID $proc.Id 2>$null | Out-Null
        }
        Start-Sleep -Seconds 1
    }
    
    # Final check
    $finalCheck = @()
    foreach ($processName in $OpenShellProcessNames) {
        $check = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($check) {
            $finalCheck += $check
        }
    }
    
    if ($finalCheck.Count -eq 0) {
        Write-Host "  [+] OpenShell stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [!] OpenShell may still be running (PIDs: $($finalCheck.Id -join ', '))" -ForegroundColor Red
        Write-Host "      You may need to manually end these processes" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [!] OpenShell was not running" -ForegroundColor Yellow
}

# Stop RetroBar if running
Write-Host ""
Write-Host "[*] Stopping RetroBar..." -ForegroundColor Cyan
$RetroBarProcesses = Get-Process -Name "RetroBar" -ErrorAction SilentlyContinue
if ($RetroBarProcesses) {
    $RetroBarProcesses | Stop-Process -Force
    Write-Host "  [OK] RetroBar stopped" -ForegroundColor Green
} else {
    Write-Host "  [!] RetroBar was not running" -ForegroundColor Yellow
}

# Restart Explorer
Write-Host "[*] Restarting Explorer to apply changes..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
