#!/usr/bin/env python3
# Set locale to C BEFORE any imports to prevent numpy/scipy/librosa crashes
import locale
import os
os.environ['LC_ALL'] = 'C'
os.environ['LC_NUMERIC'] = 'C'
try:
    locale.setlocale(locale.LC_ALL, 'C')
    locale.setlocale(locale.LC_NUMERIC, 'C')
except locale.Error:
    pass

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
    
    # Create main window controller
    window = MainWindow()
    
    # Handle application quit
    app.aboutToQuit.connect(window.cleanup)
    
    # Run application
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
