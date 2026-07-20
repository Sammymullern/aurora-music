"""
Base plugin interface
"""

import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional, List, Dict, Any
from pathlib import Path

from PySide6.QtCore import QObject

logger = logging.getLogger(__name__)


@dataclass
class PluginInfo:
    """Plugin metadata"""
    name: str
    version: str
    description: str
    author: str
    license: str
    min_app_version: str = "0.1.0"
    dependencies: Optional[List[str]] = None


class Plugin(QObject):
    """Base class for all plugins"""
    
    def __init__(self):
        super().__init__()
        self._enabled = False
        self._info: Optional[PluginInfo] = None
    
    @abstractmethod
    def get_info(self) -> PluginInfo:
        """Return plugin metadata"""
        pass
    
    @abstractmethod
    def initialize(self) -> bool:
        """Initialize the plugin"""
        pass
    
    @abstractmethod
    def shutdown(self) -> None:
        """Shutdown the plugin"""
        pass
    
    def enable(self) -> bool:
        """Enable the plugin"""
        if not self._enabled:
            if self.initialize():
                self._enabled = True
                logger.info(f"Plugin enabled: {self.get_info().name}")
                return True
        return False
    
    def disable(self) -> None:
        """Disable the plugin"""
        if self._enabled:
            self.shutdown()
            self._enabled = False
            logger.info(f"Plugin disabled: {self.get_info().name}")
    
    def is_enabled(self) -> bool:
        """Check if plugin is enabled"""
        return self._enabled
    
    def on_track_play(self, track_id: int) -> None:
        """Called when a track starts playing"""
        pass
    
    def on_track_pause(self, track_id: int) -> None:
        """Called when a track is paused"""
        pass
    
    def on_track_stop(self, track_id: int) -> None:
        """Called when a track stops"""
        pass
    
    def on_playlist_created(self, playlist_id: int) -> None:
        """Called when a playlist is created"""
        pass
    
    def on_library_scanned(self, track_count: int) -> None:
        """Called after library scan completes"""
        pass


class UIPlugin(Plugin):
    """Base class for UI plugins"""
    
    @abstractmethod
    def get_widget(self):
        """Return the main widget for this plugin"""
        pass
    
    @abstractmethod
    def get_menu_item(self) -> Optional[Dict[str, Any]]:
        """Return menu item configuration (optional)"""
        pass


class AudioPlugin(Plugin):
    """Base class for audio processing plugins"""
    
    @abstractmethod
    def process_audio(self, audio_data: bytes) -> bytes:
        """Process audio data"""
        pass
    
    @abstractmethod
    def get_audio_filters(self) -> List[str]:
        """Return list of audio filter strings"""
        pass


class MetadataPlugin(Plugin):
    """Base class for metadata plugins"""
    
    @abstractmethod
    def fetch_metadata(self, artist: str, album: str, title: str) -> Dict[str, Any]:
        """Fetch metadata from external source"""
        pass
    
    @abstractmethod
    def fetch_artwork(self, artist: str, album: str) -> Optional[bytes]:
        """Fetch artwork from external source"""
        pass
