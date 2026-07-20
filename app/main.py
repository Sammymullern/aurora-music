#!/usr/bin/env python3
"""
Main entry point for Aurora Music application
"""

import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication
from PySide6.QtCore import QSettings, Qt

from app.ui.main_window import MainWindow


def main():
    """Main application entry point"""
    # Enable high DPI scaling
    QApplication.setHighDpiScaleFactorRoundingPolicy(
        Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
    )
    
    # Create application instance
    app = QApplication(sys.argv)
    app.setApplicationName("Aurora Music")
    app.setApplicationVersion("0.1.0")
    app.setOrganizationName("Aurora Music")
    
    # Set up application settings
    settings = QSettings()
    
    # Create and show main window
    window = MainWindow()
    window.show()
    
    # Run application
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
