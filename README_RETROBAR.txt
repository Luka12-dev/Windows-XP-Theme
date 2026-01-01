========================================
RETROBAR INTEGRATION GUIDE
========================================

RetroBar is now integrated into the Windows XP theme package!
It will automatically start and configure when you apply the theme.

========================================
WHAT IS RETROBAR?
========================================

RetroBar is a taskbar replacement for Windows that brings back
the classic Windows XP/95/98 taskbar look to Windows 11.

Features:
---------
- Classic Windows XP Blue taskbar
- Start button with XP styling
- System tray with XP appearance
- Quick launch icons support
- Runs alongside Windows 11 taskbar

========================================
AUTOMATIC SETUP
========================================

When you run "run.ps1" or "run-test.ps1":
------------------------------------------
1. The theme is applied (wallpaper, colors, sounds, etc.)
2. Windows XP icons are converted and applied
3. RetroBar is automatically configured for XP Blue theme
4. RetroBar starts automatically
5. Windows 11 taskbar remains (you can hide it manually)

When you run "back_to_win11.ps1":
----------------------------------
1. RetroBar is automatically stopped
2. All theme settings are restored
3. Windows 11 taskbar is restored

========================================
RETROBAR LOCATION
========================================

Required folder structure:
--------------------------
XP_Reantimation/
  Retro_Bar/
    RetroBar.exe       <- Place RetroBar here (Or download from release.)

Download RetroBar:
------------------
https://github.com/dremin/RetroBar/releases

1. Download the latest release (RetroBar.zip)
2. Extract RetroBar.exe
3. Place it in the "Retro_Bar" folder

========================================
RETROBAR CONFIGURATION
========================================

Automatic Configuration:
------------------------
The script "configure_retrobar.ps1" automatically:
- Sets theme to "Windows XP Blue"
- Enables taskbar at bottom
- Shows clock and system tray
- Enables animations
- Creates config at: %APPDATA%\RetroBar\RetroBar.xml

Manual Configuration:
---------------------
If you want to customize RetroBar:
1. Right-click on RetroBar taskbar
2. Select "Properties"
3. Choose your preferred theme:
   - Windows XP Blue (recommended)
   - Windows Classic
   - Windows 95/98
   - Windows ME
4. Adjust other settings as desired

========================================
AVAILABLE THEMES IN RETROBAR
========================================

Windows XP Blue (Recommended):
-------------------------------
- Classic blue and green XP appearance
- Rounded start button
- Blue title bar on active windows
- Matches our theme perfectly

Windows Classic:
----------------
- Gray Windows 95/NT appearance
- Square buttons
- Classic gray scheme

Other Themes:
-------------
- Windows 95
- Windows 98
- Windows ME
- Windows 2000

========================================
RETROBAR CONTROLS
========================================

Right-click RetroBar:
---------------------
- Properties         - Configure RetroBar
- Task Manager       - Open Task Manager
- Cascade Windows    - Arrange windows
- Show Desktop       - Minimize all windows
- Exit               - Close RetroBar

Start Button:
-------------
- Click to open Start menu (Windows 11 Start)
- Works just like classic XP Start button

System Tray:
------------
- Shows running applications
- System icons (network, sound, etc.)
- Clock display

========================================
TIPS & TRICKS
========================================

Hide Windows 11 Taskbar:
------------------------
To fully enjoy RetroBar:
1. Right-click Windows 11 taskbar
2. Select "Taskbar settings"
3. Turn on "Automatically hide the taskbar"
4. Now only RetroBar will be visible!

Quick Launch:
-------------
RetroBar supports Quick Launch toolbar:
1. Right-click RetroBar
2. Toolbars > Quick Launch
3. Add your favorite shortcuts

Pin Programs:
-------------
Pin programs to RetroBar:
1. Open the program
2. Right-click its taskbar button
3. Select "Pin to taskbar"

RetroBar Startup:
-----------------
To make RetroBar start automatically:
1. Press Win + R
2. Type: shell:startup
3. Create shortcut to: Retro_Bar\RetroBar.exe
4. RetroBar will start with Windows

========================================
TROUBLESHOOTING
========================================

RetroBar doesn't start:
-----------------------
- Make sure RetroBar.exe is in "Retro_Bar" folder
- Download from: https://github.com/dremin/RetroBar/releases
- Run as Administrator if needed

RetroBar won't stop:
--------------------
- Run: stop_retrobar.ps1
- Or manually: Task Manager > End RetroBar process

Wrong theme showing:
--------------------
- Right-click RetroBar > Properties
- Select "Windows XP Blue" from dropdown
- Click Apply

Both taskbars showing:
----------------------
- Hide Windows 11 taskbar in settings
- Or enjoy both (RetroBar + Win11 taskbar)

Configuration not saving:
-------------------------
- Make sure you have write permissions
- Config location: %APPDATA%\RetroBar\
- Try running as Administrator

========================================
MANUAL SCRIPTS
========================================

If you want to manage RetroBar separately:

configure_retrobar.ps1:
-----------------------
- Configures RetroBar for XP Blue theme
- Starts RetroBar
- Run this to reconfigure RetroBar

stop_retrobar.ps1:
------------------
- Stops RetroBar
- Restores Windows 11 taskbar
- Run this to manually stop RetroBar

========================================
ADVANCED: CUSTOM THEMES
========================================

RetroBar supports custom themes!

Theme Location:
---------------
%APPDATA%\RetroBar\Themes\

Create Custom Theme:
--------------------
1. Copy an existing theme folder
2. Modify the theme files
3. Select your theme in Properties

Community Themes:
-----------------
Check RetroBar GitHub for community themes:
https://github.com/dremin/RetroBar

========================================
IMPORTANT NOTES
========================================

Performance:
------------
- RetroBar is lightweight (minimal RAM usage)
- No performance impact on games or apps
- Can run 24/7 without issues

Compatibility:
--------------
- Works with all Windows 11 versions
- Compatible with multiple monitors
- Works with Windows 11 Start menu

Uninstall:
----------
- Run: stop_retrobar.ps1
- Or delete RetroBar.exe
- No system files modified

Updates:
--------
- Check GitHub for RetroBar updates
- Extract new version to Retro_Bar folder
- Configuration is preserved

========================================
FREQUENTLY ASKED QUESTIONS
========================================

Q: Does RetroBar replace Windows 11 taskbar?
A: No, it runs alongside it. You can hide Win11 taskbar.

Q: Can I use Windows XP Start menu?
A: RetroBar uses Win11 Start menu. For XP Start, use Open-Shell.

Q: Will this work on Windows 10?
A: Yes! RetroBar works on Windows 10 and 11.

Q: Is RetroBar safe?
A: Yes! It's open-source on GitHub, regularly updated.

Q: Can I customize the colors?
A: Yes, through theme files or custom themes.

Q: Does it slow down my computer?
A: No, RetroBar is very lightweight.

Q: Can I use it with dual monitors?
A: Yes! RetroBar supports multiple monitors.

========================================
CREDITS
========================================

RetroBar:
---------
Created by: dremin
GitHub: https://github.com/dremin/RetroBar
License: Apache License 2.0

This Integration:
-----------------
Part of Windows XP Theme for Windows 11
Automatically configures RetroBar for XP experience

========================================
SUPPORT & MORE INFO
========================================

RetroBar Issues:
----------------
https://github.com/dremin/RetroBar/issues

RetroBar Wiki:
--------------
https://github.com/dremin/RetroBar/wiki

This Theme Package:
-------------------
See: README.txt for complete documentation

========================================
ENJOY YOUR WINDOWS XP TASKBAR!
========================================
