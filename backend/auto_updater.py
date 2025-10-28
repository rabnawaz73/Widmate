"""
Automatic yt-dlp Update System
Handles scheduled updates, startup checks, and background update management
"""

import asyncio
import time
import threading
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
import subprocess
import sys
import requests
import json
import pkg_resources
from pathlib import Path

logger = logging.getLogger(__name__)

class AutoUpdater:
    """Handles automatic yt-dlp updates with configurable schedules"""
    
    def __init__(self):
        self.is_running = False
        self.update_thread = None
        self.last_check = 0
        self.check_interval = 24 * 60 * 60  # 24 hours in seconds
        self.auto_update_enabled = True
        self.notify_on_update = False
        self.update_on_startup = True
        self.silent_updates = True
        
        # Update status tracking
        self.update_status = {
            "status": "idle",  # idle, checking, updating, completed, failed
            "progress": 0.0,
            "message": "",
            "error": None,
            "last_update": None,
            "next_check": None
        }
        
        # Load configuration
        self._load_config()
    
    def _validate_config(self, config: Dict[str, Any]):
        """Validate the auto-updater configuration"""
        if not isinstance(config.get("check_interval"), int) or config.get("check_interval", 0) < 3600:
            raise ValueError("check_interval must be an integer greater than or equal to 3600")
        if not isinstance(config.get("enabled"), bool):
            raise ValueError("enabled must be a boolean")
        if not isinstance(config.get("notify_on_update"), bool):
            raise ValueError("notify_on_update must be a boolean")
        if not isinstance(config.get("update_on_startup"), bool):
            raise ValueError("update_on_startup must be a boolean")
        if not isinstance(config.get("silent_updates"), bool):
            raise ValueError("silent_updates must be a boolean")

    def _load_config(self):
        """Load auto-update configuration from file"""
        config_file = Path("config/auto_update.json")
        if config_file.exists():
            try:
                with open(config_file, 'r') as f:
                    config = json.load(f)
                    self._validate_config(config)
                    self.check_interval = config.get("check_interval", 24 * 60 * 60)
                    self.auto_update_enabled = config.get("enabled", True)
                    self.notify_on_update = config.get("notify_on_update", True)
                    self.update_on_startup = config.get("update_on_startup", True)
                    self.silent_updates = config.get("silent_updates", False)
                    logger.info(f"Loaded auto-update config: {config}")
            except (ValueError, json.JSONDecodeError) as e:
                logger.error(f"Failed to load or validate auto-update config: {e}")
    
    def _save_config(self):
        """Save auto-update configuration to file"""
        config_dir = Path("config")
        config_dir.mkdir(exist_ok=True)
        
        config = {
            "check_interval": self.check_interval,
            "enabled": self.auto_update_enabled,
            "notify_on_update": self.notify_on_update,
            "update_on_startup": self.update_on_startup,
            "silent_updates": self.silent_updates,
            "last_updated": datetime.now().isoformat()
        }
        
        try:
            with open(config_dir / "auto_update.json", 'w') as f:
                json.dump(config, f, indent=2)
            logger.info("Auto-update config saved")
        except Exception as e:
            logger.error(f"Failed to save auto-update config: {e}")
    
    def start(self):
        """Start the auto-updater service"""
        if self.is_running:
            logger.warning("Auto-updater is already running")
            return
        
        self.is_running = True
        
        # Check for updates on startup if enabled
        if self.update_on_startup:
            logger.info("Checking for updates on startup...")
            asyncio.create_task(self._check_and_update_async())
        
        # Start the background update thread
        self.update_thread = threading.Thread(target=self._update_loop, daemon=True)
        self.update_thread.start()
        
        logger.info("Auto-updater started")
    
    def stop(self):
        """Stop the auto-updater service"""
        self.is_running = False
        if self.update_thread and self.update_thread.is_alive():
            self.update_thread.join(timeout=5)
        logger.info("Auto-updater stopped")
    
    def _update_loop(self):
        """Main update loop running in background thread"""
        while self.is_running:
            try:
                current_time = time.time()
                
                # Check if it's time for an update check
                if (current_time - self.last_check) >= self.check_interval:
                    logger.info("Scheduled update check triggered")
                    asyncio.run(self._check_and_update_async())
                    self.last_check = current_time
                
                # Sleep for 1 hour before next check
                time.sleep(60 * 60)
                
            except Exception as e:
                logger.error(f"Error in update loop: {e}")
                time.sleep(60 * 5)  # Wait 5 minutes before retrying
    
    async def _check_and_update_async(self):
        """Check for updates and update if available"""
        try:
            self.update_status["status"] = "checking"
            self.update_status["message"] = "Checking for updates..."
            
            # Get current and latest versions
            current_version = self._get_current_version()
            latest_version = self._get_latest_version()
            
            if latest_version == "unknown":
                self.update_status["status"] = "idle"
                self.update_status["message"] = "Could not check for updates"
                return
            
            if current_version == latest_version:
                self.update_status["status"] = "idle"
                self.update_status["message"] = f"yt-dlp is up to date (v{current_version})"
                self.update_status["next_check"] = datetime.now() + timedelta(seconds=self.check_interval)
                logger.info(f"yt-dlp is up to date: {current_version}")
                return
            
            # Update available
            logger.info(f"Update available: {current_version} -> {latest_version}")
            
            if self.auto_update_enabled:
                if self.silent_updates:
                    logger.info("Starting silent update...")
                    await self._update_ytdlp_silent()
                else:
                    logger.info("Update available, waiting for manual trigger")
                    self.update_status["status"] = "idle"
                    self.update_status["message"] = f"Update available: {current_version} -> {latest_version}"
                    
                    if self.notify_on_update:
                        # Send notification (implement based on your notification system)
                        self._send_update_notification(current_version, latest_version)
            else:
                self.update_status["status"] = "idle"
                self.update_status["message"] = f"Update available but auto-update disabled"
                
        except Exception as e:
            logger.error(f"Error checking for updates: {e}")
            self.update_status["status"] = "failed"
            self.update_status["error"] = str(e)
            self.update_status["message"] = f"Update check failed: {e}"
    
    def _get_current_version(self) -> str:
        """Get currently installed yt-dlp version"""
        try:
            return pkg_resources.get_distribution("yt-dlp").version
        except pkg_resources.DistributionNotFound:
            try:
                result = subprocess.run(
                    [sys.executable, "-m", "yt_dlp", "--version"],
                    capture_output=True, text=True, check=True
                )
                return result.stdout.strip()
            except subprocess.SubprocessError:
                return "unknown"
    
    def _get_latest_version(self) -> (str, str):
        """Get latest available yt-dlp version and its SHA256 checksum from PyPI"""
        try:
            response = requests.get("https://pypi.org/pypi/yt-dlp/json", timeout=10)
            response.raise_for_status()
            data = response.json()
            version = data["info"]["version"]
            for release in data["releases"][version]:
                if release["packagetype"] == "sdist":
                    return version, release["digests"]["sha256"]
            return version, None
        except Exception as e:
            logger.error(f"Failed to get latest version: {e}")
            return "unknown", None
    
    def _download_and_verify_package(self, version: str, expected_checksum: str):
        """Download the yt-dlp package and verify its SHA256 checksum"""
        try:
            url = f"https://files.pythonhosted.org/packages/source/y/yt-dlp/yt-dlp-{version}.tar.gz"
            response = requests.get(url, stream=True, timeout=30)
            response.raise_for_status()
            
            hasher = hashlib.sha256()
            for chunk in response.iter_content(chunk_size=8192):
                hasher.update(chunk)
            
            actual_checksum = hasher.hexdigest()
            
            if actual_checksum != expected_checksum:
                raise Exception("Checksum mismatch")
            
            return response.content
        except Exception as e:
            logger.error(f"Failed to download or verify package: {e}")
            raise
    
    async def _update_ytdlp_silent(self):
        """Perform silent update without user interaction"""
        try:
            self.update_status["status"] = "updating"
            self.update_status["progress"] = 0.0
            self.update_status["message"] = "Updating yt-dlp..."
            
            latest_version, expected_checksum = self._get_latest_version()
            if latest_version == "unknown" or not expected_checksum:
                raise Exception("Could not get latest version information")
            
            package_content = self._download_and_verify_package(latest_version, expected_checksum)
            
            # Update progress
            self.update_status["progress"] = 0.2
            self.update_status["message"] = "Preparing update..."
            
            # Run pip install from the downloaded package
            with open(f"yt-dlp-{latest_version}.tar.gz", "wb") as f:
                f.write(package_content)
            
            self.update_status["progress"] = 0.4
            self.update_status["message"] = "Installing update..."
            
            result = subprocess.run(
                [sys.executable, "-m", "pip", "install", f"yt-dlp-{latest_version}.tar.gz"],
                capture_output=True, text=True
            )
            
            os.remove(f"yt-dlp-{latest_version}.tar.gz")
            
            if result.returncode != 0:
                raise Exception(f"Update failed: {result.stderr}")
            
            # Complete update
            self.update_status["progress"] = 1.0
            self.update_status["message"] = "Update completed successfully"
            self.update_status["status"] = "completed"
            self.update_status["last_update"] = datetime.now().isoformat()
            
            # Get new version
            new_version = self._get_current_version()
            logger.info(f"Successfully updated yt-dlp to version {new_version}")
            
            if self.notify_on_update:
                self._send_update_completion_notification(new_version)
                
        except Exception as e:
            logger.error(f"Silent update failed: {e}")
            self.update_status["status"] = "failed"
            self.update_status["error"] = str(e)
            self.update_status["message"] = f"Update failed: {e}"
    
    def _send_update_notification(self, current_version: str, latest_version: str):
        """Send notification about available update"""
        # Implement notification logic here
        # This could integrate with your existing notification system
        logger.info(f"Update notification: {current_version} -> {latest_version}")
    
    def _send_update_completion_notification(self, new_version: str):
        """Send notification about completed update"""
        # Implement notification logic here
        logger.info(f"Update completion notification: {new_version}")
    
    def get_status(self) -> Dict[str, Any]:
        """Get current auto-updater status"""
        return {
            "is_running": self.is_running,
            "auto_update_enabled": self.auto_update_enabled,
            "check_interval_hours": self.check_interval / 3600,
            "last_check": self.last_check,
            "next_check": self.last_check + self.check_interval if self.last_check else None,
            "update_status": self.update_status
        }
    
    
