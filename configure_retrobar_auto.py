import os
import sys
import time
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

def create_retrobar_config():
    print("=" * 80)
    print("RETROBAR AUTO-CONFIGURATOR")
    print("=" * 80)
    print()
    
    # RetroBar config directory
    appdata = os.getenv('APPDATA')
    if not appdata:
        print("[ERROR] Could not find APPDATA directory")
        return False
    
    config_dir = Path(appdata) / "RetroBar"
    config_file = config_dir / "RetroBar.xml"
    
    print(f"[*] Config directory: {config_dir}")
    
    # Create directory if it doesn't exist
    config_dir.mkdir(parents=True, exist_ok=True)
    print(f"[+] Config directory ready")
    
    # Create XML configuration for Windows XP Blue
    config_xml = """<?xml version="1.0" encoding="utf-8"?>
<Settings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <CurrentTheme>Windows XP Blue</CurrentTheme>
  <EdgeMode>Bottom</EdgeMode>
  <AutoHide>false</AutoHide>
  <ShowClock>true</ShowClock>
  <ShowNotificationArea>true</ShowNotificationArea>
  <ShowTaskView>false</ShowTaskView>
  <ShowMultiMon>true</ShowMultiMon>
  <CollapseNotifyIcons>false</CollapseNotifyIcons>
  <UseTaskbarAnimation>true</UseTaskbarAnimation>
  <Language>en-US</Language>
</Settings>
"""
    
    # Write configuration file
    try:
        with open(config_file, 'w', encoding='utf-8') as f:
            f.write(config_xml)
        print(f"[+] Configuration written to: {config_file}")
        print(f"[+] Theme set to: Windows XP Blue")
        print(f"[+] Auto-hide disabled")
        print(f"[+] Clock and system tray enabled")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to write config: {e}")
        return False

def kill_retrobar():
    """Kill any existing RetroBar processes"""
    try:
        # Try to kill RetroBar gracefully
        subprocess.run(['taskkill', '/F', '/IM', 'RetroBar.exe'], 
                      stdout=subprocess.DEVNULL, 
                      stderr=subprocess.DEVNULL)
        time.sleep(1)
        return True
    except:
        return False

def start_retrobar(retrobar_path):
    try:
        print()
        print("[*] Starting RetroBar...")
        
        # Start RetroBar in the background
        subprocess.Popen([retrobar_path], 
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
        
        time.sleep(2)
        print("[+] RetroBar started with Windows XP Blue theme!")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to start RetroBar: {e}")
        return False

def main():
    # Get script directory
    script_dir = Path(__file__).parent
    retrobar_path = script_dir / "Retro_Bar" / "RetroBar.exe"
    
    print()
    
    # Check if RetroBar exists
    if not retrobar_path.exists():
        print(f"[ERROR] RetroBar.exe not found at: {retrobar_path}")
        print()
        print("Please download RetroBar from:")
        print("https://github.com/dremin/RetroBar/releases")
        print()
        print("Place RetroBar.exe in the Retro_Bar folder")
        print()
        input("Press Enter to exit...")
        return False
    
    print(f"[+] RetroBar found: {retrobar_path}")
    print()
    
    # Kill existing RetroBar
    print("[*] Stopping any existing RetroBar processes...")
    kill_retrobar()
    print("[+] Previous instances stopped")
    print()
    
    # Create configuration
    print("[*] Creating RetroBar configuration...")
    if not create_retrobar_config():
        print()
        print("[ERROR] Failed to create configuration")
        input("Press Enter to exit...")
        return False
    
    print()
    print("=" * 80)
    print("CONFIGURATION COMPLETE!")
    print("=" * 80)
    
    # Start RetroBar
    if start_retrobar(retrobar_path):
        print()
        print("=" * 80)
        print("SUCCESS!")
        print("=" * 80)
        print()
        print("RetroBar is now running with Windows XP Blue theme!")
        print()
        print("Features configured:")
        print("  - Theme: Windows XP Blue")
        print("  - Position: Bottom of screen")
        print("  - Auto-hide: Disabled (always visible)")
        print("  - Clock: Enabled")
        print("  - System tray: Enabled")
        print("  - Animations: Enabled")
        print()
        print("To customize further:")
        print("  Right-click RetroBar > Properties")
        print()
        return True
    else:
        print()
        print("[ERROR] Failed to start RetroBar")
        input("Press Enter to exit...")
        return False

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n[!] Cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n[ERROR] Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        input("Press Enter to exit...")
        sys.exit(1)
