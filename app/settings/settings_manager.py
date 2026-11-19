"""
Settings Manager for Aurora Music
Handles application settings persistence and logic
"""
import json
import sys
import urllib.request
import urllib.error
import re
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Property, Slot, QRunnable, QThreadPool, QProcess
from PySide6.QtWidgets import QApplication, QFileDialog
try:
    from PySide6.QtDBus import QDBusMessage, QDBusConnection
except ImportError:
    QDBusMessage = QDBusConnection = None

from app.database.session import db
from app.library.scanner import LibraryScanner


class _UpdateSignals(QObject):
    finished = Signal(str)


class _UpdateCheck(QRunnable):
    def __init__(self):
        super().__init__()
        self.signals = _UpdateSignals()

    def run(self):
        request = urllib.request.Request(
            "https://api.github.com/repos/sammymullern/aurora-music/releases/latest",
            headers={"Accept": "application/vnd.github+json", "User-Agent": "Aurora-Music"},
        )
        try:
            with urllib.request.urlopen(request, timeout=8) as response:
                release = json.load(response)
            tag = release.get("tag_name", "").lstrip("v")
            if not tag:
                result = "No published release was found."
            elif self._version(tag) > self._version("0.1.0"):
                result = f"Aurora Music {tag} is available."
            else:
                result = "You’re running the latest release."
        except (urllib.error.URLError, TimeoutError, ValueError, OSError):
            result = "Could not check for updates. Check your internet connection and try again."
        self.signals.finished.emit(result)

    @staticmethod
    def _version(value):
        match = re.match(r"^(\d+)\.(\d+)\.(\d+)", value)
        return tuple(map(int, match.groups())) if match else (0, 0, 0)


class _LibraryTaskSignals(QObject):
    finished = Signal(str, str)


class _LibraryTask(QRunnable):
    def __init__(self, operation, folders):
        super().__init__()
        self.operation = operation
        self.folders = list(folders)
        self.signals = _LibraryTaskSignals()

    def _scan(self):
        session = db.get_session()
        try:
            scanner = LibraryScanner(session)
            return sum(
                scanner.scan_directory(folder)
                for folder in self.folders
                if Path(folder).is_dir()
            )
        finally:
            session.close()

    def run(self):
        try:
            if self.operation in {"scan", "rescan"}:
                count = self._scan()
                text = f"Scan complete. Added {count} tracks."
            elif self.operation == "clean":
                from app.database.models import Track, PlaylistTrack
                session = db.get_session()
                try:
                    rows = session.query(Track.id, Track.file_path).all()
                    missing_ids = [track_id for track_id, path in rows if not Path(path).is_file()]
                    if missing_ids:
                        session.query(PlaylistTrack).filter(
                            PlaylistTrack.track_id.in_(missing_ids)
                        ).delete(synchronize_session=False)
                        count = session.query(Track).filter(
                            Track.id.in_(missing_ids)
                        ).delete(synchronize_session=False)
                    else:
                        count = 0
                    session.commit()
                finally:
                    session.close()
                text = f"Removed {count} missing tracks."
            elif self.operation == "rebuild":
                from app.database.models import Track, Album, Artist, PlaylistTrack
                session = db.get_session()
                try:
                    session.query(PlaylistTrack).delete()
                    session.query(Track).delete()
                    session.query(Album).delete()
                    session.query(Artist).delete()
                    session.commit()
                finally:
                    session.close()
                count = self._scan()
                text = f"Index rebuilt. Found {count} tracks."
            else:
                text = "Unknown library action."
        except Exception as exc:
            logger.exception("Library operation failed: %s", self.operation)
            text = f"Library operation failed: {exc}"
        self.signals.finished.emit(self.operation, text)


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
    themeChanged = Signal()
    updateStatusChanged = Signal()
    libraryBusyChanged = Signal()
    libraryOperationStatusChanged = Signal()
    outputDeviceChanged = Signal()
    audioBufferChanged = Signal()
    
    def __init__(self):
        super().__init__()
        self._settings_file = Path.home() / ".config" / "aurora-music" / "settings.json"
        self._ensure_settings_dir()
        self._load_settings()
        self._update_status = ""
        self._library_busy = False
        self._library_operation_status = ""
    
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
            "last_session": {},
            "auto_check_updates": True,
            "language": "English",
            "show_desktop_notifications": True,
            "show_currently_playing": True,
            "music_folders": [],
            "watch_folders_automatically": True,
            "scan_frequency": "Manual",
            "output_device": "auto",
            "audio_buffer": 0.2,
            "theme": "Light",
        }
        
        if self._settings_file.exists():
            try:
                with open(self._settings_file, 'r') as f:
                    saved_settings = json.load(f)
                    # Merge with defaults to handle new settings
                    default_settings.update(saved_settings)
            except (json.JSONDecodeError, IOError):
                pass

        if default_settings.get("output_device") == "Default":
            default_settings["output_device"] = "auto"
        default_settings.setdefault("audio_buffer", 0.2)
        default_settings.pop("audio_backend", None)
        default_settings.pop("buffer_size", None)
        default_settings.pop("animated_backgrounds", None)
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

    def get_theme(self):
        return self._settings.get("theme", "Light")

    def set_theme(self, value):
        if value not in {"Light", "Dark", "Midnight", "Aurora"}:
            return
        if self._settings.get("theme") != value:
            self._settings["theme"] = value
            self._save_settings()
            self.themeChanged.emit()

    theme = Property(str, get_theme, set_theme, notify=themeChanged)

    def get_update_status(self):
        return self._update_status

    updateStatus = Property(str, get_update_status, notify=updateStatusChanged)

    def get_library_busy(self):
        return self._library_busy

    libraryBusy = Property(bool, get_library_busy, notify=libraryBusyChanged)

    def get_library_operation_status(self):
        return self._library_operation_status

    libraryOperationStatus = Property(
        str, get_library_operation_status, notify=libraryOperationStatusChanged
    )

    def get_output_device(self):
        return self._settings.get("output_device", "auto")

    def set_output_device(self, value):
        if isinstance(value, str) and value and self._settings.get("output_device") != value:
            self._settings["output_device"] = value
            self._save_settings()
            self.outputDeviceChanged.emit()

    outputDevice = Property(str, get_output_device, set_output_device, notify=outputDeviceChanged)

    def get_audio_buffer(self):
        return float(self._settings.get("audio_buffer", 0.2))

    def set_audio_buffer(self, value):
        value = round(max(0.05, min(2.0, float(value))), 2)
        if self._settings.get("audio_buffer", 0.2) != value:
            self._settings["audio_buffer"] = value
            self._save_settings()
            self.audioBufferChanged.emit()

    audioBuffer = Property(float, get_audio_buffer, set_audio_buffer, notify=audioBufferChanged)

    def _set_update_status(self, status):
        self._update_status = status
        self.updateStatusChanged.emit()
    
    # Library statistics
    def save_last_session(self, state):
        if self._settings.get("remember_last_session", True):
            self._settings["last_session"] = state
            self._save_settings()

    def get_last_session(self):
        return self._settings.get("last_session", {})

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
    @Slot(result=str)
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
                return folder
        return ""
    
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
        self._start_library_task("scan")
    
    @Slot()
    def rescanLibrary(self):
        """Rescan entire library"""
        self._start_library_task("rescan")
    
    @Slot()
    def cleanMissingSongs(self):
        """Remove tracks with missing files"""
        self._start_library_task("clean")
    
    @Slot()
    def rebuildDatabase(self):
        """Rebuild the entire database"""
        self._start_library_task("rebuild")

    def _start_library_task(self, operation):
        if self._library_busy:
            return
        self._library_busy = True
        labels = {
            "scan": "Scanning your music folders…",
            "rescan": "Refreshing the library index…",
            "clean": "Checking for missing files…",
            "rebuild": "Rebuilding the library index…",
        }
        self._library_operation_status = labels[operation]
        self.libraryBusyChanged.emit()
        self.libraryOperationStatusChanged.emit()
        worker = _LibraryTask(operation, self._settings.get("music_folders", []))
        worker.signals.finished.connect(self._on_library_task_finished)
        self._library_worker = worker
        QThreadPool.globalInstance().start(worker)

    @Slot(str, str)
    def _on_library_task_finished(self, operation, status):
        self._library_busy = False
        self._library_operation_status = status
        self.libraryBusyChanged.emit()
        self.libraryOperationStatusChanged.emit()
        self.libraryStatsChanged.emit()
        titles = {"scan": "Library Scan", "rescan": "Library Refresh", "clean": "Library Cleanup", "rebuild": "Library Rebuild"}
        self.showNotification(titles[operation], status)

    def wait_for_background_operations(self):
        QThreadPool.globalInstance().waitForDone()
    
    def _update_autostart(self):
        """Update autostart entry based on setting"""
        autostart_dir = Path.home() / ".config" / "autostart"
        autostart_file = autostart_dir / "aurora-music.desktop"
        
        if self._settings.get("launch_at_startup"):
            autostart_dir.mkdir(parents=True, exist_ok=True)
            project_root = Path(__file__).resolve().parents[2]
            desktop_content = """[Desktop Entry]
Type=Application
Name=Aurora Music
Exec="{}" -m app.main
Path="{}"
Icon=aurora-music
Terminal=false
Categories=Audio;Music;Player;
""".format(sys.executable, project_root)
            
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
        """Check GitHub for the latest published release without blocking the UI."""
        self._set_update_status("Checking for updates…")
        worker = _UpdateCheck()
        worker.signals.finished.connect(self._set_update_status)
        # Retain the worker while it is running so its signal object stays alive.
        self._update_worker = worker
        QThreadPool.globalInstance().start(worker)
    
    @Slot(str, str, str)
    def showNotification(self, title, message, icon=""):
        """Show system notification using freedesktop notifications"""
        if not self._settings.get("show_desktop_notifications", True):
            return
        
        try:
            if QDBusConnection is None:
                QProcess.startDetached("notify-send", [title, message])
                return
            bus = QDBusConnection.sessionBus()
            if not bus.isConnected():
                return
            
            dbus_message = QDBusMessage.createMethodCall(
                "org.freedesktop.Notifications",
                "/org/freedesktop/Notifications",
                "org.freedesktop.Notifications",
                "Notify"
            )
            
            dbus_message.setArguments([
                "Aurora Music",  # app_name
                0,  # replaces_id
                icon,  # app_icon
                title,  # summary
                message,  # body
                [],  # actions
                {},  # hints
                5000  # timeout in ms
            ])
            
            bus.call(dbus_message)
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
