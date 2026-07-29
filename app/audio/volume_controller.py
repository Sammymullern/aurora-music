"""
System volume controller using PulseAudio
"""

import logging
from typing import Optional

try:
    import pulsectl
    PULSE_AVAILABLE = True
except ImportError:
    PULSE_AVAILABLE = False
    pulsectl = None

from PySide6.QtCore import QObject, Signal, Slot, Property

logger = logging.getLogger(__name__)


class VolumeController(QObject):
    """Controls system volume using PulseAudio"""
    
    volume_changed = Signal(int)  # Volume level 0-100
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._pulse: Optional[pulsectl.Pulse] = None
        self._current_volume: int = 100
        self._is_initialized: bool = False
        
        if PULSE_AVAILABLE:
            self._initialize_pulse()
        else:
            logger.warning("pulsectl not available, system volume control disabled")
    
    def _initialize_pulse(self) -> None:
        """Initialize PulseAudio connection"""
        try:
            self._pulse = pulsectl.Pulse('aurora-music')
            self._is_initialized = True
            logger.info("PulseAudio volume controller initialized")
            
            # Get initial volume
            self._update_current_volume()
        except Exception as e:
            logger.error(f"Failed to initialize PulseAudio: {e}")
            self._is_initialized = False
    
    def _get_default_sink(self):
        """Return default sink object via the correct pulsectl API, or None."""
        if not self._is_initialized or not self._pulse:
            return None
        try:
            name = self._pulse.server_info().default_sink_name
            if not name:
                return None
            return self._pulse.get_sink_by_name(name)
        except Exception as e:
            logger.debug(f"Error resolving default sink: {e}")
            return None

    def _update_current_volume(self) -> None:
        """Update current volume from PulseAudio"""
        sink = self._get_default_sink()
        if not sink:
            return

        try:
            pulse_volume = sink.volume.value_flat
            self._current_volume = int(pulse_volume * 100)
            logger.debug(f"Current system volume: {self._current_volume}%")
        except Exception as e:
            logger.debug(f"Error getting current volume: {e}")

    def get_volume(self) -> int:
        """Get current system volume (0-100)"""
        if not self._is_initialized:
            return self._current_volume

        self._update_current_volume()
        return self._current_volume

    @Slot(int, result=bool)
    def set_volume(self, volume: int) -> bool:
        """Set system volume (0-100)"""
        sink = self._get_default_sink()
        if not sink:
            logger.warning("No default sink found")
            return False

        try:
            volume = max(0, min(100, volume))
            pulse_volume = volume / 100.0

            self._pulse.volume_set_all_chans(sink, pulse_volume)
            self._current_volume = volume
            self.volume_changed.emit(volume)

            logger.debug(f"System volume set to {volume}%")
            return True
        except Exception as e:
            logger.error(f"Failed to set system volume: {e}")
            return False
    
    # CamelCase alias for QML
    @Slot(int, result=bool)
    def setVolume(self, volume: int) -> bool:
        """QML-friendly alias for set_volume"""
        return self.set_volume(volume)

    @Slot(int, result=bool)
    def increase_volume(self, step: int = 5) -> bool:
        """Increase volume by step"""
        return self.set_volume(self._current_volume + step)

    @Slot(int, result=bool)
    def decrease_volume(self, step: int = 5) -> bool:
        """Decrease volume by step"""
        return self.set_volume(self._current_volume - step)
    
    def get_isAvailable(self) -> bool:
        """Check if system volume control is available"""
        return self._is_initialized
    
    # QML property getters
    def get_volume_property(self) -> int:
        return self.get_volume()
    
    isAvailable = Property(bool, get_isAvailable, constant=True)
    volume = Property(int, get_volume_property, notify=volume_changed)
