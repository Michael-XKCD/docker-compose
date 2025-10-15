#!/usr/bin/env python3
"""
Game Manager - Automation script for idle games on Android emulator
Handles APK installation, game launching, and basic automation tasks.
"""

import os
import sys
import time
import subprocess
import logging
from pathlib import Path
from typing import List, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/tmp/game_data/automation.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class GameManager:
    def __init__(self):
        self.adb_host = os.getenv('ADB_SERVER_ADDRESS', 'android-emulator')
        self.adb_port = os.getenv('ADB_SERVER_PORT', '5555')
        self.adb_address = f"{self.adb_host}:{self.adb_port}"
        self.apk_dir = Path("/apks")
        self.game_data_dir = Path("/tmp/game_data")
        
        # Ensure directories exist
        self.game_data_dir.mkdir(exist_ok=True)
        
    def run_adb_command(self, command: List[str], timeout: int = 30) -> Optional[str]:
        """Run ADB command and return output."""
        try:
            full_command = ['adb', '-s', self.adb_address] + command
            logger.info(f"Running: {' '.join(full_command)}")
            
            result = subprocess.run(
                full_command,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            if result.returncode == 0:
                return result.stdout.strip()
            else:
                logger.error(f"ADB command failed: {result.stderr}")
                return None
                
        except subprocess.TimeoutExpired:
            logger.error(f"ADB command timed out after {timeout} seconds")
            return None
        except Exception as e:
            logger.error(f"Error running ADB command: {e}")
            return None
    
    def wait_for_device(self, max_wait: int = 120) -> bool:
        """Wait for emulator to be ready."""
        logger.info("Waiting for emulator to be ready...")
        
        # First, connect to the emulator
        subprocess.run(['adb', 'connect', self.adb_address], capture_output=True)
        
        for attempt in range(max_wait):
            if self.run_adb_command(['get-state']) == 'device':
                # Check if boot is complete
                boot_completed = self.run_adb_command(['shell', 'getprop', 'sys.boot_completed'])
                if boot_completed == '1':
                    logger.info("Emulator is ready!")
                    return True
            
            time.sleep(1)
            if attempt % 10 == 0:
                logger.info(f"Still waiting for emulator... ({attempt}/{max_wait})")
                
        logger.error("Emulator failed to become ready in time")
        return False
    
    def install_apk(self, apk_path: Path) -> bool:
        """Install an APK file."""
        if not apk_path.exists():
            logger.error(f"APK file not found: {apk_path}")
            return False
            
        logger.info(f"Installing APK: {apk_path.name}")
        result = self.run_adb_command(['install', '-r', str(apk_path)], timeout=120)
        
        if result and 'Success' in result:
            logger.info(f"Successfully installed {apk_path.name}")
            return True
        else:
            logger.error(f"Failed to install {apk_path.name}")
            return False
    
    def install_all_apks(self) -> int:
        """Install all APK files in the apks directory."""
        if not self.apk_dir.exists():
            logger.warning("APKs directory not found")
            return 0
            
        apk_files = list(self.apk_dir.glob("*.apk"))
        if not apk_files:
            logger.info("No APK files found to install")
            return 0
            
        installed_count = 0
        for apk_file in apk_files:
            if self.install_apk(apk_file):
                installed_count += 1
                
        logger.info(f"Installed {installed_count}/{len(apk_files)} APK files")
        return installed_count
    
    def get_installed_packages(self) -> List[str]:
        """Get list of installed packages."""
        result = self.run_adb_command(['shell', 'pm', 'list', 'packages', '-3'])
        if result:
            packages = [line.replace('package:', '') for line in result.split('\n') if line]
            return packages
        return []
    
    def launch_app(self, package_name: str) -> bool:
        """Launch an app by package name."""
        logger.info(f"Launching app: {package_name}")
        
        # Get the main activity
        result = self.run_adb_command([
            'shell', 'pm', 'dump', package_name, '|', 'grep', '-A', '1', 'MAIN'
        ])
        
        if not result:
            # Fallback: try to launch with monkey
            logger.info(f"Using monkey to launch {package_name}")
            result = self.run_adb_command([
                'shell', 'monkey', '-p', package_name, 
                '-c', 'android.intent.category.LAUNCHER', '1'
            ])
            return result is not None
        
        # Try to extract activity name and launch properly
        try:
            activity_result = self.run_adb_command([
                'shell', 'cmd', 'package', 'resolve-activity', 
                '--brief', package_name, '|', 'tail', '-n', '1'
            ])
            
            if activity_result:
                self.run_adb_command([
                    'shell', 'am', 'start', '-n', activity_result
                ])
                logger.info(f"Successfully launched {package_name}")
                return True
                
        except Exception as e:
            logger.error(f"Error launching app: {e}")
            
        return False
    
    def configure_emulator_for_idle_games(self):
        """Configure emulator settings optimized for idle games."""
        logger.info("Configuring emulator for idle games...")
        
        # Keep screen on
        self.run_adb_command(['shell', 'svc', 'power', 'stayon', 'true'])
        
        # Disable animations
        self.run_adb_command(['shell', 'settings', 'put', 'global', 'window_animation_scale', '0'])
        self.run_adb_command(['shell', 'settings', 'put', 'global', 'transition_animation_scale', '0'])
        self.run_adb_command(['shell', 'settings', 'put', 'global', 'animator_duration_scale', '0'])
        
        # Set high performance mode
        self.run_adb_command(['shell', 'settings', 'put', 'global', 'low_power', '0'])
        
        # Disable automatic updates
        self.run_adb_command(['shell', 'settings', 'put', 'global', 'auto_update_enabled', '0'])
        
        # Unlock screen
        self.run_adb_command(['shell', 'input', 'keyevent', 'KEYCODE_WAKEUP'])
        self.run_adb_command(['shell', 'input', 'keyevent', 'KEYCODE_MENU'])
        
        logger.info("Emulator configuration completed")
    
    def keep_games_active(self, package_names: List[str], check_interval: int = 300):
        """Keep specified games active by periodically checking and interacting."""
        logger.info(f"Starting game monitoring for: {', '.join(package_names)}")
        
        while True:
            for package in package_names:
                try:
                    # Check if app is running
                    result = self.run_adb_command([
                        'shell', 'pidof', package
                    ])
                    
                    if not result:
                        logger.info(f"Restarting {package}")
                        self.launch_app(package)
                        time.sleep(10)  # Wait for app to start
                    
                    # Send a light tap to keep the game active
                    self.run_adb_command(['shell', 'input', 'tap', '500', '500'])
                    
                except Exception as e:
                    logger.error(f"Error monitoring {package}: {e}")
                    
            time.sleep(check_interval)

def main():
    """Main function to run game automation."""
    manager = GameManager()
    
    # Wait for emulator to be ready
    if not manager.wait_for_device():
        logger.error("Emulator not ready, exiting")
        sys.exit(1)
    
    # Configure emulator
    manager.configure_emulator_for_idle_games()
    
    # Install APKs
    manager.install_all_apks()
    
    # Get installed games
    packages = manager.get_installed_packages()
    if packages:
        logger.info(f"Found {len(packages)} installed packages")
        
        # Launch first game as example
        if packages:
            manager.launch_app(packages[0])
        
        # Keep games active (uncomment to enable)
        # manager.keep_games_active(packages[:3])  # Monitor first 3 games
    
    logger.info("Game automation setup completed!")

if __name__ == "__main__":
    main()