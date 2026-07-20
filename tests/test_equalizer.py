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
