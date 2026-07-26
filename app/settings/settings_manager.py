"""
Settings Manager for Aurora Music
Handles application settings persistence and logic
"""
import os
import json
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtWidgets import QApplication, QFileDialog
from PySide6.QtDBus import QDBusMessage, QDBusConnection

from app.database.session import db
from app.library.scanner import LibraryScanner


class SettingsManager(QObject):
    """Manages application settings with QML integration"""
    
    # Signals for QML binding
    launchAtStartupChanged = Signal()
    startMinimizedChanged = Signal()
    rememberLastSessionChanged = Signal()
    restoreLastPlaylistChanged = Signal()
    autoCheckUpdatesChanged = Signal()
    languageChanged = Signal()
    showDesktopNotificationsChanged = Signal()
    showCurrentlyPlayingChanged = Signal()
    musicFoldersChanged = Signal()
    watchFoldersAutomaticallyChanged = Signal()
    scanFrequencyChanged = Signal()
    libraryStatsChanged = Signal()
    
    def __init__(self):
        super().__init__()
        self._settings_file = Path.home() / ".config" / "aurora-music" / "settings.json"
        self._ensure_settings_dir()
        self._load_settings()
        self._scanner = None
    
    def _ensure_settings_dir(self):
        """Ensure settings directory exists"""
        self._settings_file.parent.mkdir(parents=True, exist_ok=True)
    
    def _load_settings(self):
        """Load settings from JSON file"""
        default_settings = {
            "launch_at_startup": False,
            "start_minimized": False,
            "remember_last_session": True,
            "restore_last_playlist": True,
            "auto_check_updates": True,
            "language": "English",
            "show_desktop_notifications": True,
            "show_currently_playing": True,
            "music_folders": [],
            "watch_folders_automatically": True,
            "scan_frequency": "Manual",
            "audio_backend": "MPV (Recommended)",
            "output_device": "Default",
            "buffer_size": 512,
            "theme": "Dark",
            "animated_backgrounds": False
        }
        
        if self._settings_file.exists():
            try:
                with open(self._settings_file, 'r') as f:
                    saved_settings = json.load(f)
                    # Merge with defaults to handle new settings
                    default_settings.update(saved_settings)
            except (json.JSONDecodeError, IOError):
                pass
        
        self._settings = default_settings
    
    def _save_settings(self):
        """Save settings to JSON file"""
        try:
            with open(self._settings_file, 'w') as f:
                json.dump(self._settings, f, indent=4)
        except IOError:
            pass
    
    # Property getters and setters
    def get_launch_at_startup(self):
        return self._settings.get("launch_at_startup", False)
    
    def set_launch_at_startup(self, value):
        if self._settings.get("launch_at_startup") != value:
            self._settings["launch_at_startup"] = value
            self._save_settings()
            self._update_autostart()
            self.launchAtStartupChanged.emit()
    
    launchAtStartup = Property(bool, get_launch_at_startup, set_launch_at_startup, notify=launchAtStartupChanged)
    
    def get_start_minimized(self):
        return self._settings.get("start_minimized", False)
    
    def set_start_minimized(self, value):
        if self._settings.get("start_minimized") != value:
            self._settings["start_minimized"] = value
            self._save_settings()
            self.startMinimizedChanged.emit()
    
    startMinimized = Property(bool, get_start_minimized, set_start_minimized, notify=startMinimizedChanged)
    
    def get_remember_last_session(self):
        return self._settings.get("remember_last_session", True)
    
    def set_remember_last_session(self, value):
        if self._settings.get("remember_last_session") != value:
            self._settings["remember_last_session"] = value
            self._save_settings()
            self.rememberLastSessionChanged.emit()
    
    rememberLastSession = Property(bool, get_remember_last_session, set_remember_last_session, notify=rememberLastSessionChanged)
    
    def get_restore_last_playlist(self):
        return self._settings.get("restore_last_playlist", True)
    
    def set_restore_last_playlist(self, value):
        if self._settings.get("restore_last_playlist") != value:
            self._settings["restore_last_playlist"] = value
            self._save_settings()
            self.restoreLastPlaylistChanged.emit()
    
    restoreLastPlaylist = Property(bool, get_restore_last_playlist, set_restore_last_playlist, notify=restoreLastPlaylistChanged)
    
    def get_auto_check_updates(self):
        return self._settings.get("auto_check_updates", True)
    
    def set_auto_check_updates(self, value):
        if self._settings.get("auto_check_updates") != value:
            self._settings["auto_check_updates"] = value
            self._save_settings()
            self.autoCheckUpdatesChanged.emit()
    
    autoCheckUpdates = Property(bool, get_auto_check_updates, set_auto_check_updates, notify=autoCheckUpdatesChanged)
    
    def get_language(self):
        return self._settings.get("language", "English")
    
    def set_language(self, value):
        if self._settings.get("language") != value:
            self._settings["language"] = value
            self._save_settings()
            self.languageChanged.emit()
    
    language = Property(str, get_language, set_language, notify=languageChanged)
    
    def get_show_desktop_notifications(self):
        return self._settings.get("show_desktop_notifications", True)
    
    def set_show_desktop_notifications(self, value):
        if self._settings.get("show_desktop_notifications") != value:
            self._settings["show_desktop_notifications"] = value
            self._save_settings()
            self.showDesktopNotificationsChanged.emit()
    
    showDesktopNotifications = Property(bool, get_show_desktop_notifications, set_show_desktop_notifications, notify=showDesktopNotificationsChanged)
    
    def get_show_currently_playing(self):
        return self._settings.get("show_currently_playing", True)
    
    def set_show_currently_playing(self, value):
        if self._settings.get("show_currently_playing") != value:
            self._settings["show_currently_playing"] = value
            self._save_settings()
            self.showCurrentlyPlayingChanged.emit()
    
    showCurrentlyPlaying = Property(bool, get_show_currently_playing, set_show_currently_playing, notify=showCurrentlyPlayingChanged)
    
    # Library settings
    def get_music_folders(self):
        return self._settings.get("music_folders", [])
    
    def set_music_folders(self, value):
        if self._settings.get("music_folders") != value:
            self._settings["music_folders"] = value
            self._save_settings()
            self.musicFoldersChanged.emit()
    
    musicFolders = Property('QVariantList', get_music_folders, set_music_folders, notify=musicFoldersChanged)
    
    def get_watch_folders_automatically(self):
        return self._settings.get("watch_folders_automatically", True)
    
    def set_watch_folders_automatically(self, value):
        if self._settings.get("watch_folders_automatically") != value:
            self._settings["watch_folders_automatically"] = value
            self._save_settings()
            self.watchFoldersAutomaticallyChanged.emit()
    
    watchFoldersAutomatically = Property(bool, get_watch_folders_automatically, set_watch_folders_automatically, notify=watchFoldersAutomaticallyChanged)
    
    def get_scan_frequency(self):
        return self._settings.get("scan_frequency", "Manual")
    
    def set_scan_frequency(self, value):
        if self._settings.get("scan_frequency") != value:
            self._settings["scan_frequency"] = value
            self._save_settings()
            self.scanFrequencyChanged.emit()
    
    scanFrequency = Property(str, get_scan_frequency, set_scan_frequency, notify=scanFrequencyChanged)
    
    # Library statistics
    def get_library_stats(self):
        """Get library statistics"""
        from app.database.models import Track, Album, Artist
        session = db.get_session()
        try:
            song_count = session.query(Track).count()
            album_count = session.query(Album).count()
            artist_count = session.query(Artist).count()
            
            # Calculate total size
            total_size = session.query(Track).with_entities(Track.file_size).all()
            size_bytes = sum(s[0] or 0 for s in total_size)
            
            # Format size
            if size_bytes < 1024:
                size_str = f"{size_bytes} B"
            elif size_bytes < 1024 * 1024:
                size_str = f"{size_bytes / 1024:.1f} KB"
            elif size_bytes < 1024 * 1024 * 1024:
                size_str = f"{size_bytes / (1024 * 1024):.1f} MB"
            else:
                size_str = f"{size_bytes / (1024 * 1024 * 1024):.1f} GB"
            
            return {
                "songs": song_count,
                "albums": album_count,
                "artists": artist_count,
                "size": size_str
            }
        finally:
            session.close()
    
    libraryStats = Property('QVariantMap', get_library_stats, notify=libraryStatsChanged)
    
    # Library management methods
    @Slot()
    def browseMusicFolder(self):
        """Open folder dialog to select music folder"""
        app = QApplication.instance()
        if app:
            folder = QFileDialog.getExistingDirectory(
                None,
                "Select Music Folder",
                str(Path.home()),
                QFileDialog.ShowDirsOnly
            )
            if folder:
                self.addMusicFolder(folder)
    
    @Slot(str)
    def addMusicFolder(self, folder_path):
        """Add a music folder to the library"""
        folders = self._settings.get("music_folders", [])
        if folder_path not in folders:
            folders.append(folder_path)
            self._settings["music_folders"] = folders
            self._save_settings()
            self.musicFoldersChanged.emit()
            self.libraryStatsChanged.emit()
    
    @Slot(str)
    def removeMusicFolder(self, folder_path):
        """Remove a music folder from the library"""
        folders = self._settings.get("music_folders", [])
        if folder_path in folders:
            folders.remove(folder_path)
            self._settings["music_folders"] = folders
            self._save_settings()
            self.musicFoldersChanged.emit()
    
    @Slot()
    def scanLibrary(self):
        """Scan all music folders"""
        if not self._scanner:
            self._scanner = LibraryScanner(db.get_session())
        
        folders = self._settings.get("music_folders", [])
        total_added = 0
        for folder in folders:
            if Path(folder).exists():
                added = self._scanner.scan_directory(folder)
                total_added += added
        
        self.libraryStatsChanged.emit()
        self.showNotification("Library Scan", f"Added {total_added} tracks")
    
    @Slot()
    def rescanLibrary(self):
        """Rescan entire library"""
        if not self._scanner:
            self._scanner = LibraryScanner(db.get_session())
        
        folders = self._settings.get("music_folders", [])
        total_added = 0
        for folder in folders:
            if Path(folder).exists():
                added = self._scanner.scan_directory(folder)
                total_added += added
        
        self.libraryStatsChanged.emit()
        self.showNotification("Library Rescan", f"Processed {total_added} tracks")
    
    @Slot()
    def cleanMissingSongs(self):
        """Remove tracks with missing files"""
        from app.database.models import Track
        session = db.get_session()
        try:
            tracks = session.query(Track).all()
            removed = 0
            for track in tracks:
                if not Path(track.file_path).exists():
                    session.delete(track)
                    removed += 1
            session.commit()
            self.libraryStatsChanged.emit()
            self.showNotification("Clean Library", f"Removed {removed} missing tracks")
        finally:
            session.close()
    
    @Slot()
    def rebuildDatabase(self):
        """Rebuild the entire database"""
        from app.database.models import Track, Album, Artist
        session = db.get_session()
        try:
            # Clear all data
            session.query(Track).delete()
            session.query(Album).delete()
            session.query(Artist).delete()
            session.commit()
            
            # Rescan folders
            self.rescanLibrary()
        finally:
            session.close()
    
    def _update_autostart(self):
        """Update autostart entry based on setting"""
        autostart_dir = Path.home() / ".config" / "autostart"
        autostart_file = autostart_dir / "aurora-music.desktop"
        
        if self._settings.get("launch_at_startup"):
            autostart_dir.mkdir(parents=True, exist_ok=True)
            desktop_content = """[Desktop Entry]
Type=Application
Name=Aurora Music
Exec={}
Icon=aurora-music
Terminal=false
Categories=Audio;Music;Player;
""".format(os.path.abspath(__file__).replace("settings_manager.py", "main.py"))
            
            try:
                with open(autostart_file, 'w') as f:
                    f.write(desktop_content)
            except IOError:
                pass
        else:
            if autostart_file.exists():
                try:
                    autostart_file.unlink()
                except IOError:
                    pass
    
    @Slot()
    def checkForUpdates(self):
        """Check for application updates"""
        # Placeholder for update checking logic
        print("Checking for updates...")
        # TODO: Implement actual update checking
    
    @Slot(str, str, str)
    def showNotification(self, title, message, icon=""):
        """Show system notification using freedesktop notifications"""
        if not self._settings.get("show_desktop_notifications", True):
            return
        
        try:
            bus = QDBusConnection.sessionBus()
            if not bus.isConnected():
                return
            
            message = QDBusMessage.createMethodCall(
                "org.freedesktop.Notifications",
                "/org/freedesktop/Notifications",
                "org.freedesktop.Notifications",
                "Notify"
            )
            
            message.setArguments([
                "Aurora Music",  # app_name
                0,  # replaces_id
                icon,  # app_icon
                title,  # summary
                message,  # body
                [],  # actions
                {},  # hints
                5000  # timeout in ms
            ])
            
            bus.call(message)
        except Exception:
            pass
    
    @Slot(str, str)
    def showNowPlaying(self, title, artist):
        """Show now playing notification"""
        if not self._settings.get("show_currently_playing", True):
            return
        
        self.showNotification(
            "Now Playing",
            f"{title}\nby {artist}",
            "audio-x-generic"
        )
