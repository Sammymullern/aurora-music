"""
Main application window with sidebar navigation
"""

import logging
from pathlib import Path

from PySide6.QtCore import QUrl, QObject, Signal, QTimer
from PySide6.QtQml import QQmlApplicationEngine, QQmlContext
from PySide6.QtGui import QGuiApplication

from app.player.player import Player
from app.database.session import db
from app.settings.settings_manager import SettingsManager
from app.i18n.translation_manager import TranslationManager
from app.library.music_manager import MusicManager
from app.library.watcher import LibraryWatcher
from app.audio.volume_controller import VolumeController
from app.ui.playlist_controller import PlaylistController
from app.themes.theme_manager import ThemeManager

logger = logging.getLogger(__name__)


class MainWindow(QObject):
    """Main application window controller"""
    
    def __init__(self):
        super().__init__()
        
        self.player = Player()
        self.db = db
        self.settings = SettingsManager()
        self.theme_manager = ThemeManager()
        self.translation = TranslationManager()
        self.volume_controller = VolumeController()
        
        # Initialize database first
        self.db.initialize()
        
        # Now create playlist controller (requires initialized database)
        self.playlist_controller = PlaylistController()
        
        # Now create music manager (requires initialized database and player)
        self.music_manager = MusicManager(player=self.player)

        self.library_watcher = None
        self.scan_timer = QTimer(self)
        self.scan_timer.timeout.connect(self.settings.rescanLibrary)
        self.settings.musicFoldersChanged.connect(self._on_music_folders_changed)
        self.settings.watchFoldersAutomaticallyChanged.connect(self._refresh_library_monitoring)
        self.settings.scanFrequencyChanged.connect(self._refresh_library_monitoring)
        self.settings.libraryStatsChanged.connect(self.music_manager.refreshLibrary)

        self.settings.outputDeviceChanged.connect(self._apply_audio_settings)
        self.settings.audioBufferChanged.connect(self._apply_audio_settings)
        self.player.track_changed.connect(self._on_track_changed)
        self.player.setAudioDevice(self.settings.outputDevice)
        self.player.setAudioBuffer(self.settings.audioBuffer)
        if self.settings.restoreLastPlaylist:
            self.player.restore_session(self.settings.get_last_session())
        self._refresh_library_monitoring()
        
        # Set initial language from settings
        self.translation.set_language(self.settings.language)
        
        # Connect language changes
        self.settings.languageChanged.connect(self._on_language_changed)
        self.settings.themeChanged.connect(self._on_theme_changed)
        self.theme_manager.set_theme(self.settings.theme.lower())
        if self.settings.autoCheckUpdates:
            QTimer.singleShot(0, self.settings.checkForUpdates)
        
        # Setup QML engine
        self._setup_qml()
        # Populate the library without requiring the user to press Scan.
        QTimer.singleShot(1200, self.settings.scanLibrary)
        
        logger.info("Main window initialized")
    
    def _setup_qml(self) -> None:
        """Setup QML interface"""
        # Create QML application engine
        self.engine = QQmlApplicationEngine()
        
        # Expose Python objects to QML BEFORE loading
        self._expose_objects()
        
        # Load QML file
        qml_path = Path(__file__).parent / "qml" / "Main.qml"
        logger.info(f"Loading QML from: {qml_path}")
        self.engine.load(QUrl.fromLocalFile(str(qml_path)))
        
        if not self.engine.rootObjects():
            logger.error("Failed to load QML file")
            logger.error(f"QML path exists: {qml_path.exists()}")
        else:
            logger.info("QML loaded successfully")
            # Show the root window
            root = self.engine.rootObjects()[0]
            root.show()
            if self.settings.startMinimized:
                root.showMinimized()
    
    def _expose_objects(self) -> None:
        """Expose Python objects to QML context"""
        context = self.engine.rootContext()
        
        # Expose assets path
        assets_path = str(Path(__file__).parent.parent.parent / "assets" / "icons")
        context.setContextProperty("assetsPath", assets_path)
        
        # Expose player
        context.setContextProperty("player", self.player)
        
        # Expose database
        context.setContextProperty("database", self.db)
        
        # Expose settings manager
        context.setContextProperty("settings", self.settings)
        context.setContextProperty("theme", self.theme_manager)
        
        # Expose translation manager
        context.setContextProperty("translation", self.translation)
        
        # Expose music manager
        context.setContextProperty("musicManager", self.music_manager)
        context.setContextProperty("libraryManager", self.music_manager)
        
        # Expose volume controller
        context.setContextProperty("volumeController", self.volume_controller)
        
        # Expose playlist controller
        context.setContextProperty("playlistController", self.playlist_controller)
        
        # Expose playlist model
        context.setContextProperty("playlistModel", self.playlist_controller.model)
        
        # Expose main window controller
        context.setContextProperty("mainWindow", self)
    
    def _on_language_changed(self) -> None:
        """Handle language change"""
        self.translation.set_language(self.settings.language)

    def _on_theme_changed(self) -> None:
        self.theme_manager.set_theme(self.settings.theme.lower())

    def _apply_audio_settings(self) -> None:
        self.player.setAudioDevice(self.settings.outputDevice)
        self.player.setAudioBuffer(self.settings.audioBuffer)

    def _refresh_library_monitoring(self) -> None:
        if self.library_watcher and self.library_watcher.is_running():
            self.library_watcher.stop()

        self.library_watcher = LibraryWatcher()
        if self.settings.watchFoldersAutomatically:
            for folder in self.settings.musicFolders:
                self.library_watcher.add_directory(folder, self.music_manager.refreshLibrary)
            if self.library_watcher.handlers:
                self.library_watcher.start()

        intervals = {
            "Every 5 min": 5 * 60 * 1000,
            "Every 15 min": 15 * 60 * 1000,
            "Every hour": 60 * 60 * 1000,
        }
        self.scan_timer.start(intervals.get(self.settings.scanFrequency, 5 * 60 * 1000))

    def _on_music_folders_changed(self) -> None:
        self._refresh_library_monitoring()
        # New folders are indexed in the background as soon as they are added.
        QTimer.singleShot(0, self.settings.scanLibrary)

    def _on_track_changed(self, _path: str) -> None:
        if self.settings.showCurrentlyPlaying:
            self.settings.showNowPlaying(self.player.currentTitle, self.player.currentArtist)
    
    def cleanup(self) -> None:
        """Cleanup resources"""
        if self.settings.rememberLastSession:
            self.settings.save_last_session(self.player.get_session_state())
        if self.library_watcher and self.library_watcher.is_running():
            self.library_watcher.stop()
        self.scan_timer.stop()
        self.settings.wait_for_background_operations()
        self.player.cleanup()
        self.db.close()
