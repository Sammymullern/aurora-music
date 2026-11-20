"""
Tests for audio player
"""

import pytest
from concurrent.futures import Future
from pathlib import Path
from types import SimpleNamespace
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

    def test_mpv_end_file_reason_is_read_from_event_data(self):
        eof_event = SimpleNamespace(data=SimpleNamespace(reason=0))
        stopped_event = SimpleNamespace(data=SimpleNamespace(reason=2))

        assert Player._get_mpv_end_file_reason(eof_event) == 0
        assert Player._get_mpv_end_file_reason(stopped_event) == 2

    @patch('app.player.player.mpv.MPV')
    def test_play_playlist_records_selected_index_for_auto_advance(self, mock_mpv, tmp_path):
        first = tmp_path / "first.mp3"
        second = tmp_path / "second.mp3"
        first.touch()
        second.touch()
        mock_mpv.return_value = Mock()

        player = Player()
        assert player.playPlaylist([str(first), str(second)], 1)

        assert player.get_current_index() == 1
        assert player.get_current_track() == second
    
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
        player._current_track = Path("playing.mp3")
        assert player.is_playing()
        
        player.pause()
        assert not player.is_playing()
        
        player.play()
        assert player.is_playing()

    @patch('app.player.player.mpv.MPV')
    def test_natural_end_advances_to_next_playlist_track(self, mock_mpv):
        mock_mpv.return_value = Mock()
        player = Player()
        player.set_playlist(["first.mp3", "second.mp3"])
        player._current_index = 0
        player._play_at_index = Mock(return_value=True)

        assert player._do_auto_advance("test-eof")
        player._play_at_index.assert_called_once_with(1, auto_play=True)

    @patch('app.player.player.mpv.MPV')
    def test_play_after_stop_restarts_the_stopped_playlist_track(self, mock_mpv):
        mock_mpv.return_value = Mock()
        player = Player()
        player.set_playlist(["first.mp3", "second.mp3"])
        player._current_index = 1
        player._current_track = Path("second.mp3")
        player._play_at_index = Mock(return_value=True)

        assert player.stop_playback()
        assert player._current_track is None
        assert player.play()
        player._play_at_index.assert_called_once_with(1, auto_play=True)

    @patch('app.player.player.mpv.MPV')
    def test_auto_advance_respects_repeat_modes_and_playlist_end(self, mock_mpv):
        mock_instance = Mock()
        mock_mpv.return_value = mock_instance
        player = Player()
        player.set_playlist(["first.mp3", "second.mp3"])
        player._current_index = 1
        player._play_at_index = Mock(return_value=True)

        player._repeat = "all"
        assert player._do_auto_advance("test-repeat-all")
        player._play_at_index.assert_called_with(0, auto_play=True)

        player._play_at_index.reset_mock()
        player._advancing = False
        player._current_index = 1
        player._repeat = "one"
        assert player._do_auto_advance("test-repeat-one")
        player._play_at_index.assert_called_once_with(1, auto_play=True)

        player._advancing = False
        player._current_index = 1
        player._repeat = "off"
        assert not player._do_auto_advance("test-end-of-playlist")
        mock_instance.stop.assert_called_once()

    @patch('app.player.player.mpv.MPV')
    def test_shuffle_selects_a_different_track_when_possible(self, mock_mpv):
        mock_mpv.return_value = Mock()
        player = Player()
        player.set_playlist(["first.mp3", "second.mp3", "third.mp3"])
        player._current_index = 1
        player._shuffle = True
        player._play_at_index = Mock(return_value=True)

        assert player.next_track()
        selected_index = player._play_at_index.call_args.args[0]
        assert selected_index in {0, 2}

    @patch('app.player.player.mpv.MPV')
    def test_queued_end_event_is_ignored_if_track_changed_or_user_paused(self, mock_mpv):
        mock_mpv.return_value = Mock()
        player = Player()
        player._last_load_mono = 2
        player._do_auto_advance = Mock()

        player._on_auto_advance_requested(1, "stale-eof")
        player._user_paused = True
        player._on_auto_advance_requested(2, "paused-eof")
        player._do_auto_advance.assert_not_called()

        player._user_paused = False
        player._on_auto_advance_requested(2, "current-eof")
        player._do_auto_advance.assert_called_once_with(source="current-eof")

    @patch('app.player.player.mpv.MPV')
    def test_user_pause_at_track_end_does_not_trigger_watchdog_advance(self, mock_mpv):
        mock_instance = Mock()
        mock_instance.time_pos = 99.9
        mock_instance.duration = 100.0
        mock_instance.pause = True
        mock_instance.eof_reached = True
        mock_instance.end = True
        mock_instance.idle_active = True
        mock_mpv.return_value = mock_instance

        player = Player()
        player._user_paused = True
        player._eof_watchdog_counter = 1
        player._do_auto_advance = Mock()

        player._update_position_duration()

        player._do_auto_advance.assert_not_called()
        assert player._eof_watchdog_counter == 0

    @patch('app.player.player.mpv.MPV')
    def test_seek_is_deferred_until_track_is_loaded(self, mock_mpv):
        mock_instance = Mock()
        mock_instance.duration = 100.0
        mock_mpv.return_value = mock_instance

        player = Player()
        player._current_track = Path("queued-track.mp3")
        player._track_loaded = False

        assert player.seek(42.0)
        mock_instance.seek.assert_not_called()
        assert player._pending_seek_position == 42.0

        player._track_loaded = True
        player._apply_pending_seek()

        mock_instance.seek.assert_called_once_with(42.0, reference="absolute")
        assert player._pending_seek_position is None

    @patch('app.player.player.mpv.MPV')
    def test_equalizer_uses_one_graph_and_updates_only_changed_band(self, mock_mpv):
        mock_instance = Mock()

        def completed_command(*_args):
            future = Future()
            future.set_result(None)
            return future

        mock_instance.command_async.side_effect = completed_command
        mock_mpv.return_value = mock_instance

        player = Player()
        graph_call = mock_instance.command_async.call_args
        assert graph_call.args[:2] == ("af", "add")
        assert graph_call.args[2].count("equalizer@eq") == 10
        assert player._dsp_graph_ready

        player._track_loaded = True
        player._dsp_applied_parameters = player._dsp_current_parameters().copy()
        player._dsp_applied_switches = player.dsp_manager.runtime_switches().copy()
        mock_instance.command_async.reset_mock()

        player.dsp_manager.equalizer.set_band_gain(0, 5.0)
        player._apply_audio_filters()

        mock_instance.command_async.assert_called_once_with(
            "af-command", "nelva_dsp", "gain", "5.0", "equalizer@eq31"
        )

    @patch('app.player.player.mpv.MPV')
    def test_equalizer_reports_mpv_filter_command_failure(self, mock_mpv):
        mock_instance = Mock()
        failed = Future()
        failed.set_exception(RuntimeError("filter rejected"))
        mock_instance.command_async.return_value = failed
        mock_mpv.return_value = mock_instance

        player = Player()

        assert not player._dsp_graph_ready
        assert player.dspStatus == "An audio effect could not be applied"
