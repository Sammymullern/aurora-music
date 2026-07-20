"""
Example plugin demonstrating the plugin system
"""

from app.plugins.base import Plugin, PluginInfo, UIPlugin
from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton
from PySide6.QtCore import QObject


class ExamplePlugin(UIPlugin):
    """Example plugin that adds a simple widget"""
    
    def __init__(self):
        super().__init__()
        self._widget = None
    
    def get_info(self) -> PluginInfo:
        """Return plugin metadata"""
        return PluginInfo(
            name="Example Plugin",
            version="1.0.0",
            description="A simple example plugin demonstrating the plugin system",
            author="Aurora Music Team",
            license="MIT",
            min_app_version="0.1.0"
        )
    
    def initialize(self) -> bool:
        """Initialize the plugin"""
        print("Example plugin initialized")
        return True
    
    def shutdown(self) -> None:
        """Shutdown the plugin"""
        print("Example plugin shutdown")
    
    def get_widget(self):
        """Return the main widget for this plugin"""
        if self._widget is None:
            self._widget = ExampleWidget()
        return self._widget
    
    def get_menu_item(self):
        """Return menu item configuration"""
        return {
            "title": "Example Plugin",
            "action": self._show_widget
        }
    
    def _show_widget(self):
        """Show the plugin widget"""
        widget = self.get_widget()
        widget.show()
    
    def on_track_play(self, track_id: int) -> None:
        """Called when a track starts playing"""
        print(f"Example plugin: Track {track_id} started playing")
    
    def on_library_scanned(self, track_count: int) -> None:
        """Called after library scan completes"""
        print(f"Example plugin: Library scanned, {track_count} tracks found")


class ExampleWidget(QWidget):
    """Example widget for the plugin"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Example Plugin")
        self.setMinimumSize(400, 300)
        
        layout = QVBoxLayout()
        
        label = QLabel("Example Plugin Widget")
        label.setStyleSheet("font-size: 18px; font-weight: bold;")
        layout.addWidget(label)
        
        info_label = QLabel("This is an example plugin demonstrating Aurora's plugin system.")
        layout.addWidget(info_label)
        
        button = QPushButton("Click Me")
        button.clicked.connect(self._on_button_click)
        layout.addWidget(button)
        
        layout.addStretch()
        self.setLayout(layout)
    
    def _on_button_click(self):
        """Handle button click"""
        print("Example plugin button clicked!")
