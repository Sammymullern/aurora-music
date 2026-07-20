"""
Audio equalizer and DSP features
"""

import logging
from typing import List, Dict, Optional
from enum import Enum
from dataclasses import dataclass

from PySide6.QtCore import QObject, Signal

logger = logging.getLogger(__name__)


class EqualizerPreset(Enum):
    """Equalizer presets"""
    FLAT = "flat"
    BASS_BOOST = "bass_boost"
    TREBLE_BOOST = "treble_boost"
    VOCAL = "vocal"
    ROCK = "rock"
    CLASSICAL = "classical"
    ELECTRONIC = "electronic"
    JAZZ = "jazz"
    POP = "pop"
    CUSTOM = "custom"


@dataclass
class EqualizerBand:
    """Individual equalizer band"""
    frequency: float  # Hz
    gain: float  # dB
    bandwidth: float  # Octaves


class Equalizer(QObject):
    """Audio equalizer with multiple bands"""
    
    # Signals
    settings_changed = Signal()
    preset_changed = Signal(str)
    
    # Standard ISO frequency bands
    FREQUENCY_BANDS = [
        32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000
    ]
    
    # Preset configurations (gain in dB for each band)
    PRESETS = {
        EqualizerPreset.FLAT: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        EqualizerPreset.BASS_BOOST: [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
        EqualizerPreset.TREBLE_BOOST: [0, 0, 0, 0, 0, 0, 2, 4, 5, 6],
        EqualizerPreset.VOCAL: [-2, -1, 0, 2, 4, 4, 2, 0, -1, -2],
        EqualizerPreset.ROCK: [5, 4, 3, 1, -1, -1, 2, 4, 5, 6],
        EqualizerPreset.CLASSICAL: [4, 3, 2, 0, 0, 0, 0, 2, 3, 4],
        EqualizerPreset.ELECTRONIC: [4, 3, 1, 0, -2, -2, 0, 2, 3, 4],
        EqualizerPreset.JAZZ: [2, 2, 1, 2, 2, 0, -1, 0, 1, 2],
        EqualizerPreset.POP: [2, 1, 0, 0, -1, -1, 0, 1, 2, 3],
    }
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._bands: List[float] = [0.0] * 10  # Current gain for each band
        self._current_preset = EqualizerPreset.FLAT
        self._enabled = True
    
    def set_band_gain(self, band_index: int, gain: float) -> bool:
        """Set gain for a specific band (-12 to +12 dB)"""
        if 0 <= band_index < len(self._bands):
            gain = max(-12, min(12, gain))
            self._bands[band_index] = gain
            self._current_preset = EqualizerPreset.CUSTOM
            self.settings_changed.emit()
            logger.debug(f"Band {band_index} gain set to {gain} dB")
            return True
        return False
    
    def get_band_gain(self, band_index: int) -> float:
        """Get gain for a specific band"""
        if 0 <= band_index < len(self._bands):
            return self._bands[band_index]
        return 0.0
    
    def get_all_bands(self) -> List[float]:
        """Get all band gains"""
        return self._bands.copy()
    
    def set_all_bands(self, gains: List[float]) -> bool:
        """Set all band gains"""
        if len(gains) == len(self._bands):
            self._bands = [max(-12, min(12, g)) for g in gains]
            self._current_preset = EqualizerPreset.CUSTOM
            self.settings_changed.emit()
            return True
        return False
    
    def apply_preset(self, preset: EqualizerPreset) -> bool:
        """Apply an equalizer preset"""
        if preset in self.PRESETS:
            self._bands = self.PRESETS[preset].copy()
            self._current_preset = preset
            self.preset_changed.emit(preset.value)
            self.settings_changed.emit()
            logger.info(f"Applied preset: {preset.value}")
            return True
        return False
    
    def get_current_preset(self) -> EqualizerPreset:
        """Get the current preset"""
        return self._current_preset
    
    def reset(self) -> None:
        """Reset to flat"""
        self.apply_preset(EqualizerPreset.FLAT)
    
    def set_enabled(self, enabled: bool) -> None:
        """Enable or disable equalizer"""
        self._enabled = enabled
        logger.debug(f"Equalizer {'enabled' if enabled else 'disabled'}")
    
    def is_enabled(self) -> bool:
        """Check if equalizer is enabled"""
        return self._enabled
    
    def get_mpv_filter_string(self) -> str:
        """Generate MPV filter string for current settings"""
        if not self._enabled:
            return ""
        
        # Build equalizer filter string for MPV
        # MPV uses: equalizer=f=1000:width_type=h:width=1:g=0
        filters = []
        for i, (freq, gain) in enumerate(zip(self.FREQUENCY_BANDS, self._bands)):
            if gain != 0:
                filters.append(f"equalizer=f={freq}:width_type=h:width=1:g={gain}")
        
        return ",".join(filters) if filters else ""


class DSPManager(QObject):
    """Manager for DSP effects"""
    
    # Signals
    settings_changed = Signal()
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._equalizer = Equalizer(self)
        self._replaygain_enabled = True
        self._replaygain_mode = "track"  # "track" or "album"
        self._replaygain_preamp = 0.0  # dB
        self._crossfade_enabled = False
        self._crossfade_duration = 3.0  # seconds
        self._normalization_enabled = False
        self._voice_enhancement_enabled = False
    
    @property
    def equalizer(self) -> Equalizer:
        """Get the equalizer instance"""
        return self._equalizer
    
    def set_replaygain_enabled(self, enabled: bool) -> None:
        """Enable or disable ReplayGain"""
        self._replaygain_enabled = enabled
        self.settings_changed.emit()
    
    def is_replaygain_enabled(self) -> bool:
        """Check if ReplayGain is enabled"""
        return self._replaygain_enabled
    
    def set_replaygain_mode(self, mode: str) -> None:
        """Set ReplayGain mode (track or album)"""
        if mode in ["track", "album"]:
            self._replaygain_mode = mode
            self.settings_changed.emit()
    
    def get_replaygain_mode(self) -> str:
        """Get ReplayGain mode"""
        return self._replaygain_mode
    
    def set_replaygain_preamp(self, preamp: float) -> None:
        """Set ReplayGain preamp in dB"""
        self._replaygain_preamp = max(-15, min(15, preamp))
        self.settings_changed.emit()
    
    def get_replaygain_preamp(self) -> float:
        """Get ReplayGain preamp"""
        return self._replaygain_preamp
    
    def set_crossfade_enabled(self, enabled: bool) -> None:
        """Enable or disable crossfade"""
        self._crossfade_enabled = enabled
        self.settings_changed.emit()
    
    def is_crossfade_enabled(self) -> bool:
        """Check if crossfade is enabled"""
        return self._crossfade_enabled
    
    def set_crossfade_duration(self, duration: float) -> None:
        """Set crossfade duration in seconds"""
        self._crossfade_duration = max(0.5, min(12.0, duration))
        self.settings_changed.emit()
    
    def get_crossfade_duration(self) -> float:
        """Get crossfade duration"""
        return self._crossfade_duration
    
    def set_normalization_enabled(self, enabled: bool) -> None:
        """Enable or disable audio normalization"""
        self._normalization_enabled = enabled
        self.settings_changed.emit()
    
    def is_normalization_enabled(self) -> bool:
        """Check if normalization is enabled"""
        return self._normalization_enabled
    
    def set_voice_enhancement_enabled(self, enabled: bool) -> None:
        """Enable or disable voice enhancement"""
        self._voice_enhancement_enabled = enabled
        self.settings_changed.emit()
    
    def is_voice_enhancement_enabled(self) -> bool:
        """Check if voice enhancement is enabled"""
        return self._voice_enhancement_enabled
    
    def get_mpv_audio_filters(self) -> str:
        """Generate complete MPV audio filter string"""
        filters = []
        
        # Add equalizer
        eq_filter = self._equalizer.get_mpv_filter_string()
        if eq_filter:
            filters.append(eq_filter)
        
        # Add normalization
        if self._normalization_enabled:
            filters.append("dynaudnorm")
        
        # Add voice enhancement
        if self._voice_enhancement_enabled:
            filters.append("highpass=f=200")
        
        return ",".join(filters) if filters else ""
