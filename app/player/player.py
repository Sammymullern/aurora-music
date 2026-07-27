"""
MPV-based audio player with advanced features
"""

import logging
from pathlib import Path
from typing import Optional, Callable, List

import mpv
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

logger = logging.getLogger(__name__)


class Player(QObject):
    """Audio player using MPV backend"""
    
    # Signals
    position_changed = Signal(float)  # Current playback position in seconds
    duration_changed = Signal(float)  # Track duration in seconds
    playback_state_changed = Signal(str)  # 'playing', 'paused', 'stopped'
    track_changed = Signal(str)  # Path to current track
    volume_changed = Signal(int)  # Volume level 0-100
    shuffle_changed = Signal(bool)  # Shuffle state
    repeat_changed = Signal(str)  # 'off', 'all', 'one'
    track_info_changed = Signal()  # Track metadata changed
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._mpv: Optional[mpv.MPV] = None
        self._current_track: Optional[Path] = None
        self._volume: int = 100
        self._is_initialized: bool = False
        self._playlist: List[Path] = []
        self._current_index: int = -1
        self._shuffle: bool = False
        self._repeat: str = "off"  # 'off', 'all', 'one'
        self._current_title: str = ""
        self._current_artist: str = ""
        self._current_album: str = ""
        self._current_position: float = 0.0
        self._current_duration: float = 0.0
        
        # Timer for polling position and duration
        self._update_timer = QTimer(self)
        self._update_timer.setInterval(100)  # Update every 100ms
        self._update_timer.timeout.connect(self._update_position_duration)
        
        self._initialize_mpv()
    
    def _initialize_mpv(self) -> None:
        """Initialize MPV player with settings"""
        try:
            self._mpv = mpv.MPV(
                # Audio settings
                audio_format="float",
                audio_wait_open=0,
                # Video settings (disable for audio-only)
                vo="null",
                # Performance
                video_sync="audio",
                # Gapless playback
                gapless_audio=True,
                # Other
                keep_open="no",
            )
            
            self._is_initialized = True
            logger.info("MPV player initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize MPV: {e}")
            self._is_initialized = False
    
    def _update_position_duration(self) -> None:
        """Poll MPV for current position and duration"""
        if not self._is_initialized or not self._mpv:
            return
        
        try:
            # Get current position
            pos = self._mpv.time_pos
            if pos is not None and pos != self._current_position:
                self._current_position = pos
                self.position_changed.emit(pos)
            
            # Get duration
            duration = self._mpv.duration
            if duration is not None and duration != self._current_duration:
                self._current_duration = duration
                self.duration_changed.emit(duration)
        except Exception as e:
            logger.debug(f"Error polling position/duration: {e}")
    
    def load_track(self, track_path: str | Path, title: str = "", artist: str = "", album: str = "") -> bool:
        """Load a track for playback"""
        if not self._is_initialized:
            logger.error("Player not initialized")
            return False
        
        try:
            track_path = Path(track_path)
            if not track_path.exists():
                logger.error(f"Track not found: {track_path}")
                return False
            
            self._current_track = track_path
            self._current_title = title
            self._current_artist = artist
            self._current_album = album
            self._current_position = 0.0
            self._current_duration = 0.0
            
            self._mpv.play(str(track_path))
            self._mpv.pause = True  # Start paused
            
            # Start the update timer
            self._update_timer.start()
            
            self.track_changed.emit(str(track_path))
            self.track_info_changed.emit()
            
            logger.info(f"Loaded track: {track_path}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to load track: {e}")
            return False
    
    def play(self) -> bool:
        """Start or resume playback"""
        if not self._is_initialized:
            return False
        
        try:
            self._mpv.pause = False
            self.playback_state_changed.emit("playing")
            logger.debug("Playback started")
            return True
        except Exception as e:
            logger.error(f"Failed to play: {e}")
            return False
    
    def pause(self) -> bool:
        """Pause playback"""
        if not self._is_initialized:
            return False
        
        try:
            self._mpv.pause = True
            self.playback_state_changed.emit("paused")
            logger.debug("Playback paused")
            return True
        except Exception as e:
            logger.error(f"Failed to pause: {e}")
            return False
    
    def stop(self) -> bool:
        """Stop playback"""
        if not self._is_initialized:
            return False
        
        try:
            self._mpv.pause = True
            self._mpv.seek(0, reference="absolute")
            self.playback_state_changed.emit("stopped")
            logger.debug("Playback stopped")
            return True
        except Exception as e:
            logger.error(f"Failed to stop: {e}")
            return False
    
    def seek(self, position: float) -> bool:
        """Seek to position in seconds"""
        if not self._is_initialized:
            return False
        
        try:
            self._mpv.seek(position, reference="absolute")
            logger.debug(f"Seeked to {position}s")
            return True
        except Exception as e:
            logger.error(f"Failed to seek: {e}")
            return False
    
    def set_volume(self, volume: int) -> bool:
        """Set volume (0-100)"""
        if not self._is_initialized:
            return False
        
        try:
            volume = max(0, min(100, volume))
            self._volume = volume
            self._mpv.volume = volume
            self.volume_changed.emit(volume)
            logger.debug(f"Volume set to {volume}")
            return True
        except Exception as e:
            logger.error(f"Failed to set volume: {e}")
            return False
    
    def get_volume(self) -> int:
        """Get current volume"""
        return self._volume
    
    def get_position(self) -> float:
        """Get current playback position in seconds"""
        if not self._is_initialized:
            return 0.0
        return self._mpv.time_pos or 0.0
    
    def get_duration(self) -> float:
        """Get current track duration in seconds"""
        if not self._is_initialized:
            return 0.0
        return self._mpv.duration or 0.0
    
    def is_playing(self) -> bool:
        """Check if currently playing"""
        if not self._is_initialized:
            return False
        return not self._mpv.pause
    
    def get_current_track(self) -> Optional[Path]:
        """Get current track path"""
        return self._current_track
    
    # QML-exposed methods with Slot decorator
    @Slot()
    def playPause(self) -> None:
        """Toggle play/pause"""
        if self.is_playing():
            self.pause()
        else:
            self.play()
    
    @Slot()
    def stop(self) -> bool:
        """Stop playback"""
        return super().stop()
    
    @Slot()
    def next(self) -> bool:
        """Play next track"""
        return self.next_track()
    
    @Slot()
    def previous(self) -> bool:
        """Play previous track"""
        return self.previous_track()
    
    @Slot()
    def toggleShuffle(self) -> None:
        """Toggle shuffle mode"""
        self.toggle_shuffle()
    
    @Slot()
    def toggleRepeat(self) -> None:
        """Toggle repeat mode"""
        self.toggle_repeat()
    
    @Slot(float)
    def seekTo(self, position: float) -> bool:
        """Seek to position (0.0 to 1.0)"""
        if not self._is_initialized:
            return False
        duration = self.get_duration()
        if duration > 0:
            return self.seek(position * duration)
        return False
    
    @Slot(int)
    def setVolume(self, volume: int) -> bool:
        """Set volume (0-100)"""
        return super().set_volume(volume)
    
    # Properties for QML binding
    def get_isPlaying(self) -> bool:
        return self.is_playing()
    
    def get_isPaused(self) -> bool:
        return not self.is_playing()
    
    def get_currentPosition(self) -> float:
        return self.get_position()
    
    def get_currentDuration(self) -> float:
        return self.get_duration()
    
    def get_currentVolume(self) -> int:
        return self.get_volume()
    
    def get_isShuffle(self) -> bool:
        return self.get_shuffle()
    
    def get_repeatMode(self) -> str:
        return self.get_repeat()
    
    def get_currentTitle(self) -> str:
        return self._current_title
    
    def get_currentArtist(self) -> str:
        return self._current_artist
    
    def get_currentAlbum(self) -> str:
        return self._current_album
    
    isPlaying = Property(bool, get_isPlaying, notify=playback_state_changed)
    isPaused = Property(bool, get_isPaused, notify=playback_state_changed)
    currentPosition = Property(float, get_currentPosition, notify=position_changed)
    currentDuration = Property(float, get_currentDuration, notify=duration_changed)
    currentVolume = Property(int, get_currentVolume, notify=volume_changed)
    isShuffle = Property(bool, get_isShuffle, notify=shuffle_changed)
    repeatMode = Property(str, get_repeatMode, notify=repeat_changed)
    currentTitle = Property(str, get_currentTitle, notify=track_info_changed)
    currentArtist = Property(str, get_currentArtist, notify=track_info_changed)
    currentAlbum = Property(str, get_currentAlbum, notify=track_info_changed)
    
    def set_playlist(self, tracks: List[str | Path]) -> None:
        """Set the playlist"""
        self._playlist = [Path(t) for t in tracks]
        self._current_index = -1
        logger.info(f"Playlist set with {len(self._playlist)} tracks")
    
    def next_track(self) -> bool:
        """Play next track in playlist"""
        if not self._playlist:
            logger.warning("No playlist set")
            return False
        
        if self._shuffle:
            import random
            self._current_index = random.randint(0, len(self._playlist) - 1)
        else:
            self._current_index = (self._current_index + 1) % len(self._playlist)
        
        if self._current_index < len(self._playlist):
            return self.load_track(self._playlist[self._current_index])
        return False
    
    def previous_track(self) -> bool:
        """Play previous track in playlist"""
        if not self._playlist:
            logger.warning("No playlist set")
            return False
        
        self._current_index = (self._current_index - 1) % len(self._playlist)
        
        if self._current_index >= 0:
            return self.load_track(self._playlist[self._current_index])
        return False
    
    def toggle_shuffle(self) -> None:
        """Toggle shuffle mode"""
        self._shuffle = not self._shuffle
        self.shuffle_changed.emit(self._shuffle)
        logger.info(f"Shuffle: {self._shuffle}")
    
    def toggle_repeat(self) -> None:
        """Cycle through repeat modes: off -> all -> one -> off"""
        modes = ["off", "all", "one"]
        current_index = modes.index(self._repeat)
        self._repeat = modes[(current_index + 1) % len(modes)]
        self.repeat_changed.emit(self._repeat)
        logger.info(f"Repeat: {self._repeat}")
    
    def get_shuffle(self) -> bool:
        """Get shuffle state"""
        return self._shuffle
    
    def get_repeat(self) -> str:
        """Get repeat mode"""
        return self._repeat
    
    def cleanup(self) -> None:
        """Clean up resources"""
        self._update_timer.stop()
        if self._mpv:
            self._mpv.terminate()
            self._mpv = None
        self._is_initialized = False
        logger.info("Player cleaned up")
