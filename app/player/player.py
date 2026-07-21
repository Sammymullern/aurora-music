"""
MPV-based audio player with advanced features
"""

import logging
from pathlib import Path
from typing import Optional, Callable

import mpv
from PySide6.QtCore import QObject, Signal

logger = logging.getLogger(__name__)


class Player(QObject):
    """Audio player using MPV backend"""
    
    # Signals
    position_changed = Signal(float)  # Current playback position in seconds
    duration_changed = Signal(float)  # Track duration in seconds
    playback_state_changed = Signal(str)  # 'playing', 'paused', 'stopped'
    track_changed = Signal(str)  # Path to current track
    volume_changed = Signal(int)  # Volume level 0-100
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._mpv: Optional[mpv.MPV] = None
        self._current_track: Optional[Path] = None
        self._volume: int = 100
        self._is_initialized: bool = False
        
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
            
            # Set up event handlers with error handling
            try:
                self._mpv.observe("time-pos", self._on_position_changed)
            except Exception as e:
                logger.warning(f"Could not observe time-pos: {e}")
            
            try:
                self._mpv.observe("duration", self._on_duration_changed)
            except Exception as e:
                logger.warning(f"Could not observe duration: {e}")
            
            try:
                self._mpv.observe("pause", self._on_pause_changed)
            except Exception as e:
                logger.warning(f"Could not observe pause: {e}")
            
            self._is_initialized = True
            logger.info("MPV player initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize MPV: {e}")
            self._is_initialized = False
    
    def _on_position_changed(self, pos: Optional[float]) -> None:
        """Handle position change event"""
        if pos is not None:
            self.position_changed.emit(pos)
    
    def _on_duration_changed(self, duration: Optional[float]) -> None:
        """Handle duration change event"""
        if duration is not None:
            self.duration_changed.emit(duration)
    
    def _on_pause_changed(self, paused: bool) -> None:
        """Handle pause state change event"""
        if paused:
            self.playback_state_changed.emit("paused")
        else:
            self.playback_state_changed.emit("playing")
    
    def load_track(self, track_path: str | Path) -> bool:
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
            self._mpv.play(str(track_path))
            self._mpv.pause = True  # Start paused
            self.track_changed.emit(str(track_path))
            
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
    
    def cleanup(self) -> None:
        """Clean up resources"""
        if self._mpv:
            self._mpv.terminate()
            self._mpv = None
        self._is_initialized = False
        logger.info("Player cleaned up")
