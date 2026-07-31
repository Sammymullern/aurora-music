"""
Main application window with sidebar navigation
"""

import logging
from pathlib import Path

from PySide6.QtCore import QUrl, QObject, Signal
from PySide6.QtQml import QQmlApplicationEngine, QQmlContext
from PySide6.QtGui import QGuiApplication

from app.player.player import Player
from app.database.session import db
from app.settings.settings_manager import SettingsManager
from app.i18n.translation_manager import TranslationManager
from app.library.music_manager import MusicManager
from app.audio.volume_controller import VolumeController
from app.ui.playlist_controller import PlaylistController

logger = logging.getLogger(__name__)


class MainWindow(QObject):
    """Main application window controller"""
    
    def __init__(self):
        super().__init__()
        
        self.player = Player()
        self.db = db
        self.settings = SettingsManager()
        self.translation = TranslationManager()
        self.volume_controller = VolumeController()
        
        # Initialize database first
        self.db.initialize()
        
        # Now create playlist controller (requires initialized database)
        self.playlist_controller = PlaylistController()
        
        # Now create music manager (requires initialized database and player)
        self.music_manager = MusicManager(player=self.player)
        
        # Set initial language from settings
        self.translation.set_language(self.settings.language)
        
        # Connect language changes
        self.settings.languageChanged.connect(self._on_language_changed)
        
        # Setup QML engine
        self._setup_qml()
        
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
        
        # Expose translation manager
        context.setContextProperty("translation", self.translation)
        
        # Expose music manager
        context.setContextProperty("musicManager", self.music_manager)
        
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
    
    def cleanup(self) -> None:
        """Cleanup resources"""
        self.player.cleanup()
        self.db.close()
