"""
Playback queue management
"""

import logging
from typing import List, Optional
from enum import Enum

from PySide6.QtCore import QObject, Signal

from app.database.models import Track

logger = logging.getLogger(__name__)


class PlaybackMode(Enum):
    """Playback mode options"""
    SEQUENTIAL = "sequential"
    LOOP = "loop"
    SHUFFLE = "shuffle"
    LOOP_SINGLE = "loop_single"


class QueueManager(QObject):
    """Manager for playback queue"""
    
    # Signals
    queue_changed = Signal()
    current_track_changed = Signal()
    playback_mode_changed = Signal(str)
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._queue: List[Track] = []
        self._current_index: int = -1
        self._playback_mode = PlaybackMode.SEQUENTIAL
        self._history: List[Track] = []
    
    def add_track(self, track: Track) -> None:
        """Add a track to the queue"""
        self._queue.append(track)
        self.queue_changed.emit()
        logger.debug(f"Added track to queue: {track.title}")
    
    def add_tracks(self, tracks: List[Track]) -> None:
        """Add multiple tracks to the queue"""
        self._queue.extend(tracks)
        self.queue_changed.emit()
        logger.debug(f"Added {len(tracks)} tracks to queue")
    
    def insert_track(self, track: Track, position: int) -> None:
        """Insert a track at a specific position"""
        if 0 <= position <= len(self._queue):
            self._queue.insert(position, track)
            self.queue_changed.emit()
    
    def remove_track(self, position: int) -> Optional[Track]:
        """Remove a track from the queue"""
        if 0 <= position < len(self._queue):
            track = self._queue.pop(position)
            if position == self._current_index:
                self._current_index = -1
            elif position < self._current_index:
                self._current_index -= 1
            self.queue_changed.emit()
            return track
        return None
    
    def clear_queue(self) -> None:
        """Clear all tracks from the queue"""
        self._queue.clear()
        self._current_index = -1
        self.queue_changed.emit()
        logger.debug("Queue cleared")
    
    def get_queue(self) -> List[Track]:
        """Get the current queue"""
        return self._queue.copy()
    
    def get_current_track(self) -> Optional[Track]:
        """Get the currently playing track"""
        if 0 <= self._current_index < len(self._queue):
            return self._queue[self._current_index]
        return None
    
    def play_track_at(self, index: int) -> Optional[Track]:
        """Play a track at a specific index"""
        if 0 <= index < len(self._queue):
            # Add current track to history
            if self._current_index >= 0:
                self._history.append(self._queue[self._current_index])
            
            self._current_index = index
            self.current_track_changed.emit()
            return self._queue[index]
        return None
    
    def next_track(self) -> Optional[Track]:
        """Get the next track"""
        if not self._queue:
            return None
        
        if self._playback_mode == PlaybackMode.LOOP_SINGLE:
            return self.get_current_track()
        
        if self._playback_mode == PlaybackMode.SHUFFLE:
            import random
            next_index = random.randint(0, len(self._queue) - 1)
            return self.play_track_at(next_index)
        
        next_index = self._current_index + 1
        if next_index >= len(self._queue):
            if self._playback_mode == PlaybackMode.LOOP:
                next_index = 0
            else:
                return None
        
        return self.play_track_at(next_index)
    
    def previous_track(self) -> Optional[Track]:
        """Get the previous track"""
        if not self._queue:
            return None
        
        if self._history:
            prev_track = self._history.pop()
            prev_index = self._queue.index(prev_track)
            return self.play_track_at(prev_index)
        
        prev_index = self._current_index - 1
        if prev_index < 0:
            if self._playback_mode == PlaybackMode.LOOP:
                prev_index = len(self._queue) - 1
            else:
                return None
        
        return self.play_track_at(prev_index)
    
    def set_playback_mode(self, mode: PlaybackMode) -> None:
        """Set the playback mode"""
        self._playback_mode = mode
        self.playback_mode_changed.emit(mode.value)
        logger.info(f"Playback mode set to: {mode.value}")
    
    def get_playback_mode(self) -> PlaybackMode:
        """Get the current playback mode"""
        return self._playback_mode
    
    def get_queue_length(self) -> int:
        """Get the number of tracks in the queue"""
        return len(self._queue)
