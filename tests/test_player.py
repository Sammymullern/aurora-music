"""
Tests for audio player
"""

import pytest
from unittest.mock import Mock, patch

from app.player.player import Player


class TestPlayer:
    """Test Player class"""
    
    @patch('app.player.player.mpv.MPV')
    def test_player_initialization(self, mock_mpv):
        """Test player initialization"""
        player = Player()
        assert player._is_initialized
        mock_mpv.assert_called_once()
    
    @patch('app.player.player.mpv.MPV')
    def test_volume_setting(self, mock_mpv):
        """Test volume setting"""
        mock_instance = Mock()
        mock_mpv.return_value = mock_instance
        
        player = Player()
        player.set_volume(50)
        
        assert player.get_volume() == 50
        mock_instance.volume = 50
    
    @patch('app.player.player.mpv.MPV')
    def test_volume_clamping(self, mock_mpv):
        """Test volume is clamped to 0-100"""
        mock_instance = Mock()
        mock_mpv.return_value = mock_instance
        
        player = Player()
        player.set_volume(150)
        assert player.get_volume() == 100
        
        player.set_volume(-50)
        assert player.get_volume() == 0
    
    @patch('app.player.player.mpv.MPV')
    def test_playback_state(self, mock_mpv):
        """Test playback state tracking"""
        mock_instance = Mock()
        mock_instance.pause = False
        mock_mpv.return_value = mock_instance
        
        player = Player()
        assert player.is_playing()
        
        player.pause()
        assert not player.is_playing()
        
        player.play()
        assert player.is_playing()
