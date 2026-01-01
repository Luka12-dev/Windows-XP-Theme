# Architecture Documentation

> **Windows XP Theme for Windows 11**  
> Technical architecture and system design overview

This document explains how the Windows XP theme transformation works under the hood, including the technical implementation, safety measures, and integration points.

---

## 📋 Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Component Breakdown](#component-breakdown)
- [Data Flow](#data-flow)
- [Registry Modifications](#registry-modifications)
- [Backup System](#backup-system)
- [Integration Points](#integration-points)
- [Safety Mechanisms](#safety-mechanisms)
- [Performance Considerations](#performance-considerations)
- [Technical Limitations](#technical-limitations)

---

## Overview

### Design Philosophy

The Windows XP theme transformation follows these core principles:

1. **Non-invasive:** Only modify user-level registry keys (HKCU), never system-level (HKLM)
2. **Reversible:** Every change is backed up before modification
3. **Safe:** No kernel modifications, no system file replacements
4. **User-friendly:** Automated scripts with clear feedback
5. **Modular:** Each component can be applied or restored independently

### Architecture Goals

- Maintain Windows 11 kernel integrity
- Preserve all system functionality
- Ensure complete reversibility
- Minimize performance impact
- Provide clear user feedback

---

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────┐
│                   User Interface                     │
│  (START_HERE.bat / PowerShell Scripts / Python)     │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│              Orchestration Layer                     │
│  • run.ps1 (Apply Theme)                            │
│  • back_to_win11.ps1 (Restore)                      │
│  • run-test.ps1 (Test Mode)                         │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
┌─────────────┐ ┌──────────┐ ┌──────────────┐
│   Backup    │ │ Registry │ │   Asset      │
│   System    │ │ Modifier │ │  Deployer    │
└─────────────┘ └──────────┘ └──────────────┘
          │            │            │
          └────────────┼────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│              Windows 11 System                       │
│  • User Registry (HKCU)                             │
│  • Desktop Environment                              │
│  • Explorer Shell                                   │
│  • Audio Subsystem                                  │
└─────────────────────────────────────────────────────┘
          │            │            │
          ▼            ▼            ▼
┌──────────────┐ ┌───────────┐ ┌──────────────┐
│  RetroBar    │ │ OpenShell │ │  Windows 11  │
│  (Taskbar)   │ │  (Start)  │ │   Kernel     │
└──────────────┘ └───────────┘ └──────────────┘
```

### Component Layers

1. **User Interface Layer**
   - Command-line interface (PowerShell scripts)
   - Batch file launcher (START_HERE.bat)
   - Python utilities for advanced features

2. **Orchestration Layer**
   - Theme application logic
   - Backup and restore coordination
   - Third-party tool integration

3. **Modification Layer**
   - Registry key modifications
   - File system operations
   - Asset deployment

4. **System Layer**
   - Windows 11 user environment
   - Shell components (Explorer, DWM)
   - Audio and visual subsystems

5. **Integration Layer**
   - Third-party tools (RetroBar, OpenShell)
   - Windows 11 native components

---

## Component Breakdown

### Core Scripts

#### 1. run.ps1 (Main Installer)

**Purpose:** Apply Windows XP theme permanently

**Workflow:**
```
Start
  │
  ├─> Check Administrator Privileges
  │     └─> Exit if not admin
  │
  ├─> Create Backup Directory
  │     └─> Backup_Win11/
  │
  ├─> Backup Current Settings
  │     ├─> Registry exports (*.reg files)
  │     ├─> Wallpaper path (txt)
  │     ├─> Cursor scheme (JSON)
  │     ├─> Sound scheme (JSON)
  │     ├─> Taskbar settings (JSON)
  │     └─> Icon settings (JSON)
  │
  ├─> Apply Visual Theme
  │     ├─> [1/7] Wallpaper
  │     ├─> [2/7] Cursors
  │     ├─> [3/7] Sounds
  │     ├─> [4/7] Colors (26 values)
  │     ├─> [5/7] Desktop Settings
  │     ├─> [6/7] DWM Settings
  │     └─> [7/7] Boot Screen (if HackBGRT)
  │
  ├─> Disable Auto-Hide Taskbar
  │     └─> Fix StuckRects3 binary
  │
  ├─> Convert and Apply Icons
  │     └─> Call apply_icons.ps1
  │
  ├─> Start Third-Party Tools
  │     ├─> OpenShell (if installed)
  │     └─> RetroBar (if available)
  │
  └─> Restart Explorer
        └─> Done
```

**Technical Details:**
- Uses .NET SystemParametersInfo API for wallpaper
- Binary manipulation for taskbar settings
- JSON serialization for complex backups
- Win32 API calls for cursor refresh

#### 2. back_to_win11.ps1 (Restoration)

**Purpose:** Restore Windows 11 default theme

**Workflow:**
```
Start
  │
  ├─> Check Administrator Privileges
  │
  ├─> Verify Backup Exists
  │     └─> Exit if not found
  │
  ├─> Restore Settings
  │     ├─> [1/6] Wallpaper
  │     ├─> [2/6] Cursors
  │     ├─> [3/6] Sounds
  │     ├─> [4/6] Colors (Win11 defaults)
  │     ├─> [5/6] Visual Features
  │     └─> [6/6] Registry Imports
  │
  ├─> Fix Taskbar Auto-Hide
  │     └─> Restore StuckRects3
  │
  ├─> Restore Icons
  │     └─> From icon_backup.json
  │
  ├─> Restore Boot Screen
  │     └─> If HackBGRT present
  │
  ├─> Stop Third-Party Tools
  │     ├─> Kill OpenShell processes
  │     └─> Kill RetroBar processes
  │
  └─> Restart Explorer
        └─> Done
```

#### 3. run-test.ps1 (Test Mode)

**Purpose:** Temporary 30-second theme test

**Workflow:**
```
Start
  │
  ├─> Rename existing backup (if any)
  │     └─> Backup_Win11 → Backup_Win11_Test
  │
  ├─> Apply Theme
  │     └─> Call run.ps1
  │
  ├─> 30-Second Countdown
  │     └─> Display timer
  │
  ├─> Restore Windows 11
  │     └─> Call back_to_win11.ps1
  │
  └─> Cleanup Test Backup
        └─> Done
```

### Utility Scripts

#### apply_icons.ps1

**Purpose:** Apply converted ICO icons to system

**Operations:**
1. Check for Icons_ICO directory
2. Backup current icon settings
3. Apply desktop icons (My Computer, Recycle Bin, etc.)
4. Apply folder icons
5. Apply system icons
6. Clear and refresh icon cache
7. Restart Explorer

**Registry Paths:**
```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\
  {20D04FE0-3AEA-1069-A2D8-08002B30309D}  # My Computer
  {645FF040-5081-101B-9F08-00AA002F954E}  # Recycle Bin
  {450D8FBA-AD25-11D0-98A8-0800361B1103}  # My Documents
  {F02C1A0D-BE21-4350-88B0-7367FC96EF3C}  # Network

HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons
  "3"  # Folder (closed)
  "4"  # Folder (open)
```

#### convert_all_icons.ps1

**Purpose:** Batch convert PNG icons to ICO format

**Algorithm:**
```csharp
foreach (PNGFile in Icons/) {
    Load image → System.Drawing.Image
    Determine optimal size (32x32 or original)
    Create bitmap → System.Drawing.Bitmap
    Convert to icon → System.Drawing.Icon
    Save as ICO → Icons_ICO/filename.ico
    Dispose resources
}
```

#### convert_icons_hq.py

**Purpose:** High-quality icon conversion with Python

**Features:**
- Multiple icon sizes (16×16 to 256×256)
- Lanczos resampling for quality
- RGBA → RGB conversion with alpha compositing
- Pillow (PIL) library for professional results

**Sizes Generated:**
```python
sizes = [
    (16, 16),   # Small icons, menus
    (32, 32),   # Standard desktop
    (48, 48),   # Large icons
    (64, 64),   # Extra large
    (128, 128), # High-DPI
    (256, 256)  # Maximum quality
]
```

#### configure_openshell.ps1

**Purpose:** Configure OpenShell for XP style

**Settings Applied:**
```
HKCU:\Software\OpenShell\StartMenu\Settings
  MenuStyle = "Classic2"
  SkinW7 = "Windows Aero"
  TwoColumns = 1
  EnableUserPicture = 1
  MenuAnimation = "Fade"
  EnableSettings = 1
  EnableDocuments = 1
  EnableRun = 1
```

#### configure_retrobar.ps1 / configure_retrobar_auto.py

**Purpose:** Configure RetroBar for XP Blue theme

**XML Configuration:**
```xml
<Settings>
  <CurrentTheme>Windows XP Blue</CurrentTheme>
  <EdgeMode>Bottom</EdgeMode>
  <AutoHide>false</AutoHide>
  <ShowClock>true</ShowClock>
  <ShowNotificationArea>true</ShowNotificationArea>
  <UseTaskbarAnimation>true</UseTaskbarAnimation>
</Settings>
```

**Config Location:** `%APPDATA%\RetroBar\RetroBar.xml`

---

## Data Flow

### Theme Application Flow

```
User Initiates Theme
        │
        ▼
┌──────────────────┐
│  Pre-Checks      │
│  • Admin rights  │
│  • File presence │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Backup Phase    │
│  • Export regs   │
│  • Save settings │
│  • JSON dumps    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Asset Deploy    │
│  • Copy files    │
│  • Convert icons │
│  • Set paths     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Registry Mods   │
│  • Colors        │
│  • Settings      │
│  • Icons         │
│  • Sounds        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  API Calls       │
│  • Wallpaper     │
│  • Cursor        │
│  • Refresh       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Integration     │
│  • OpenShell     │
│  • RetroBar      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Shell Restart   │
│  • Kill explorer │
│  • Wait 2s       │
│  • Auto-restart  │
└────────┬─────────┘
         │
         ▼
    Theme Applied
```

### Restoration Flow

```
User Initiates Restore
        │
        ▼
┌──────────────────┐
│  Verify Backup   │
│  • Check folder  │
│  • Validate data │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Stop Tools      │
│  • OpenShell     │
│  • RetroBar      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Restore Data    │
│  • Wallpaper     │
│  • Cursors       │
│  • Sounds        │
│  • Colors        │
│  • Icons         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Import Regs     │
│  • *.reg files   │
│  • Silent import │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  API Refresh     │
│  • Wallpaper     │
│  • Cursor        │
│  • Icon cache    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Shell Restart   │
│  • Kill explorer │
│  • Auto-restart  │
└────────┬─────────┘
         │
         ▼
   Restore Complete
```

---

## Registry Modifications

### Modified Registry Paths

All modifications are **user-level** (HKEY_CURRENT_USER) only:

#### 1. Control Panel Settings

**Colors:**
```
HKCU:\Control Panel\Colors
  ActiveBorder          = "212 208 200"
  ActiveTitle           = "0 84 227"
  AppWorkSpace          = "128 128 128"
  Background            = "0 78 152"
  ButtonFace            = "236 233 216"
  ButtonHilight         = "255 255 255"
  ButtonLight           = "241 239 226"
  ButtonShadow          = "172 168 153"
  ButtonText            = "0 0 0"
  GradientActiveTitle   = "61 149 255"
  GradientInactiveTitle = "157 185 235"
  GrayText              = "172 168 153"
  Hilight               = "49 106 197"
  HilightText           = "255 255 255"
  InactiveBorder        = "212 208 200"
  InactiveTitle         = "122 150 223"
  InactiveTitleText     = "216 228 248"
  InfoText              = "0 0 0"
  InfoWindow            = "255 255 225"
  Menu                  = "255 255 255"
  MenuText              = "0 0 0"
  Scrollbar             = "212 208 200"
  TitleText             = "255 255 255"
  Window                = "255 255 255"
  WindowFrame           = "0 0 0"
  WindowText            = "0 0 0"
```

**Desktop:**
```
HKCU:\Control Panel\Desktop
  Wallpaper        = "C:\Path\To\Windows_XP_Wallpaper.png"
  WallpaperStyle   = "2"  (Stretch)
  TileWallpaper    = "0"  (No tile)
```

**Cursors:**
```
HKCU:\Control Panel\Cursors
  (Default)        = "Windows XP"
  Arrow            = "C:\Path\To\cursor.cur"
  Hand             = "C:\Path\To\cursor.cur"
  Help             = ...
  AppStarting      = ...
  (etc.)
```

#### 2. Windows Themes

```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize
  EnableTransparency = 0  (Disabled)
```

#### 3. Explorer Settings

```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
  TaskbarSizeMove           = 0
  TaskbarSmallIcons         = 0
  TaskbarAutoHideInDesktop  = 0  (No auto-hide)
```

```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects
  VisualFXSetting = 2  (Best performance)
```

```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons
  "2"  = "C:\Path\To\Explorer.ico"
  "3"  = "C:\Path\To\Folder Closed.ico"
  "4"  = "C:\Path\To\Folder Opened.ico"
  "34" = "C:\Path\To\Control Panel.ico"
```

```
HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3
  Settings = [Binary Data]  (Taskbar position/visibility)
```

#### 4. DWM (Desktop Window Manager)

```
HKCU:\Software\Microsoft\Windows\DWM
  EnableWindowColorization = 1
  ColorizationColor        = 0x6B74B8FC
  ColorizationAfterglow    = 0x6B74B8FC
```

#### 5. Classic Context Menu

```
HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
  (Default) = ""  (Empty enables classic menu)
```

#### 6. Sound Scheme

```
HKCU:\AppEvents\Schemes\Apps\.Default\SystemStart\.Current
  (Default) = "C:\Path\To\WindowsXP_Startup.mp3"

HKCU:\AppEvents\Schemes\Apps\.Default\SystemExit\.Current
  (Default) = "C:\Path\To\windows-xp-log-out.mp3"

(Similar for SystemExclamation, SystemHand, .Default)
```

### Binary Data Structures

#### StuckRects3 Settings

The `StuckRects3\Settings` value contains binary data controlling taskbar behavior:

```
Byte Layout:
  [0-7]   : Header
  [8]     : Taskbar state (bit 0 = auto-hide)
  [9]     : Position
  [10]    : Visibility flags
  [11-n]  : Position coordinates
```

**Auto-hide Control:**
```powershell
$bytes[8] = $bytes[8] -band 0xFE  # Clear bit 0 to disable auto-hide
$bytes[10] = $bytes[10] -band 0xFE # Ensure visible
```

---

## Backup System

### Backup Architecture

```
run.ps1 Starts
     │
     ▼
┌────────────────────┐
│ Create Backup Dir  │
│ Backup_Win11/      │
└────────┬───────────┘
         │
         ├─> Registry Exports (*.reg)
         │   ├─ backup_HKEY_CURRENT_USER_Control_Panel_Colors.reg
         │   ├─ backup_HKEY_CURRENT_USER_Control_Panel_Desktop.reg
         │   ├─ backup_HKEY_CURRENT_USER_Control_Panel_Cursors.reg
         │   ├─ backup_HKEY_CURRENT_USER_Software_Microsoft_Windows_CurrentVersion_Themes.reg
         │   ├─ backup_HKEY_CURRENT_USER_Software_Microsoft_Windows_CurrentVersion_Explorer_Advanced.reg
         │   └─ backup_HKEY_CURRENT_USER_Software_Microsoft_Windows_DWM.reg
         │
         ├─> Text Backups
         │   └─ original_wallpaper.txt (path to current wallpaper)
         │
         └─> JSON Backups
             ├─ cursor_backup.json
             ├─ sound_backup.json
             ├─ taskbar_backup.json (includes StuckRects3 binary as Base64)
             └─ icon_backup.json
```

### Backup File Formats

**Registry (.reg):**
```
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\Colors]
"ActiveBorder"="180 180 180"
"ActiveTitle"="0 120 215"
...
```

**Wallpaper (.txt):**
```
C:\Windows\Web\Wallpaper\Windows\img0.jpg
```

**Cursor Backup (.json):**
```json
{
  "Arrow": "C:\\Windows\\Cursors\\aero_arrow.cur",
  "Help": "C:\\Windows\\Cursors\\aero_helpsel.cur",
  "Hand": "C:\\Windows\\Cursors\\aero_link.cur",
  ...
}
```

**Sound Backup (.json):**
```json
{
  "SystemStart": "C:\\Windows\\Media\\Windows Logon.wav",
  "SystemExit": "C:\\Windows\\Media\\Windows Logoff.wav",
  ...
}
```

**Taskbar Backup (.json):**
```json
{
  "StuckRects3_Settings": "AQAAAP////8MAAAAAQAAAA...",
  "TaskbarAl": 0,
  "TaskbarSi": 0,
  ...
}
```

**Icon Backup (.json):**
```json
{
  "ShellIcon_2": "%SystemRoot%\\system32\\imageres.dll,-1043",
  "ShellIcon_3": "%SystemRoot%\\system32\\imageres.dll,-3",
  "MyComputer": "%SystemRoot%\\system32\\imageres.dll,-109",
  "RecycleBin": "%SystemRoot%\\system32\\imageres.dll,-54",
  ...
}
```

### Restoration Process

```powershell
# back_to_win11.ps1

# 1. Check backup exists
if (-not (Test-Path $BackupDir)) { EXIT }

# 2. Restore wallpaper
$WallpaperPath = Get-Content "$BackupDir\original_wallpaper.txt"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $WallpaperPath
[Wallpaper]::SystemParametersInfo(0x0014, 0, $WallpaperPath, 0x0001 -bor 0x0002)

# 3. Restore cursors
$CursorBackup = Get-Content "$BackupDir\cursor_backup.json" | ConvertFrom-Json
$CursorBackup.PSObject.Properties | ForEach-Object {
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name $_.Name -Value $_.Value
}
[CursorHelper]::SystemParametersInfo(0x0057, 0, 0, 0x0001 -bor 0x0002)

# 4. Restore sounds
$SoundBackup = Get-Content "$BackupDir\sound_backup.json" | ConvertFrom-Json
$SoundBackup.PSObject.Properties | ForEach-Object {
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes\Apps\.Default\$($_.Name)\.Current" -Name "(Default)" -Value $_.Value
}

# 5. Restore taskbar
$TaskbarBackup = Get-Content "$BackupDir\taskbar_backup.json" | ConvertFrom-Json
$bytes = [Convert]::FromBase64String($TaskbarBackup.StuckRects3_Settings)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -Value ([byte[]]$bytes)

# 6. Restore icons
$IconBackup = Get-Content "$BackupDir\icon_backup.json" | ConvertFrom-Json
# ... restore icon paths

# 7. Import registry files
Get-ChildItem -Path $BackupDir -Filter "*.reg" | ForEach-Object {
    reg import $_.FullName
}

# 8. Restart Explorer
Stop-Process -Name explorer -Force
```

---

## Integration Points

### Third-Party Tool Integration

#### RetroBar Integration

**Detection:**
```powershell
$RetroBarPaths = @(
    "$ScriptRoot\Retro_Bar\RetroBar.exe",
    "C:\Program Files\RetroBar\RetroBar.exe",
    "${env:ProgramFiles}\RetroBar\RetroBar.exe"
)

foreach ($path in $RetroBarPaths) {
    if (Test-Path $path) {
        $RetroBarExe = $path
        break
    }
}
```

**Configuration:**
```powershell
# Create XML config
$ConfigPath = Join-Path $env:APPDATA "RetroBar\RetroBar.xml"
$XmlContent = @"
<?xml version="1.0"?>
<Settings>
  <CurrentTheme>Windows XP Blue</CurrentTheme>
  <EdgeMode>Bottom</EdgeMode>
  <AutoHide>false</AutoHide>
  ...
</Settings>
"@
$XmlContent | Out-File -FilePath $ConfigPath -Encoding UTF8

# Start RetroBar
Start-Process -FilePath $RetroBarExe -WindowStyle Hidden
```

**Termination:**
```powershell
$Processes = Get-Process -Name "RetroBar" -ErrorAction SilentlyContinue
if ($Processes) {
    $Processes | Stop-Process -Force
}
```

#### OpenShell Integration

**Detection:**
```powershell
$OpenShellPaths = @(
    "C:\Program Files\Open-Shell\StartMenu.exe",
    "C:\Program Files (x86)\Open-Shell\StartMenu.exe",
    "$ScriptRoot\OpenShell\StartMenu.exe"
)

foreach ($path in $OpenShellPaths) {
    if (Test-Path $path) {
        $OpenShellExe = $path
        break
    }
}
```

**Configuration:**
```powershell
$RegPath = "HKCU:\Software\OpenShell\StartMenu\Settings"
Set-ItemProperty -Path $RegPath -Name "MenuStyle" -Value "Classic2"
Set-ItemProperty -Path $RegPath -Name "TwoColumns" -Value 1
Set-ItemProperty -Path $RegPath -Name "MenuAnimation" -Value "Fade"
# ... more settings
```

**Start:**
```powershell
Start-Process -FilePath $OpenShellExe -WindowStyle Hidden
```

**Termination:**
```powershell
# Find ALL OpenShell process names
$ProcessNames = @("StartMenu", "ClassicStartMenu", "OpenShellMenu", "StartMenuHost")

foreach ($name in $ProcessNames) {
    $Processes = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($Processes) {
        # Try graceful close
        $Processes | ForEach-Object { $_.CloseMainWindow() }
        Start-Sleep -Seconds 2
        
        # Force if still running
        $Remaining = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($Remaining) {
            $Remaining | Stop-Process -Force
        }
    }
}
```

#### HackBGRT Integration (Boot Screen)

**Detection:**
```powershell
$HackBGRTPaths = @(
    "C:\HackBGRT",
    "${env:SystemDrive}\HackBGRT",
    "${env:ProgramFiles}\HackBGRT"
)

$HackBGRTPath = $null
foreach ($path in $HackBGRTPaths) {
    if (Test-Path $path) {
        $HackBGRTPath = $path
        break
    }
}
```

**Configuration (Manual):**
```powershell
if ($HackBGRTPath) {
    Write-Host "HackBGRT found at: $HackBGRTPath"
    Write-Host "Convert Boot\WindowsXP_Boot.gif to BMP"
    Write-Host "Save as: $HackBGRTPath\splash.bmp"
    Write-Host "Reboot to see XP boot screen"
}
```

**Note:** HackBGRT requires manual configuration due to UEFI complexity and potential system risks.

### Windows API Integration

#### Wallpaper API

```csharp
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(
        int uAction, 
        int uParam, 
        string lpvParam, 
        int fuWinIni
    );
}
"@

// Constants
const int SPI_SETDESKWALLPAPER = 0x0014;
const int SPIF_UPDATEINIFILE = 0x0001;
const int SPIF_SENDCHANGE = 0x0002;

// Set wallpaper
[Wallpaper]::SystemParametersInfo(
    SPI_SETDESKWALLPAPER, 
    0, 
    $WallpaperPath, 
    SPIF_UPDATEINIFILE -bor SPIF_SENDCHANGE
)
```

#### Cursor Refresh API

```csharp
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CursorHelper {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(
        uint uiAction, 
        uint uiParam, 
        uint pvParam, 
        uint fWinIni
    );
}
"@

// Constants
const uint SPI_SETCURSORS = 0x0057;

// Refresh cursors
[CursorHelper]::SystemParametersInfo(
    SPI_SETCURSORS, 
    0, 
    0, 
    SPIF_UPDATEINIFILE -bor SPIF_SENDCHANGE
)
```

#### Icon Cache Refresh

```powershell
# Delete icon cache
$IconCache = Join-Path $env:LOCALAPPDATA "IconCache.db"
if (Test-Path $IconCache) {
    Remove-Item -Path $IconCache -Force
}

# Refresh using IE4UINIT
ie4uinit.exe -show
```

---

## Safety Mechanisms

### Design Principles

The theme transformation prioritizes safety through multiple layers of protection:

1. **User-Level Only:** All modifications target HKEY_CURRENT_USER (HKCU)
2. **No System Files:** Zero modifications to Windows\System32 or protected directories
3. **No Kernel Changes:** Windows 11 kernel remains untouched
4. **Automatic Backups:** Every setting backed up before modification
5. **Clean Rollback:** Complete restoration capability

### Protection Layers

```
┌─────────────────────────────────────┐
│    Administrator Check Layer         │
│  • Verify elevation before changes  │
│  • Clear error messages if not admin│
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│    Validation Layer                  │
│  • Check file existence             │
│  • Verify backup directory          │
│  • Validate asset integrity         │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│    Backup Layer                      │
│  • Export all registry keys         │
│  • Save all current settings        │
│  • Store in JSON/REG formats        │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│    Modification Layer                │
│  • Only HKCU modifications          │
│  • No protected file changes        │
│  • Graceful error handling          │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│    Verification Layer                │
│  • Confirm changes applied          │
│  • Log any failures                 │
│  • Provide user feedback            │
└─────────────────────────────────────┘
```

### Administrator Privilege Checks

**Implementation:**
```powershell
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on the script and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}
```

**Why Required:**
- Registry modifications need elevated permissions
- Process termination (Explorer, RetroBar, OpenShell) requires admin
- System-wide settings changes need proper rights

**User Protection:**
- Clear error messages if not elevated
- Instructions provided for proper execution
- Prevents partial installations

### Error Handling Strategy

**PowerShell Error Handling:**
```powershell
$ErrorActionPreference = "Stop"

try {
    # Risky operation
    Set-ItemProperty -Path "HKCU:\SomePath" -Name "Value" -Value "Data"
} catch {
    Write-Host "[ERROR] Failed to modify registry: $_" -ForegroundColor Red
    # Attempt rollback or continue with warning
}
```

**Graceful Degradation:**
- If icon conversion fails → Continue with other changes
- If RetroBar missing → Continue without taskbar replacement
- If OpenShell not installed → Continue without Start Menu replacement
- Core theme always applies, enhancements are optional

### File System Safety

**Read-Only Operations:**
```
✓ Read from Icons/ directory
✓ Read from Wallpaper/ directory
✓ Read from Sounds/ directory
✓ Copy to user directories only
```

**No Write Operations To:**
```
✗ C:\Windows\System32\
✗ C:\Windows\
✗ C:\Program Files\
✗ Boot partition (without HackBGRT)
✗ Any protected system directories
```

**User Directory Operations:**
```
✓ Backup_Win11/ (created in script directory)
✓ Icons_ICO/ (created in script directory)
✓ %APPDATA%\RetroBar\ (user config)
✓ WindowsXP_Icons/ (user profile)
```

### Registry Safety

**Allowed Operations:**
```
✓ HKEY_CURRENT_USER\Control Panel\*
✓ HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\*
✓ HKEY_CURRENT_USER\Software\OpenShell\*
✓ HKEY_CURRENT_USER\AppEvents\*
```

**Forbidden Operations:**
```
✗ HKEY_LOCAL_MACHINE\* (system-wide settings)
✗ HKEY_CLASSES_ROOT\* (except HKCU mirror)
✗ Boot configuration
✗ System policies
```

**Backup Before Modification:**
Every registry path is exported before changes:
```powershell
reg export "HKEY_CURRENT_USER\Control Panel\Colors" "$BackupDir\backup_colors.reg" /y
```

### Process Management Safety

**Explorer Restart:**
```powershell
# Graceful termination
Stop-Process -Name explorer -Force

# Wait for clean shutdown
Start-Sleep -Seconds 2

# Explorer auto-restarts (Windows 11 behavior)
# No manual restart needed
```

**Third-Party Tool Management:**
```powershell
# Try graceful close first
$Process.CloseMainWindow()
Start-Sleep -Seconds 2

# Force terminate only if still running
if (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue) {
    Stop-Process -Name $ProcessName -Force
}
```

**Risk Mitigation:**
- Explorer auto-restarts if crashed
- Desktop remains accessible
- No system processes terminated
- Only user-initiated applications affected

### Data Integrity

**Backup Validation:**
```powershell
# Check backup exists before restoration
if (-not (Test-Path $BackupDir)) {
    Write-Host "ERROR: Backup directory not found!" -ForegroundColor Red
    Write-Host "Cannot restore without backup." -ForegroundColor Yellow
    exit 1
}

# Verify backup files
$RequiredFiles = @("cursor_backup.json", "sound_backup.json", "original_wallpaper.txt")
foreach ($file in $RequiredFiles) {
    if (-not (Test-Path (Join-Path $BackupDir $file))) {
        Write-Host "WARNING: $file not found in backup" -ForegroundColor Yellow
    }
}
```

**JSON Serialization:**
- Complex objects stored as JSON for reliable restoration
- Base64 encoding for binary data (StuckRects3)
- UTF-8 encoding for all text files

**Registry Export:**
- Native .REG format for maximum compatibility
- Can be manually inspected/edited if needed
- Importable even if script fails

---

## Performance Considerations

### Resource Usage

**Disk Space:**
```
Script Package:        ~8 MB
- Icons (PNG):         ~2 MB
- Icons (ICO):         ~2 MB
- Wallpaper:           6.7 MB
- Sounds:              ~100 KB
- Scripts:             ~100 KB

Runtime Space:         ~10 MB
- Backup:              ~50 KB
- Icon copies:         ~2 MB (optional)
- Temp files:          Minimal
```

**Memory Usage:**
```
PowerShell Process:    ~50-100 MB (during execution)
RetroBar:              ~10-20 MB (if running)
OpenShell:             ~15-30 MB (if installed)

Total Added:           ~25-50 MB (persistent)
```

**CPU Usage:**
```
During Installation:   10-20% (1-2 minutes)
During Normal Use:     <1% additional
Icon Conversion:       20-40% (depends on method)
```

### Execution Time

**Theme Application (run.ps1):**
```
Pre-checks:            <1 second
Backup creation:       5-10 seconds
Theme application:     10-20 seconds
Icon conversion:       20-30 seconds (PowerShell)
                       30-60 seconds (Python HQ)
Tool integration:      5-10 seconds
Total:                 30-90 seconds
```

**Theme Restoration (back_to_win11.ps1):**
```
Backup verification:   <1 second
Stop tools:            2-5 seconds
Restore settings:      10-15 seconds
Registry import:       5-10 seconds
Total:                 20-30 seconds
```

**Test Mode (run-test.ps1):**
```
Apply theme:           30-60 seconds
Wait period:           30 seconds (fixed)
Restore theme:         20-30 seconds
Total:                 80-120 seconds
```

### Performance Optimizations

**Icon Conversion:**

*PowerShell Method:*
```powershell
# Optimized: Direct .NET calls
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($PNGPath)
$bitmap = New-Object System.Drawing.Bitmap($img, 32, 32)
$icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
$icon.Save($ICOPath)
```

*Python Method (Higher Quality):*
```python
# Multiple sizes for all resolutions
sizes = [(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)]
img.save(ico_path, format='ICO', sizes=sizes)
```

**Batch Operations:**
```powershell
# Group registry changes
$ColorChanges = @{
    "ActiveTitle" = "0 84 227"
    "ButtonFace" = "236 233 216"
    # ... 24 more colors
}

# Apply all at once
foreach ($key in $ColorChanges.Keys) {
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name $key -Value $ColorChanges[$key]
}
```

**Parallel Processing:**
- Multiple registry exports run concurrently
- Icon conversion processes in batches
- File operations optimized with buffering

### Visual Performance Impact

**Before Theme (Windows 11):**
```
Transparency:          Enabled (GPU-intensive)
Animations:            Full effects
Visual effects:        Maximum
DWM Compositor:        Full acceleration
```

**After Theme (Windows XP Style):**
```
Transparency:          Disabled (CPU savings)
Animations:            Minimal
Visual effects:        Best performance
DWM Compositor:        Basic composition
```

**Result:** Potential 5-10% performance improvement on lower-end hardware due to reduced visual effects.

### Startup Impact

**No Persistent Services:**
- No background processes added
- No startup registry entries (except user choice)
- RetroBar/OpenShell are optional
- Theme applies immediately, no boot delay

**Boot Time:**
- Unchanged: No boot configuration modifications
- Optional: HackBGRT adds ~1-2 seconds (if configured)

---

## Technical Limitations

### Inherent Windows 11 Constraints

**1. Taskbar Structure**
```
Limitation:  Windows 11 taskbar is UWP-based
Impact:      Cannot be fully replaced with classic taskbar
Workaround:  RetroBar runs alongside (can hide Win11 taskbar)
Status:      Cosmetic limitation only
```

**2. Start Menu**
```
Limitation:  Windows 11 Start Menu is integrated with Shell
Impact:      Cannot replace without third-party tools
Workaround:  OpenShell provides classic Start Menu
Status:      Optional enhancement, not required
```

**3. Window Borders**
```
Limitation:  DWM controls window composition
Impact:      Cannot achieve exact XP window borders
Workaround:  Disable transparency, adjust colors
Status:      Visual approximation, very close to XP
```

**4. File Explorer**
```
Limitation:  Explorer.exe is Windows 11 version
Impact:      Ribbon interface remains
Workaround:  Cosmetic changes only (icons, colors)
Alternative: Third-party tools like OldNewExplorer
```

**5. System Icons**
```
Limitation:  Some icons hardcoded in system DLLs
Impact:      Not all system icons replaceable
Workaround:  Replace user-accessible icons only
Status:      500+ icons available, covers most common items
```

### Technical Restrictions

**Boot Screen:**
```
Limitation:  UEFI Secure Boot prevents boot logo changes
Impact:      Cannot change boot screen without HackBGRT
Workaround:  HackBGRT (requires Secure Boot disable)
Risk:        Advanced users only, potential security impact
```

**Lock Screen:**
```
Limitation:  Lock screen is UWP component
Impact:      Cannot apply XP styling to lock screen
Workaround:  Lock screen remains Windows 11 style
Status:      Minor cosmetic limitation
```

**Modern Apps:**
```
Limitation:  UWP/Modern apps use own theming
Impact:      Settings, Store, etc. remain Windows 11 style
Workaround:  None (by design, separate UI framework)
Status:      Expected behavior, not a bug
```

**Context Menus:**
```
Limitation:  Windows 11 new context menus partially applied
Impact:      Some menus remain modern style
Workaround:  Registry tweak enables classic menus
Status:      Mostly successful, some exceptions
```

### Icon Format Constraints

**PNG to ICO Conversion:**
```
Challenge:   Windows requires ICO format for icons
Impact:      501 PNG icons need conversion
Solutions:   
  1. PowerShell: Fast, lower quality
  2. Python/Pillow: Slower, high quality with multiple sizes
Status:      Both methods work, user choice
```

**Icon Size Limitations:**
```
Optimal:     32x32 pixels (XP standard)
Supported:   16x16, 32x32, 48x48, 64x64, 128x128, 256x256
Issue:       Some XP icons were 32x32 only
Workaround:  Upscaling for larger sizes, downscaling for smaller
```

### Registry Limitations

**HKCU vs HKLM:**
```
Limitation:  Only HKCU modifications (safety)
Impact:      Changes apply per-user, not system-wide
Benefit:     Safer, reversible, no admin conflicts
Trade-off:   Each user must apply theme separately
```

**Binary Data:**
```
Limitation:  StuckRects3 is binary registry value
Impact:      Complex to manipulate correctly
Solution:    Base64 encoding, byte-level manipulation
Status:      Working correctly, auto-hide fix implemented
```

### Compatibility Constraints

**Windows Update:**
```
Limitation:  Major Windows updates may reset some settings
Impact:      Taskbar, Explorer settings might revert
Workaround:  Re-run theme script after major updates
Frequency:   Rare (1-2 times per year for major updates)
```

**Third-Party Software:**
```
Limitation:  Some apps override system theme
Impact:      App-specific styling may conflict
Examples:    Chrome, Firefox, modern apps
Workaround:  Per-app theme settings (if available)
```

**Screen Resolution:**
```
Limitation:  XP assets designed for lower resolutions
Impact:      Wallpaper may look stretched on high-DPI displays
Workaround:  Wallpaper is 1920x1080, covers most displays
Note:        4K displays may see minor quality degradation
```

### Restoration Limitations

**Backup Dependency:**
```
Limitation:  Restoration requires backup files
Impact:      If backup deleted, cannot auto-restore
Workaround:  Manual registry editing required
Prevention:  Clear warning not to delete backup folder
```

**Partial Restoration:**
```
Limitation:  Some settings may not restore perfectly
Impact:      Minor visual differences possible
Examples:    Custom wallpapers, third-party cursor schemes
Solution:    Manual reconfiguration if needed
```

### Third-Party Tool Limitations

**RetroBar:**
```
Pros:        Excellent XP taskbar replica
Limitations: Runs alongside Windows 11 taskbar (can hide)
            Does not replace system tray completely
Status:      Best available solution for XP taskbar
```

**OpenShell:**
```
Pros:        Perfect classic Start Menu
Limitations: Requires separate installation
            Settings stored separately
Status:      Optional but highly recommended
```

**HackBGRT:**
```
Pros:        Changes boot logo
Limitations: Requires UEFI modifications
            Security risk if misconfigured
            Advanced users only
Status:      Optional, not automated by our scripts
```

### Known Issues & Solutions

**Issue 1: Taskbar Auto-Hide Bug**
```
Problem:     Some users experience taskbar auto-hide after restore
Cause:       StuckRects3 binary data corruption
Solution:    Fixed in v1.0 - proper binary restoration
Status:      ✓ RESOLVED
```

**Issue 2: Icons Not Changing**
```
Problem:     Some icons don't change after applying theme
Cause:       Icon cache not cleared or restart needed
Solution:    Script now clears cache + restart recommended
Status:      ✓ RESOLVED (restart may still be needed)
```

**Issue 3: Explorer Crashes**
```
Problem:     Rare Explorer crashes during theme application
Cause:       Timing issue with rapid registry changes
Solution:    Added 2-second delay before restart
Status:      ✓ RESOLVED (very rare now)
```

**Issue 4: Cursor Doesn't Change**
```
Problem:     Cursor remains Windows 11 style
Cause:       Requires logoff/reboot for full effect
Solution:    Script notes this, user should logoff after
Status:      ⚠ PARTIAL (Windows limitation, not a bug)
```

### Future Improvements

**Planned Enhancements:**
1. Additional XP themes (Silver, Olive Green, Royale)
2. Automated HackBGRT configuration (with safety checks)
3. Enhanced icon conversion quality
4. Better high-DPI support
5. Automatic Windows Update detection and re-application

**Community Requests:**
- Luna theme variations
- Windows 98 theme option
- More sound schemes
- Custom theme creation tools

---

## Conclusion

### Architecture Summary

The Windows XP Theme for Windows 11 is built on a foundation of safety, reversibility, and user control. By operating exclusively at the user level (HKCU), avoiding system file modifications, and implementing comprehensive backup systems, the theme provides a nostalgic Windows XP experience without compromising Windows 11's stability or functionality.

### Key Architectural Strengths

1. **Layered Safety:** Multiple validation and protection layers
2. **Modular Design:** Components work independently
3. **Clean Separation:** User modifications isolated from system
4. **Graceful Degradation:** Works even with missing optional components
5. **Complete Reversibility:** One-click restoration to Windows 11

### Technical Achievement

This project demonstrates that significant UI transformation is possible without kernel modifications or system file replacement. Through careful registry manipulation, Win32 API usage, and third-party tool integration, we achieve a convincing Windows XP aesthetic while maintaining Windows 11's modern foundation.

### Educational Value

The architecture serves as a reference for:
- Safe Windows customization techniques
- PowerShell automation and registry manipulation
- Backup and restore system design
- Third-party tool integration patterns
- User-level vs system-level modifications

### Final Notes

This is my first project of 2026, created with the goal of bringing Windows XP nostalgia to modern systems. The architecture prioritizes user safety and system stability above all else, ensuring that anyone can enjoy the classic XP experience without risk.

**Remember:** This theme changes only the UI, never the kernel. Your Windows 11 remains fully functional, secure, and modern under the classic XP appearance.

---

<div align="center">

**Architecture Documentation v1.0**  
*Windows XP Theme for Windows 11*

Created January 1st, 2026

[⬆ Back to Top](#architecture-documentation)

</div>