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
    
    def _update_current_volume(self) -> None:
        """Update current volume from PulseAudio"""
        if not self._is_initialized or not self._pulse:
            return
        
        try:
            # Get default sink
            sink = self._pulse.get_default_sink()
            if sink:
                # Convert pulse volume to 0-100 scale
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
    
    @Slot(int)
    def set_volume(self, volume: int) -> bool:
        """Set system volume (0-100)"""
        if not self._is_initialized:
            logger.warning("Volume controller not initialized")
            return False
        
        try:
            volume = max(0, min(100, volume))
            
            # Get default sink
            sink = self._pulse.get_default_sink()
            if not sink:
                logger.warning("No default sink found")
                return False
            
            # Convert to pulse volume (0.0-1.0)
            pulse_volume = volume / 100.0
            
            # Set volume
            self._pulse.volume_set_all_channels(sink, pulse_volume)
            self._current_volume = volume
            self.volume_changed.emit(volume)
            
            logger.debug(f"System volume set to {volume}%")
            return True
        except Exception as e:
            logger.error(f"Failed to set system volume: {e}")
            return False
    
    # CamelCase alias for QML
    def setVolume(self, volume: int) -> bool:
        """QML-friendly alias for set_volume"""
        return self.set_volume(volume)
    
    def increase_volume(self, step: int = 5) -> bool:
        """Increase volume by step"""
        return self.set_volume(self._current_volume + step)
    
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
