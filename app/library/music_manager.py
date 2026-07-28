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
    
    def __init__(self, player=None):
        super().__init__()
        self._songs = []
        self._song_count = 0
        self._current_filter = "all"  # all, favorites, recently_added, high_rating
        self._search_query = ""  # Search query string
        self._player = player  # Player instance for playback
        self._load_songs()
        # Update missing durations on init
        self.updateMissingDurations()
    
    def _load_songs(self):
        """Load songs from database based on current filter and search query"""
        session = db.get_session()
        try:
            query = session.query(Track)
            logger.info(f"Starting query with filter: {self._current_filter}, search: {self._search_query}")
            
            # Apply search filter if query exists
            if self._search_query and self._search_query.strip():
                search_term = f"%{self._search_query.strip()}%"
                query = query.filter(
                    (Track.title.ilike(search_term)) |
                    (Track.file_name.ilike(search_term))
                )
                logger.info(f"Applied search filter: {search_term}")
            
            # Apply filter
            if self._current_filter == "favorites":
                query = query.filter(Track.favorite == True)
                query = query.order_by(Track.title)
                logger.info("Applied favorites filter")
            elif self._current_filter == "recently_added":
                # Songs added in the last 30 days
                from datetime import timedelta
                thirty_days_ago = datetime.utcnow() - timedelta(days=30)
                query = query.filter(Track.added_at >= thirty_days_ago)
                query = query.order_by(Track.added_at.desc())
                logger.info(f"Applied recently_added filter (since {thirty_days_ago})")
            elif self._current_filter == "high_rating":
                # Most played, max 15
                query = query.order_by(Track.play_count.desc()).limit(15)
                logger.info("Applied high_rating filter (top 15)")
            else:
                # All songs, default order
                query = query.order_by(Track.title)
                logger.info("Applied all filter (no restriction)")
            
            tracks = query.all()
            logger.info(f"Query returned {len(tracks)} tracks")
            
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
        logger.info(f"setFilter called with: {filter_name}")
        if filter_name in ["all", "favorites", "recently_added", "high_rating"]:
            self._current_filter = filter_name
            logger.info(f"Filter set to: {self._current_filter}")
            self._load_songs()
            logger.info(f"Loaded {self._song_count} songs after filter")
            self.songsChanged.emit()
            self.songCountChanged.emit()
        else:
            logger.warning(f"Invalid filter name: {filter_name}")
    
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
                
                # Use player instance if available
                if self._player:
                    title = track.title or track.file_name
                    artist = track.artist.name if track.artist else "Unknown"
                    album = track.album.title if track.album else "Unknown"
                    
                    # Set playlist with currently visible songs (respecting filter/search)
                    visible_tracks = self._songs
                    playlist = [t["file_path"] for t in visible_tracks]
                    self._player.set_playlist(playlist)
                    
                    # Find the index of the current track in the playlist
                    try:
                        current_index = next(i for i, t in enumerate(visible_tracks) if t["id"] == track.id)
                        # Set the player's current index
                        self._player._current_index = current_index
                    except StopIteration:
                        logger.warning("Current track not found in visible songs list")
                    
                    self._player.load_track(track.file_path, title, artist, album)
                    self._player.play()
                    logger.info(f"Loaded track: {track.file_path} - {title}")
                
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
