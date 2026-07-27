"""
Music Manager for Aurora Music
Handles music library queries and operations
"""
import logging
from datetime import datetime
from typing import List, Dict, Any, Optional
from PySide6.QtCore import QObject, Signal, Property, Slot

from app.database.session import db
from app.database.models import Track, Artist, Album

logger = logging.getLogger(__name__)


class MusicManager(QObject):
    """Manages music library queries and operations for QML"""
    
    # Signals for QML binding
    songsChanged = Signal()
    songCountChanged = Signal()
    
    def __init__(self):
        super().__init__()
        self._songs = []
        self._song_count = 0
        self._current_filter = "all"  # all, favorites, recently_added, high_rating
        self._search_query = ""  # Search query string
        self._load_songs()
        # Update missing durations on init
        self.updateMissingDurations()
    
    def _load_songs(self):
        """Load songs from database based on current filter and search query"""
        session = db.get_session()
        try:
            query = session.query(Track)
            
            # Apply search filter if query exists
            if self._search_query and self._search_query.strip():
                search_term = f"%{self._search_query.strip()}%"
                query = query.filter(
                    (Track.title.ilike(search_term)) |
                    (Track.file_name.ilike(search_term))
                )
            
            # Apply filter
            if self._current_filter == "favorites":
                query = query.filter(Track.favorite == True)
                query = query.order_by(Track.title)
            elif self._current_filter == "recently_added":
                # Songs added in the last 30 days
                from datetime import timedelta
                thirty_days_ago = datetime.utcnow() - timedelta(days=30)
                query = query.filter(Track.added_at >= thirty_days_ago)
                query = query.order_by(Track.added_at.desc())
            elif self._current_filter == "high_rating":
                # Most played, max 15
                query = query.order_by(Track.play_count.desc()).limit(15)
            else:
                # All songs, default order
                query = query.order_by(Track.title)
            
            tracks = query.all()
            self._songs = []
            for track in tracks:
                self._songs.append({
                    "id": track.id,
                    "title": track.title or track.file_name,
                    "artist": track.artist.name if track.artist else "Unknown",
                    "album": track.album.title if track.album else "Unknown",
                    "duration": self._format_duration(track.duration) if track.duration else "0:00",
                    "file_path": track.file_path,
                    "favorite": track.favorite,
                    "play_count": track.play_count
                })
            self._song_count = len(self._songs)
            logger.info(f"Loaded {self._song_count} songs from database (filter: {self._current_filter})")
        finally:
            session.close()
    
    @staticmethod
    def _format_duration(seconds: Optional[float]) -> str:
        """Format duration in seconds to MM:SS"""
        if seconds is None:
            return "0:00"
        minutes = int(seconds // 60)
        secs = int(seconds % 60)
        return f"{minutes}:{secs:02d}"
    
    def get_songs(self) -> List[Dict[str, Any]]:
        """Get all songs"""
        return self._songs
    
    def get_song_count(self) -> int:
        """Get total song count"""
        return self._song_count
    
    songs = Property('QVariantList', get_songs, notify=songsChanged)
    songCount = Property(int, get_song_count, notify=songCountChanged)
    
    @Slot(str)
    def setFilter(self, filter_name: str):
        """Set the current filter and reload songs"""
        if filter_name in ["all", "favorites", "recently_added", "high_rating"]:
            self._current_filter = filter_name
            self._load_songs()
            self.songsChanged.emit()
            self.songCountChanged.emit()
    
    @Slot(str)
    def setSearchQuery(self, query: str):
        """Set the search query and reload songs"""
        self._search_query = query
        self._load_songs()
        self.songsChanged.emit()
        self.songCountChanged.emit()
    
    @Slot(str)
    def toggleFavorite(self, song_id: str):
        """Toggle favorite status for a song"""
        session = db.get_session()
        try:
            track = session.query(Track).filter(Track.id == int(song_id)).first()
            if track:
                track.favorite = not track.favorite
                session.commit()
                self._load_songs()
                self.songsChanged.emit()
                logger.info(f"Toggled favorite for song {song_id}: {track.favorite}")
        finally:
            session.close()
    
    @Slot(str)
    def playSong(self, song_id: str):
        """Play a song by ID and increment play count"""
        session = db.get_session()
        try:
            track = session.query(Track).filter(Track.id == int(song_id)).first()
            if track:
                track.play_count += 1
                track.last_played = datetime.utcnow()
                session.commit()
                logger.info(f"Playing song: {song_id}, play count: {track.play_count}")
                # TODO: Connect to player
                self._load_songs()
                self.songsChanged.emit()
        finally:
            session.close()
    
    @Slot()
    def refreshLibrary(self):
        """Refresh the library from database"""
        self._load_songs()
        self.songsChanged.emit()
        self.songCountChanged.emit()
    
    @Slot()
    def updateMissingDurations(self):
        """Update duration for tracks that are missing it"""
        from app.metadata.extractor import MetadataExtractor
        from pathlib import Path
        
        session = db.get_session()
        try:
            # Get tracks without duration
            tracks = session.query(Track).filter(Track.duration.is_(None)).all()
            extractor = MetadataExtractor()
            
            updated_count = 0
            for track in tracks:
                file_path = Path(track.file_path)
                if file_path.exists():
                    metadata = extractor.extract(file_path)
                    if metadata and metadata.get("duration"):
                        track.duration = metadata["duration"]
                        updated_count += 1
            
            session.commit()
            logger.info(f"Updated duration for {updated_count} tracks")
            self._load_songs()
            self.songsChanged.emit()
        finally:
            session.close()
