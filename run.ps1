#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Transform Windows 11 into Windows XP Theme
.DESCRIPTION
    This script applies Windows XP visual theme including icons, wallpaper, cursor, sounds, colors, and boot screen.
    Creates backup of original settings for restoration.
#>

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows XP Theme Installer for Win11  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on the script and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Create backup directory
$BackupDir = Join-Path $ScriptRoot "Backup_Win11"
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Host "[+] Created backup directory: $BackupDir" -ForegroundColor Green
}

# Backup registry settings
Write-Host "[*] Backing up current Windows 11 settings..." -ForegroundColor Yellow

$BackupFile = Join-Path $BackupDir "registry_backup.reg"
$RegistryPaths = @(
    "HKEY_CURRENT_USER\Control Panel\Colors",
    "HKEY_CURRENT_USER\Control Panel\Desktop",
    "HKEY_CURRENT_USER\Control Panel\Cursors",
    "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes",
    "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
    "HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM"
)

foreach ($path in $RegistryPaths) {
    reg export $path (Join-Path $BackupDir "backup_$(($path -replace '\\','_') -replace ':','').reg") /y 2>$null
}

# Backup current wallpaper
$CurrentWallpaper = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper).Wallpaper
if ($CurrentWallpaper) {
    $CurrentWallpaper | Out-File (Join-Path $BackupDir "original_wallpaper.txt") -Force
}

# Backup current cursor scheme
$CursorBackup = @{}
$CursorKeys = @("Arrow", "Help", "AppStarting", "Wait", "Crosshair", "IBeam", "NWPen", "No", "SizeNS", "SizeWE", "SizeNWSE", "SizeNESW", "SizeAll", "UpArrow", "Hand")
foreach ($key in $CursorKeys) {
    try {
        $value = (Get-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name $key -ErrorAction SilentlyContinue).$key
        if ($value) { $CursorBackup[$key] = $value }
    } catch {}
}
$CursorBackup | ConvertTo-Json | Out-File (Join-Path $BackupDir "cursor_backup.json") -Force

# Backup taskbar settings (to fix auto-hide bug)
Write-Host "[*] Backing up taskbar settings..." -ForegroundColor Yellow
$TaskbarBackup = @{}
try {
    # Backup taskbar auto-hide settings (StuckRects3)
    $settings = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -ErrorAction SilentlyContinue
    if ($settings) {
        $TaskbarBackup["StuckRects3_Settings"] = [Convert]::ToBase64String($settings.Settings)
    }
    
    # Backup Advanced taskbar settings
    $advancedKeys = @("TaskbarAl", "TaskbarSi", "TaskbarMn", "TaskbarDa", "TaskbarGlomLevel", "MMTaskbarEnabled", "TaskbarSd")
    foreach ($key in $advancedKeys) {
        try {
            $value = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name $key -ErrorAction SilentlyContinue).$key
            if ($null -ne $value) { $TaskbarBackup[$key] = $value }
        } catch {}
    }
    
    $TaskbarBackup | ConvertTo-Json | Out-File (Join-Path $BackupDir "taskbar_backup.json") -Force
} catch {
    Write-Host "  [!] Could not backup all taskbar settings" -ForegroundColor Yellow
}

# DISABLE AUTO-HIDE for taskbar (keep it always visible)
Write-Host "[*] Ensuring taskbar is always visible (disabling auto-hide)..." -ForegroundColor Yellow
try {
    # Method 1: StuckRects3 binary settings
    $StuckRectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    $currentSettings = Get-ItemProperty -Path $StuckRectsPath -Name "Settings" -ErrorAction SilentlyContinue
    
    if ($currentSettings) {
        $bytes = $currentSettings.Settings
        
        # Byte 8 controls auto-hide (bit 0x01)
        # Byte 10 also affects visibility
        if ($bytes.Length -gt 10) {
            $bytes[8] = $bytes[8] -band 0xFE  # Clear auto-hide bit
            $bytes[10] = $bytes[10] -band 0xFE # Ensure taskbar shows
            Set-ItemProperty -Path $StuckRectsPath -Name "Settings" -Value ([byte[]]$bytes)
        }
    }
    
    # Method 2: Registry keys for taskbar behavior
    $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # Disable taskbar auto-hide in settings
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAutoHideInDesktopMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAutoHideInTabletMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    
    Write-Host "  [+] Taskbar auto-hide disabled" -ForegroundColor Green
} catch {
    Write-Host "  [!] Could not modify some taskbar settings" -ForegroundColor Yellow
}

# Backup current sound scheme
$SoundBackup = @{}
$SoundEvents = @("SystemStart", "SystemExit", "SystemExclamation", "SystemAsterisk", "SystemHand", ".Default")
foreach ($event in $SoundEvents) {
    try {
        $value = (Get-ItemProperty -Path "HKCU:\AppEvents\Schemes\Apps\.Default\$event\.Current" -Name "(Default)" -ErrorAction SilentlyContinue).'(Default)'
        if ($value) { $SoundBackup[$event] = $value }
    } catch {}
}
$SoundBackup | ConvertTo-Json | Out-File (Join-Path $BackupDir "sound_backup.json") -Force

Write-Host "[+] Backup completed successfully!" -ForegroundColor Green
Write-Host ""

# ========================================
# APPLY WINDOWS XP THEME
# ========================================

Write-Host "[*] Applying Windows XP Theme..." -ForegroundColor Yellow
Write-Host ""

# 1. WALLPAPER
Write-Host "[1/7] Setting Windows XP Wallpaper..." -ForegroundColor Cyan
$XPWallpaper = Join-Path $ScriptRoot "Wallpaper\Windows_XP_Wallpaper.png"
if (Test-Path $XPWallpaper) {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $XPWallpaper
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value "2"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value "0"
    
    # Force wallpaper refresh
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(0x0014, 0, $XPWallpaper, 0x0001 -bor 0x0002)
    Write-Host "  [OK] Wallpaper applied" -ForegroundColor Green
} else {
    Write-Host "  [!] Wallpaper not found" -ForegroundColor Red
}

# 2. CURSOR
Write-Host "[2/7] Setting Windows XP Cursors..." -ForegroundColor Cyan
$XPCursor = Join-Path $ScriptRoot "cursor\cursor.cur"
if (Test-Path $XPCursor) {
    $CursorPath = $XPCursor
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Arrow -Value $CursorPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Hand -Value $CursorPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(Default)" -Value "Windows XP"
    
    # Refresh cursor using SystemParametersInfo
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CursorHelper {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
}
"@
    [CursorHelper]::SystemParametersInfo(0x0057, 0, 0, 0x0001 -bor 0x0002) | Out-Null
    Write-Host "  [OK] Cursors applied (restart may be needed for full effect)" -ForegroundColor Green
} else {
    Write-Host "  [!] Cursor file not found" -ForegroundColor Red
}

# 3. SOUNDS
Write-Host "[3/7] Setting Windows XP Sounds..." -ForegroundColor Cyan
$SoundMappings = @{
    "SystemStart" = "WindowsXP_Startup.mp3"
    "SystemExit" = "windows-xp-log-out.mp3"
    "SystemExclamation" = "WindowsXP_error.mp3"
    "SystemHand" = "WindowsXP_error.mp3"
    ".Default" = "windows_xp_404_error.mp3"
}

foreach ($event in $SoundMappings.Keys) {
    $soundFile = Join-Path $ScriptRoot "Sounds\$($SoundMappings[$event])"
    if (Test-Path $soundFile) {
        $regPath = "HKCU:\AppEvents\Schemes\Apps\.Default\$event\.Current"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "(Default)" -Value $soundFile
    }
}
Write-Host "  [OK] Sound scheme applied" -ForegroundColor Green

# 4. WINDOWS XP COLORS
Write-Host "[4/7] Setting Windows XP Color Scheme..." -ForegroundColor Cyan

# Classic Windows XP Blue theme colors
$XPColors = @{
    "ActiveBorder" = "212 208 200"
    "ActiveTitle" = "0 84 227"
    "AppWorkSpace" = "128 128 128"
    "Background" = "0 78 152"
    "ButtonFace" = "236 233 216"
    "ButtonHilight" = "255 255 255"
    "ButtonLight" = "241 239 226"
    "ButtonShadow" = "172 168 153"
    "ButtonText" = "0 0 0"
    "GradientActiveTitle" = "61 149 255"
    "GradientInactiveTitle" = "157 185 235"
    "GrayText" = "172 168 153"
    "Hilight" = "49 106 197"
    "HilightText" = "255 255 255"
    "InactiveBorder" = "212 208 200"
    "InactiveTitle" = "122 150 223"
    "InactiveTitleText" = "216 228 248"
    "InfoText" = "0 0 0"
    "InfoWindow" = "255 255 225"
    "Menu" = "255 255 255"
    "MenuText" = "0 0 0"
    "Scrollbar" = "212 208 200"
    "TitleText" = "255 255 255"
    "Window" = "255 255 255"
    "WindowFrame" = "0 0 0"
    "WindowText" = "0 0 0"
}

foreach ($colorName in $XPColors.Keys) {
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name $colorName -Value $XPColors[$colorName]
}

Write-Host "  [OK] Color scheme applied" -ForegroundColor Green

# 5. DESKTOP AND TASKBAR SETTINGS
Write-Host "[5/7] Configuring Desktop and Taskbar for XP style..." -ForegroundColor Cyan

# Disable transparency effects
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name EnableTransparency -Value 0 -ErrorAction SilentlyContinue

# Classic taskbar appearance
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSizeMove -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons -Value 0 -ErrorAction SilentlyContinue

# Disable visual effects for performance (more XP-like)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 2 -ErrorAction SilentlyContinue

# Classic right-click menu
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -ErrorAction SilentlyContinue

Write-Host "  [OK] Desktop settings configured" -ForegroundColor Green

# 6. DISABLE ROUNDED CORNERS (Windows 11 specific)
Write-Host "[6/7] Disabling Windows 11 rounded corners..." -ForegroundColor Cyan
$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
if (-not (Test-Path $DWMPath)) {
    New-Item -Path $DWMPath -Force | Out-Null
}
Set-ItemProperty -Path $DWMPath -Name EnableWindowColorization -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $DWMPath -Name ColorizationColor -Value 0x6B74B8FC -ErrorAction SilentlyContinue
Set-ItemProperty -Path $DWMPath -Name ColorizationAfterglow -Value 0x6B74B8FC -ErrorAction SilentlyContinue
Write-Host "  [OK] Window styling configured" -ForegroundColor Green

# 7. BOOT SCREEN (HackBGRT Support)
Write-Host "[7/7] Setting up Windows XP Boot Screen..." -ForegroundColor Cyan

$BootImagePath = Join-Path $ScriptRoot "Boot\WindowsXP_Boot.gif"

if (Test-Path $BootImagePath) {
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
        Write-Host "  [+] HackBGRT found at: $HackBGRTPath" -ForegroundColor Green
        
        try {
            # Backup current HackBGRT splash if it exists
            $currentSplash = Join-Path $HackBGRTPath "splash.bmp"
            if (Test-Path $currentSplash) {
                $backupSplash = Join-Path $BackupDir "windows11_splash.bmp"
                Copy-Item -Path $currentSplash -Destination $backupSplash -Force -ErrorAction SilentlyContinue
                Write-Host "  [+] Current boot screen backed up" -ForegroundColor Green
            }
            
            Write-Host "  [*] To apply XP boot screen:" -ForegroundColor Yellow
            Write-Host "      1. Convert Boot\WindowsXP_Boot.gif to BMP format" -ForegroundColor White
            Write-Host "      2. Save as: $HackBGRTPath\splash.bmp" -ForegroundColor White
            Write-Host "      3. Reboot to see XP boot screen" -ForegroundColor White
            Write-Host "  [OK] HackBGRT ready for XP boot screen" -ForegroundColor Green
            
        } catch {
            Write-Host "  [!] Could not configure HackBGRT: $_" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "  [!] HackBGRT not installed" -ForegroundColor Yellow
        Write-Host "  [!] Boot image available at: Boot\WindowsXP_Boot.gif" -ForegroundColor Yellow
        Write-Host "  [!] Install HackBGRT to change boot screen" -ForegroundColor Yellow
        Write-Host "      Download: https://github.com/Metabolix/HackBGRT" -ForegroundColor Cyan
    }
    
} else {
    Write-Host "  [!] Boot screen image not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Windows XP Theme Applied Successfully! " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host "- Some changes require a RESTART to take full effect" -ForegroundColor White
Write-Host "- Icons can be changed manually using the Icons folder" -ForegroundColor White
Write-Host "- To restore Windows 11 theme, run: back_to_win11.ps1" -ForegroundColor White
Write-Host "- Backup saved to: $BackupDir" -ForegroundColor White
Write-Host ""

# Restart Explorer to apply changes
Write-Host "[*] Restarting Explorer to apply changes..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

# ========================================
# APPLY ICONS
# ========================================

Write-Host ""
Write-Host "[*] Applying Windows XP Icons..." -ForegroundColor Cyan
$IconScript = Join-Path $ScriptRoot "apply_icons.ps1"
if (Test-Path $IconScript) {
    & $IconScript
} else {
    Write-Host "  [!] Icon script not found" -ForegroundColor Yellow
}

# ========================================
# START OPENSHELL (CLASSIC START MENU)
# ========================================

Write-Host ""
Write-Host "[*] Starting OpenShell (Classic Start Menu)..." -ForegroundColor Cyan

# Check common OpenShell installation paths
$OpenShellPaths = @(
    "C:\Program Files\Open-Shell\StartMenu.exe",
    "C:\Program Files (x86)\Open-Shell\StartMenu.exe",
    "${env:ProgramFiles}\Open-Shell\StartMenu.exe",
    "${env:ProgramFiles(x86)}\Open-Shell\StartMenu.exe",
    (Join-Path $ScriptRoot "OpenShell\StartMenu.exe")
)

$OpenShellFound = $false
foreach ($path in $OpenShellPaths) {
    if (Test-Path $path) {
        Write-Host "  [+] OpenShell found at: $path" -ForegroundColor Green
        
        # Check if OpenShell is already running
        $OpenShellProcess = Get-Process -Name "StartMenu" -ErrorAction SilentlyContinue
        if ($OpenShellProcess) {
            Write-Host "  [!] OpenShell is already running" -ForegroundColor Yellow
        } else {
            # Start OpenShell
            Start-Process -FilePath $path -WindowStyle Hidden
            Start-Sleep -Seconds 2
            Write-Host "  [+] OpenShell started with classic Start Menu!" -ForegroundColor Green
        }
        
        $OpenShellFound = $true
        break
    }
}

if (-not $OpenShellFound) {
    Write-Host "  [!] OpenShell not found" -ForegroundColor Yellow
    Write-Host "  [!] Download from: https://github.com/Open-Shell/Open-Shell-Menu/releases" -ForegroundColor Yellow
    Write-Host "  [!] Or place StartMenu.exe in OpenShell folder" -ForegroundColor Yellow
}

# START RETROBAR WITH AUTO-CONFIGURATION

Write-Host ""
Write-Host "[*] Starting RetroBar (Windows XP Taskbar)..." -ForegroundColor Cyan
$RetroBarPath = Join-Path $ScriptRoot "Retro_Bar\RetroBar.exe"

if (Test-Path $RetroBarPath) {
    # Try Python auto-configurator first (BEST - automatically sets XP Blue theme)
    $PythonConfig = Join-Path $ScriptRoot "configure_retrobar_auto.py"
    if (Test-Path $PythonConfig) {
        Write-Host "  [*] Using Python auto-configurator (sets Windows XP Blue theme)..." -ForegroundColor Yellow
        
        # Check if Python is available
        $pythonAvailable = $false
        try {
            $null = python --version 2>&1
            $pythonAvailable = $true
        } catch {}
        
        if ($pythonAvailable) {
            python $PythonConfig
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] RetroBar configured and started with XP Blue theme!" -ForegroundColor Green
            } else {
                Write-Host "  [!] Python configurator failed, trying PowerShell method..." -ForegroundColor Yellow
                & (Join-Path $ScriptRoot "configure_retrobar.ps1")
            }
        } else {
            Write-Host "  [!] Python not found, using PowerShell method..." -ForegroundColor Yellow
            $ConfigScript = Join-Path $ScriptRoot "configure_retrobar.ps1"
            if (Test-Path $ConfigScript) {
                & $ConfigScript
            } else {
                Start-Process -FilePath $RetroBarPath -WindowStyle Hidden
                Write-Host "  [OK] RetroBar started (manual theme selection needed)" -ForegroundColor Green
            }
        }
    } else {
        # Fallback to PowerShell configurator
        $ConfigScript = Join-Path $ScriptRoot "configure_retrobar.ps1"
        if (Test-Path $ConfigScript) {
            & $ConfigScript
        } else {
            Start-Process -FilePath $RetroBarPath -WindowStyle Hidden
            Write-Host "  [OK] RetroBar started" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  [!] RetroBar not found at: Retro_Bar\RetroBar.exe" -ForegroundColor Yellow
    Write-Host "  [!] Download RetroBar from: https://github.com/dremin/RetroBar" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
