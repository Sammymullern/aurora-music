"""
Main application window with sidebar navigation
"""

import logging
from pathlib import Path

from PySide6.QtCore import QUrl, QObject, Signal
from PySide6.QtQml import QQmlApplicationEngine, QQmlContext

from app.player.player import Player
from app.database.session import db

logger = logging.getLogger(__name__)


class MainWindow(QObject):
    """Main application window controller"""
    
    def __init__(self):
        super().__init__()
        
        self.player = Player()
        self.db = db
        
        # Initialize database
        self.db.initialize()
        
        # Setup QML engine
        self._setup_qml()
        
        logger.info("Main window initialized")
    
    def _setup_qml(self) -> None:
        """Setup QML interface"""
        # Create QML application engine
        self.engine = QQmlApplicationEngine()
        
        # Expose Python objects to QML
        self._expose_objects()
        
        # Load QML file
        qml_path = Path(__file__).parent / "qml" / "Main.qml"
        self.engine.load(QUrl.fromLocalFile(str(qml_path)))
        
        if not self.engine.rootObjects():
            logger.error("Failed to load QML file")
    
    def _expose_objects(self) -> None:
        """Expose Python objects to QML context"""
        context = self.engine.rootContext()
        
        # Expose player
        context.setContextProperty("player", self.player)
        
        # Expose database
        context.setContextProperty("database", self.db)
        
        # Expose main window controller
        context.setContextProperty("mainWindow", self)
    
    def cleanup(self) -> None:
        """Cleanup resources"""
        self.player.cleanup()
        self.db.close()
