"""MPV-backed equalizer and audio enhancement state."""

from __future__ import annotations

import logging
import math
from dataclasses import dataclass
from enum import Enum
from typing import Dict, List, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

logger = logging.getLogger(__name__)


class EqualizerPreset(Enum):
    FLAT = "flat"
    ROCK = "rock"
    POP = "pop"
    JAZZ = "jazz"
    CLASSICAL = "classical"
    HIP_HOP = "hip_hop"
    ELECTRONIC = "electronic"
    ACOUSTIC = "acoustic"
    VOCAL = "vocal"
    BASS_BOOST = "bass_boost"
    DEEP_BASS = "deep_bass"
    TREBLE_BOOST = "treble_boost"
    PODCAST = "podcast"
    CUSTOM = "custom"


@dataclass(frozen=True)
class EqualizerBand:
    frequency: float
    q: float
    gain: float


class Equalizer(QObject):
    """Ten peaking bands plus master enable and preamp controls."""

    settings_changed = Signal()
    preset_changed = Signal(str)

    FREQUENCY_BANDS = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    # Slightly broader end bands, with octave-spaced center bands in between.
    BAND_Q = [0.85, 0.95, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.95, 0.85]
    PRESETS: Dict[EqualizerPreset, List[float]] = {
        EqualizerPreset.FLAT: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        EqualizerPreset.ROCK: [4, 3, 2, 1, -1, -1, 2, 3, 4, 4],
        EqualizerPreset.POP: [-1, 1, 3, 4, 2, -1, -1, 1, 3, 3],
        EqualizerPreset.JAZZ: [3, 2, 1, 2, -2, -2, 0, 1, 2, 3],
        EqualizerPreset.CLASSICAL: [4, 3, 2, 1, -1, -1, 0, 2, 3, 4],
        EqualizerPreset.HIP_HOP: [5, 4, 2, 1, -1, -1, 1, 1, 3, 4],
        EqualizerPreset.ELECTRONIC: [4, 3, 1, -1, -2, 1, 0, 2, 3, 4],
        EqualizerPreset.ACOUSTIC: [2, 2, 1, 0, 2, 3, 2, 2, 2, 1],
        EqualizerPreset.VOCAL: [-2, -1, -1, 1, 3, 4, 3, 1, 0, -1],
        EqualizerPreset.BASS_BOOST: [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
        EqualizerPreset.DEEP_BASS: [8, 6, 4, 1, -1, -2, -1, 0, 0, 0],
        EqualizerPreset.TREBLE_BOOST: [0, 0, 0, 0, 0, 1, 2, 4, 5, 5],
        EqualizerPreset.PODCAST: [-4, -2, 0, 2, 4, 4, 3, 1, -1, -3],
    }

    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._bands = [0.0] * len(self.FREQUENCY_BANDS)
        self._enabled = True
        self._preamp = 0.0
        self._current_preset = EqualizerPreset.FLAT
        self._active_preset_name = EqualizerPreset.FLAT.value
        self._custom_presets: Dict[str, List[float]] = {}

    @staticmethod
    def _gain(value: float) -> float:
        try:
            value = float(value)
        except (TypeError, ValueError):
            return 0.0
        if not math.isfinite(value):
            return 0.0
        return round(max(-12.0, min(12.0, value)), 1)

    @Slot(int, float, result=bool)
    def set_band_gain(self, band_index: int, gain: float) -> bool:
        if not 0 <= band_index < len(self._bands):
            return False
        gain = self._gain(gain)
        if self._bands[band_index] == gain and self._current_preset == EqualizerPreset.CUSTOM:
            return True
        self._bands[band_index] = gain
        self._mark_custom()
        self.settings_changed.emit()
        return True

    @Slot(int, result=float)
    def get_band_gain(self, band_index: int) -> float:
        return self._bands[band_index] if 0 <= band_index < len(self._bands) else 0.0

    @Slot(result="QVariantList")
    def get_all_bands(self) -> List[float]:
        return self._bands.copy()

    def set_all_bands(self, gains: List[float]) -> bool:
        if not isinstance(gains, (list, tuple)) or len(gains) != len(self._bands):
            return False
        try:
            self._bands = [self._gain(gain) for gain in gains]
        except (TypeError, ValueError):
            return False
        self._mark_custom()
        self.settings_changed.emit()
        return True

    def _mark_custom(self) -> None:
        self._current_preset = EqualizerPreset.CUSTOM
        self._active_preset_name = EqualizerPreset.CUSTOM.value

    def apply_preset(self, preset: EqualizerPreset) -> bool:
        if preset not in self.PRESETS:
            return False
        self._bands = [float(value) for value in self.PRESETS[preset]]
        self._current_preset = preset
        self._active_preset_name = preset.value
        self.preset_changed.emit(self._active_preset_name)
        self.settings_changed.emit()
        return True

    @Slot(str, result=bool)
    def apply_preset_name(self, preset_name: str) -> bool:
        try:
            preset = EqualizerPreset(preset_name)
        except ValueError:
            preset = None
        if preset in self.PRESETS:
            return self.apply_preset(preset)
        custom = self._custom_presets.get(preset_name)
        if custom is None:
            return False
        self._bands = custom.copy()
        self._current_preset = EqualizerPreset.CUSTOM
        self._active_preset_name = preset_name
        self.preset_changed.emit(preset_name)
        self.settings_changed.emit()
        return True

    def get_current_preset(self) -> EqualizerPreset:
        return self._current_preset

    def reset(self) -> None:
        self.apply_preset(EqualizerPreset.FLAT)

    def set_enabled(self, enabled: bool) -> None:
        enabled = bool(enabled)
        if self._enabled != enabled:
            self._enabled = enabled
            self.settings_changed.emit()

    def is_enabled(self) -> bool:
        return self._enabled

    def set_preamp(self, gain: float) -> None:
        value = self._gain(gain)
        if self._preamp != value:
            self._preamp = value
            self.settings_changed.emit()

    def get_preamp(self) -> float:
        return self._preamp

    def get_current_preset_name(self) -> str:
        return self._active_preset_name

    def set_active_custom_name(self, name: str) -> None:
        self._current_preset = EqualizerPreset.CUSTOM
        self._active_preset_name = name
        self.preset_changed.emit(name)
        self.settings_changed.emit()

    def get_custom_presets(self) -> List[str]:
        return sorted(self._custom_presets, key=str.casefold)

    def load_custom_presets(self, presets: Dict[str, List[float]]) -> None:
        cleaned: Dict[str, List[float]] = {}
        if isinstance(presets, dict):
            for name, gains in presets.items():
                name = str(name).strip()
                if not name or len(name) > 32 or not isinstance(gains, list) or len(gains) != 10:
                    continue
                try:
                    cleaned[name] = [self._gain(gain) for gain in gains]
                except (TypeError, ValueError):
                    continue
        self._custom_presets = cleaned
        self.settings_changed.emit()

    @Slot(str, result=bool)
    def save_custom_preset(self, name: str) -> bool:
        name = str(name).strip()
        if not name or len(name) > 32:
            return False
        if name.casefold() in {preset.value.casefold() for preset in self.PRESETS}:
            return False
        existing = next((key for key in self._custom_presets if key.casefold() == name.casefold()), None)
        if existing is not None and existing != name:
            del self._custom_presets[existing]
        self._custom_presets[name] = self._bands.copy()
        self._current_preset = EqualizerPreset.CUSTOM
        self._active_preset_name = name
        self.preset_changed.emit(name)
        self.settings_changed.emit()
        return True

    @Slot(str, result=bool)
    def delete_custom_preset(self, name: str) -> bool:
        if name not in self._custom_presets:
            return False
        del self._custom_presets[name]
        if self._active_preset_name == name:
            self._mark_custom()
        self.settings_changed.emit()
        return True

    def runtime_parameters(self) -> Dict[str, str]:
        """Values for MPV's existing labeled lavfi filters."""
        gains = self._bands if self._enabled else [0.0] * len(self._bands)
        preamp = self._preamp if self._enabled else 0.0
        values = {"preamp": f"{preamp:.1f}dB"}
        for frequency, gain in zip(self.FREQUENCY_BANDS, gains):
            values[f"band_{frequency}"] = f"{gain:.1f}"
        return values

    @staticmethod
    def initial_filter_graph() -> str:
        filters = ["volume@preamp=0dB"]
        for frequency, q in zip(Equalizer.FREQUENCY_BANDS, Equalizer.BAND_Q):
            filters.append(f"equalizer@eq{frequency}=f={frequency}:t=q:w={q}:g=0")
        filters.extend(
            [
                "bass@bass=f=90:width_type=q:width=0.7:g=0",
                "treble@treble=f=9000:width_type=q:width=0.7:g=0",
                "equalizer@vocal=f=3000:t=q:w=1:g=0",
                "extrastereo@stereo=m=1",
                "alimiter@limiter=limit=0.98:level=false",
            ]
        )
        return (
            f"@nelva_dsp:lavfi=[{','.join(filters)}],"
            "@nelva_spatial:!lavfi=earwax,"
            "@nelva_normalize:!lavfi=dynaudnorm,"
            "@nelva_voice:!lavfi=[highpass=f=200]"
        )

    bands = Property("QVariantList", get_all_bands, notify=settings_changed)
    enabled = Property(bool, is_enabled, set_enabled, notify=settings_changed)
    preamp = Property(float, get_preamp, set_preamp, notify=settings_changed)
    currentPreset = Property(str, get_current_preset_name, notify=settings_changed)
    customPresets = Property("QVariantList", get_custom_presets, notify=settings_changed)


class DSPManager(QObject):
    """Audio enhancement settings and MPV filter parameter generation."""

    settings_changed = Signal()

    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._equalizer = Equalizer(self)
        self._replaygain_enabled = True
        self._replaygain_mode = "track"
        self._replaygain_preamp = 0.0
        self._crossfade_enabled = False
        self._crossfade_duration = 3.0
        self._normalization_enabled = False
        self._voice_enhancement_enabled = False
        self._bass_enabled = False
        self._bass_intensity = 3.0
        self._treble_enabled = False
        self._treble_intensity = 2.0
        self._vocal_enabled = False
        self._vocal_intensity = 2.0
        self._stereo_enabled = False
        self._stereo_width = 125.0
        self._spatial_enabled = False
        self._custom_presets: Dict[str, Dict[str, object]] = {}

    @property
    def equalizer(self) -> Equalizer:
        return self._equalizer

    def set_replaygain_enabled(self, enabled: bool) -> None:
        self._replaygain_enabled = bool(enabled)
        self.settings_changed.emit()

    def is_replaygain_enabled(self) -> bool:
        return self._replaygain_enabled

    def set_replaygain_mode(self, mode: str) -> None:
        if mode in ("track", "album"):
            self._replaygain_mode = mode
            self.settings_changed.emit()

    def get_replaygain_mode(self) -> str:
        return self._replaygain_mode

    def set_replaygain_preamp(self, preamp: float) -> None:
        self._replaygain_preamp = max(-15, min(15, float(preamp)))
        self.settings_changed.emit()

    def get_replaygain_preamp(self) -> float:
        return self._replaygain_preamp

    def set_crossfade_enabled(self, enabled: bool) -> None:
        self._crossfade_enabled = bool(enabled)
        self.settings_changed.emit()

    def is_crossfade_enabled(self) -> bool:
        return self._crossfade_enabled

    def set_crossfade_duration(self, duration: float) -> None:
        self._crossfade_duration = max(0.5, min(12.0, float(duration)))
        self.settings_changed.emit()

    def get_crossfade_duration(self) -> float:
        return self._crossfade_duration

    def set_normalization_enabled(self, enabled: bool) -> None:
        self._normalization_enabled = bool(enabled)
        self.settings_changed.emit()

    def is_normalization_enabled(self) -> bool:
        return self._normalization_enabled

    def set_voice_enhancement_enabled(self, enabled: bool) -> None:
        self._voice_enhancement_enabled = bool(enabled)
        self.settings_changed.emit()

    def is_voice_enhancement_enabled(self) -> bool:
        return self._voice_enhancement_enabled

    def _set_effect(self, attr: str, value: float | bool, low: float = 0.0, high: float = 1.0) -> None:
        if isinstance(value, bool):
            new_value = value
        else:
            try:
                value = float(value)
            except (TypeError, ValueError):
                return
            new_value = round(max(low, min(high, value)), 1) if math.isfinite(value) else low
        if getattr(self, attr) != new_value:
            setattr(self, attr, new_value)
            self.settings_changed.emit()

    def set_bass_enabled(self, value: bool) -> None:
        self._set_effect("_bass_enabled", value)

    def is_bass_enabled(self) -> bool:
        return self._bass_enabled

    def set_bass_intensity(self, value: float) -> None:
        self._set_effect("_bass_intensity", value, 0.0, 8.0)

    def get_bass_intensity(self) -> float:
        return self._bass_intensity

    def set_treble_enabled(self, value: bool) -> None:
        self._set_effect("_treble_enabled", value)

    def is_treble_enabled(self) -> bool:
        return self._treble_enabled

    def set_treble_intensity(self, value: float) -> None:
        self._set_effect("_treble_intensity", value, 0.0, 6.0)

    def get_treble_intensity(self) -> float:
        return self._treble_intensity

    def set_vocal_enabled(self, value: bool) -> None:
        self._set_effect("_vocal_enabled", value)

    def is_vocal_enabled(self) -> bool:
        return self._vocal_enabled

    def set_vocal_intensity(self, value: float) -> None:
        self._set_effect("_vocal_intensity", value, 0.0, 6.0)

    def get_vocal_intensity(self) -> float:
        return self._vocal_intensity

    def set_stereo_enabled(self, value: bool) -> None:
        self._set_effect("_stereo_enabled", value)

    def is_stereo_enabled(self) -> bool:
        return self._stereo_enabled

    def set_stereo_width(self, value: float) -> None:
        self._set_effect("_stereo_width", value, 100.0, 150.0)

    def get_stereo_width(self) -> float:
        return self._stereo_width

    def set_spatial_enabled(self, value: bool) -> None:
        self._set_effect("_spatial_enabled", value)

    def is_spatial_enabled(self) -> bool:
        return self._spatial_enabled

    def runtime_parameters(self) -> Dict[str, str]:
        return {
            "bass": f"{self._bass_intensity if self._bass_enabled else 0.0:.1f}",
            "treble": f"{self._treble_intensity if self._treble_enabled else 0.0:.1f}",
            "vocal": f"{self._vocal_intensity if self._vocal_enabled else 0.0:.1f}",
            "stereo": f"{self._stereo_width / 100.0 if self._stereo_enabled else 1.0:.2f}",
        }

    def get_custom_presets(self) -> List[str]:
        return sorted(self._custom_presets, key=str.casefold)

    def _preset_snapshot(self) -> Dict[str, object]:
        return {
            "bands": self._equalizer.bands,
            "preamp": self._equalizer.preamp,
            "enabled": self._equalizer.enabled,
            "effects": {
                "bass_enabled": self._bass_enabled,
                "bass_intensity": self._bass_intensity,
                "treble_enabled": self._treble_enabled,
                "treble_intensity": self._treble_intensity,
                "vocal_enabled": self._vocal_enabled,
                "vocal_intensity": self._vocal_intensity,
                "stereo_enabled": self._stereo_enabled,
                "stereo_width": self._stereo_width,
                "spatial_enabled": self._spatial_enabled,
            },
        }

    @Slot(str, result=bool)
    def save_custom_preset(self, name: str) -> bool:
        name = str(name).strip()
        if not name or len(name) > 32:
            return False
        if name.casefold() in {preset.value.casefold() for preset in Equalizer.PRESETS}:
            return False
        existing = next((key for key in self._custom_presets if key.casefold() == name.casefold()), None)
        if existing is not None and existing != name:
            del self._custom_presets[existing]
        self._custom_presets[name] = self._preset_snapshot()
        self._equalizer.set_active_custom_name(name)
        self.settings_changed.emit()
        return True

    @Slot(str, result=bool)
    def apply_custom_preset(self, name: str) -> bool:
        preset = self._custom_presets.get(name)
        if not isinstance(preset, dict):
            return False
        if not self._equalizer.set_all_bands(preset.get("bands", [])):
            return False
        self._equalizer.set_preamp(preset.get("preamp", 0.0))
        self._equalizer.set_enabled(preset.get("enabled", True))
        effects = preset.get("effects", {})
        if isinstance(effects, dict):
            for key, value in effects.items():
                if key == "bass_enabled": self.set_bass_enabled(value)
                elif key == "bass_intensity": self.set_bass_intensity(value)
                elif key == "treble_enabled": self.set_treble_enabled(value)
                elif key == "treble_intensity": self.set_treble_intensity(value)
                elif key == "vocal_enabled": self.set_vocal_enabled(value)
                elif key == "vocal_intensity": self.set_vocal_intensity(value)
                elif key == "stereo_enabled": self.set_stereo_enabled(value)
                elif key == "stereo_width": self.set_stereo_width(value)
                elif key == "spatial_enabled": self.set_spatial_enabled(value)
        self._equalizer.set_active_custom_name(name)
        self.settings_changed.emit()
        return True

    @Slot(str, result=bool)
    def delete_custom_preset(self, name: str) -> bool:
        if name not in self._custom_presets:
            return False
        del self._custom_presets[name]
        if self._equalizer.currentPreset == name:
            self._equalizer._mark_custom()
            self._equalizer.settings_changed.emit()
        self.settings_changed.emit()
        return True

    def persistent_settings(self) -> Dict[str, object]:
        return {
            "enabled": self._equalizer.enabled,
            "preamp": self._equalizer.preamp,
            "preset": self._equalizer.currentPreset,
            "bands": self._equalizer.bands,
            "custom_presets": self._custom_presets.copy(),
            "effects": {
                "bass_enabled": self._bass_enabled,
                "bass_intensity": self._bass_intensity,
                "treble_enabled": self._treble_enabled,
                "treble_intensity": self._treble_intensity,
                "vocal_enabled": self._vocal_enabled,
                "vocal_intensity": self._vocal_intensity,
                "stereo_enabled": self._stereo_enabled,
                "stereo_width": self._stereo_width,
                "spatial_enabled": self._spatial_enabled,
            },
        }

    def restore_settings(self, settings: Dict[str, object]) -> None:
        if not isinstance(settings, dict):
            return

        def safe_float(value, default):
            try:
                value = float(value)
                return value if math.isfinite(value) else default
            except (TypeError, ValueError):
                return default

        custom_presets = settings.get("custom_presets", {})
        self._custom_presets = {}
        if isinstance(custom_presets, dict):
            for name, preset in custom_presets.items():
                name = str(name).strip()
                if isinstance(preset, list):
                    preset = {"bands": preset, "preamp": 0.0, "enabled": True, "effects": {}}
                if name and len(name) <= 32 and isinstance(preset, dict):
                    self._custom_presets[name] = preset
        preset = str(settings.get("preset", "flat"))
        bands = settings.get("bands", [0.0] * 10)
        if preset in {item.value for item in Equalizer.PRESETS}:
            self._equalizer.apply_preset_name(preset)
        elif preset in self._custom_presets:
            self.apply_custom_preset(preset)
        else:
            self._equalizer.set_all_bands(bands)
        self._equalizer.set_preamp(safe_float(settings.get("preamp", 0.0), 0.0))
        self._equalizer.set_enabled(settings.get("enabled", True))
        effects = settings.get("effects", {})
        if not isinstance(effects, dict):
            effects = {}
        self._bass_enabled = bool(effects.get("bass_enabled", False))
        self._bass_intensity = max(0.0, min(8.0, safe_float(effects.get("bass_intensity", 3.0), 3.0)))
        self._treble_enabled = bool(effects.get("treble_enabled", False))
        self._treble_intensity = max(0.0, min(6.0, safe_float(effects.get("treble_intensity", 2.0), 2.0)))
        self._vocal_enabled = bool(effects.get("vocal_enabled", False))
        self._vocal_intensity = max(0.0, min(6.0, safe_float(effects.get("vocal_intensity", 2.0), 2.0)))
        self._stereo_enabled = bool(effects.get("stereo_enabled", False))
        self._stereo_width = max(100.0, min(150.0, safe_float(effects.get("stereo_width", 125.0), 125.0)))
        self._spatial_enabled = bool(effects.get("spatial_enabled", False))
        self.settings_changed.emit()

    def get_mpv_audio_filters(self) -> str:
        # The controller installs one stable lavfi graph and changes its named
        # filters through mpv's af-command interface during playback.
        return Equalizer.initial_filter_graph()

    def runtime_switches(self) -> Dict[str, bool]:
        return {
            "spatial": self._spatial_enabled,
            "normalization": self._normalization_enabled,
            "voice": self._voice_enhancement_enabled,
        }

    bassEnabled = Property(bool, is_bass_enabled, set_bass_enabled, notify=settings_changed)
    bassIntensity = Property(float, get_bass_intensity, set_bass_intensity, notify=settings_changed)
    trebleEnabled = Property(bool, is_treble_enabled, set_treble_enabled, notify=settings_changed)
    trebleIntensity = Property(float, get_treble_intensity, set_treble_intensity, notify=settings_changed)
    vocalEnabled = Property(bool, is_vocal_enabled, set_vocal_enabled, notify=settings_changed)
    vocalIntensity = Property(float, get_vocal_intensity, set_vocal_intensity, notify=settings_changed)
    stereoEnabled = Property(bool, is_stereo_enabled, set_stereo_enabled, notify=settings_changed)
    stereoWidth = Property(float, get_stereo_width, set_stereo_width, notify=settings_changed)
    spatialEnabled = Property(bool, is_spatial_enabled, set_spatial_enabled, notify=settings_changed)
    customPresets = Property("QVariantList", get_custom_presets, notify=settings_changed)
