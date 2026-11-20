"""
Tests for equalizer and DSP
"""

import pytest

from app.player.equalizer import Equalizer, EqualizerPreset, DSPManager


class TestEqualizer:
    """Test Equalizer class"""
    
    def test_equalizer_initialization(self):
        """Test equalizer initializes with flat preset"""
        eq = Equalizer()
        assert eq.get_current_preset() == EqualizerPreset.FLAT
        assert all(g == 0 for g in eq.get_all_bands())
    
    def test_set_band_gain(self):
        """Test setting individual band gain"""
        eq = Equalizer()
        eq.set_band_gain(0, 5.0)
        assert eq.get_band_gain(0) == 5.0
    
    def test_band_gain_clamping(self):
        """Test band gain is clamped to -12 to +12 dB"""
        eq = Equalizer()
        eq.set_band_gain(0, 20.0)
        assert eq.get_band_gain(0) == 12.0
        
        eq.set_band_gain(0, -20.0)
        assert eq.get_band_gain(0) == -12.0
    
    def test_apply_preset(self):
        """Test applying presets"""
        eq = Equalizer()
        eq.apply_preset(EqualizerPreset.BASS_BOOST)
        assert eq.get_current_preset() == EqualizerPreset.BASS_BOOST
        assert eq.get_band_gain(0) > 0  # First band should be boosted
    
    def test_reset(self):
        """Test reset to flat"""
        eq = Equalizer()
        eq.apply_preset(EqualizerPreset.BASS_BOOST)
        eq.reset()
        assert eq.get_current_preset() == EqualizerPreset.FLAT
        assert all(g == 0 for g in eq.get_all_bands())
    
    def test_enable_disable(self):
        """Test enabling/disabling equalizer"""
        eq = Equalizer()
        assert eq.is_enabled()
        
        eq.set_enabled(False)
        assert not eq.is_enabled()
        
        eq.set_enabled(True)
        assert eq.is_enabled()

    def test_ten_bands_use_requested_centers_and_bounds(self):
        eq = Equalizer()
        assert eq.FREQUENCY_BANDS == [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        assert eq.get_all_bands() == [0.0] * 10
        assert eq.set_band_gain(0, 14)
        assert eq.get_band_gain(0) == 12.0
        assert eq.set_band_gain(9, -14)
        assert eq.get_band_gain(9) == -12.0

    def test_professional_builtin_presets_are_available(self):
        eq = Equalizer()
        expected = {
            "flat", "rock", "pop", "jazz", "classical", "hip_hop", "electronic",
            "acoustic", "vocal", "bass_boost", "deep_bass", "treble_boost", "podcast",
        }
        for name in expected:
            assert eq.apply_preset_name(name)
            assert eq.get_current_preset() != EqualizerPreset.FLAT or name == "flat"

    def test_custom_presets_can_be_saved_applied_overwritten_and_deleted(self):
        eq = Equalizer()
        eq.set_band_gain(2, 4.5)
        assert eq.save_custom_preset("Warm")
        eq.set_band_gain(2, -2)
        assert eq.apply_preset_name("Warm")
        assert eq.get_band_gain(2) == 4.5
        eq.set_band_gain(3, 2.0)
        assert eq.save_custom_preset("Warm")
        assert eq._custom_presets["Warm"] == eq.get_all_bands()
        assert eq.delete_custom_preset("Warm")
        assert not eq.apply_preset_name("Warm")

    def test_master_bypass_neutralizes_bands_and_preamp(self):
        eq = Equalizer()
        eq.apply_preset_name("rock")
        eq.set_preamp(-4)
        assert eq.runtime_parameters()["band_31"] == "4.0"
        assert eq.runtime_parameters()["preamp"] == "-4.0dB"
        eq.set_enabled(False)
        assert all(eq.runtime_parameters()[f"band_{frequency}"] == "0.0" for frequency in eq.FREQUENCY_BANDS)
        assert eq.runtime_parameters()["preamp"] == "0.0dB"


class TestDSPManager:
    """Test DSPManager class"""
    
    def test_dsp_initialization(self):
        """Test DSP manager initialization"""
        dsp = DSPManager()
        assert dsp.equalizer is not None
        assert dsp.is_replaygain_enabled()
        assert not dsp.is_crossfade_enabled()
    
    def test_replaygain_settings(self):
        """Test ReplayGain settings"""
        dsp = DSPManager()
        dsp.set_replaygain_enabled(False)
        assert not dsp.is_replaygain_enabled()
        
        dsp.set_replaygain_mode("album")
        assert dsp.get_replaygain_mode() == "album"
        
        dsp.set_replaygain_preamp(3.0)
        assert dsp.get_replaygain_preamp() == 3.0
    
    def test_crossfade_settings(self):
        """Test crossfade settings"""
        dsp = DSPManager()
        dsp.set_crossfade_enabled(True)
        assert dsp.is_crossfade_enabled()
        
        dsp.set_crossfade_duration(5.0)
        assert dsp.get_crossfade_duration() == 5.0
    
    def test_normalization_settings(self):
        """Test normalization settings"""
        dsp = DSPManager()
        dsp.set_normalization_enabled(True)
        assert dsp.is_normalization_enabled()

    def test_initial_filter_graph_is_labeled_and_has_limiter(self):
        dsp = DSPManager()
        graph = dsp.get_mpv_audio_filters()
        assert graph.startswith("@nelva_dsp:lavfi=[volume@preamp=0dB")
        assert "equalizer@eq31=f=31:t=q" in graph
        assert "equalizer@eq16000=f=16000:t=q" in graph
        assert "alimiter@limiter=limit=0.98" in graph
        assert "@nelva_spatial:!lavfi=earwax" in graph

    def test_enhancement_controls_produce_independent_filter_values(self):
        dsp = DSPManager()
        dsp.set_bass_enabled(True)
        dsp.set_bass_intensity(5.5)
        dsp.set_treble_enabled(True)
        dsp.set_treble_intensity(3)
        dsp.set_vocal_enabled(True)
        dsp.set_stereo_enabled(True)
        dsp.set_stereo_width(140)
        dsp.set_spatial_enabled(True)
        assert dsp.runtime_parameters() == {
            "bass": "5.5", "treble": "3.0", "vocal": "2.0", "stereo": "1.40"
        }
        assert dsp.runtime_switches() == {
            "spatial": True, "normalization": False, "voice": False
        }

    def test_persistent_state_restores_effects_and_custom_presets(self):
        source = DSPManager()
        source.equalizer.set_band_gain(1, -3.5)
        source.equalizer.set_preamp(-2)
        source.set_bass_enabled(True)
        source.set_bass_intensity(6)
        source.save_custom_preset("Desk")

        restored = DSPManager()
        restored.restore_settings(source.persistent_settings())
        assert restored.equalizer.get_band_gain(1) == -3.5
        assert restored.equalizer.preamp == -2
        assert restored.customPresets == ["Desk"]
        assert restored.bassEnabled
        assert restored.bassIntensity == 6

    def test_custom_preset_restores_effects_and_preamp(self):
        dsp = DSPManager()
        dsp.equalizer.set_band_gain(3, 2.0)
        dsp.equalizer.set_preamp(-1.5)
        dsp.set_vocal_enabled(True)
        dsp.set_vocal_intensity(4)
        assert dsp.save_custom_preset("Studio")

        dsp.equalizer.set_band_gain(3, -4.0)
        dsp.equalizer.set_preamp(3)
        dsp.set_vocal_enabled(False)
        assert dsp.apply_custom_preset("Studio")
        assert dsp.equalizer.get_band_gain(3) == 2.0
        assert dsp.equalizer.preamp == -1.5
        assert dsp.vocalEnabled
        assert dsp.vocalIntensity == 4
