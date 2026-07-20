"""
Main application window with sidebar navigation
"""

import logging
from pathlib import Path

from PySide6.QtWidgets import QMainWindow, QWidget, QVBoxLayout
from PySide6.QtCore import QUrl, QSize
from PySide6.QtQuickWidgets import QQuickWidget
from PySide6.QtQml import QQmlContext, QQmlEngine

from app.player.player import Player
from app.database.session import db

logger = logging.getLogger(__name__)


class MainWindow(QMainWindow):
    """Main application window"""
    
    def __init__(self):
        super().__init__()
        
        self.player = Player()
        self.db = db
        
        # Initialize database
        self.db.initialize()
        
        # Setup window
        self._setup_window()
        self._setup_qml()
        
        logger.info("Main window initialized")
    
    def _setup_window(self) -> None:
        """Setup window properties"""
        self.setWindowTitle("Aurora Music")
        self.setMinimumSize(1200, 800)
        self.resize(1400, 900)
    
    def _setup_qml(self) -> None:
        """Setup QML interface"""
        # Create QML engine
        self.engine = QQmlEngine()
        
        # Expose Python objects to QML
        self._expose_objects()
        
        # Create QML widget
        self.qml_widget = QQuickWidget()
        self.qml_widget.setResizeMode(QQuickWidget.SizeRootObjectToView)
        self.qml_widget.setSource(QUrl.fromLocalFile(
            str(Path(__file__).parent / "qml" / "Main.qml")
        ))
        
        # Set as central widget
        self.setCentralWidget(self.qml_widget)
    
    def _expose_objects(self) -> None:
        """Expose Python objects to QML context"""
        context = self.engine.rootContext()
        
        # Expose player
        context.setContextProperty("player", self.player)
        
        # Expose database
        context.setContextProperty("database", self.db)
    
    def closeEvent(self, event) -> None:
        """Handle window close event"""
        self.player.cleanup()
        self.db.close()
        super().closeEvent(event)
