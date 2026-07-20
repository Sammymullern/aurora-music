"""
Tests for playback queue
"""

import pytest
from unittest.mock import Mock

from app.player.queue import QueueManager, PlaybackMode
from app.database.models import Track


class TestQueueManager:
    """Test QueueManager class"""
    
    def test_queue_initialization(self):
        """Test queue initialization"""
        queue = QueueManager()
        assert queue.get_queue_length() == 0
        assert queue.get_current_track() is None
        assert queue.get_playback_mode() == PlaybackMode.SEQUENTIAL
    
    def test_add_track(self):
        """Test adding track to queue"""
        queue = QueueManager()
        track = Mock(spec=Track)
        track.title = "Test Track"
        
        queue.add_track(track)
        assert queue.get_queue_length() == 1
    
    def test_add_multiple_tracks(self):
        """Test adding multiple tracks"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(5)]
        
        queue.add_tracks(tracks)
        assert queue.get_queue_length() == 5
    
    def test_play_track_at(self):
        """Test playing track at specific index"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(3)]
        queue.add_tracks(tracks)
        
        result = queue.play_track_at(1)
        assert result is not None
        assert queue.get_current_track() == tracks[1]
    
    def test_next_track_sequential(self):
        """Test next track in sequential mode"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(3)]
        queue.add_tracks(tracks)
        queue.play_track_at(0)
        
        next_track = queue.next_track()
        assert next_track == tracks[1]
    
    def test_next_track_loop(self):
        """Test next track in loop mode"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(3)]
        queue.add_tracks(tracks)
        queue.set_playback_mode(PlaybackMode.LOOP)
        queue.play_track_at(2)
        
        next_track = queue.next_track()
        assert next_track == tracks[0]  # Should loop to start
    
    def test_previous_track(self):
        """Test previous track"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(3)]
        queue.add_tracks(tracks)
        queue.play_track_at(2)
        
        prev_track = queue.previous_track()
        assert prev_track == tracks[1]
    
    def test_clear_queue(self):
        """Test clearing queue"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(3)]
        queue.add_tracks(tracks)
        
        queue.clear_queue()
        assert queue.get_queue_length() == 0
        assert queue.get_current_track() is None
    
    def test_remove_track(self):
        """Test removing track from queue"""
        queue = QueueManager()
        tracks = [Mock(spec=Track) for _ in range(3)]
        queue.add_tracks(tracks)
        
        removed = queue.remove_track(1)
        assert removed is not None
        assert queue.get_queue_length() == 2
    
    def test_playback_mode_change(self):
        """Test changing playback mode"""
        queue = QueueManager()
        queue.set_playback_mode(PlaybackMode.SHUFFLE)
        assert queue.get_playback_mode() == PlaybackMode.SHUFFLE
