"""
Playlist management functionality
"""

import logging
from typing import List, Optional
from sqlalchemy.orm import Session

from app.database.models import Playlist, PlaylistTrack, Track

logger = logging.getLogger(__name__)


class PlaylistManager:
    """Manager for playlist operations"""
    
    def __init__(self, session: Session):
        self.session = session
    
    def create_playlist(self, name: str, description: Optional[str] = None) -> Optional[Playlist]:
        """Create a new playlist"""
        try:
            playlist = Playlist(name=name, description=description)
            self.session.add(playlist)
            self.session.commit()
            logger.info(f"Created playlist: {name}")
            return playlist
        except Exception as e:
            logger.error(f"Failed to create playlist: {e}")
            self.session.rollback()
            return None
    
    def delete_playlist(self, playlist_id: int) -> bool:
        """Delete a playlist"""
        try:
            playlist = self.session.query(Playlist).filter_by(id=playlist_id).first()
            if playlist:
                self.session.delete(playlist)
                self.session.commit()
                logger.info(f"Deleted playlist: {playlist_id}")
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to delete playlist: {e}")
            self.session.rollback()
            return False
    
    def get_playlist(self, playlist_id: int) -> Optional[Playlist]:
        """Get a playlist by ID"""
        return self.session.query(Playlist).filter_by(id=playlist_id).first()
    
    def get_all_playlists(self) -> List[Playlist]:
        """Get all playlists"""
        return self.session.query(Playlist).order_by(Playlist.name).all()
    
    def add_track_to_playlist(self, playlist_id: int, track_id: int) -> bool:
        """Add a track to a playlist"""
        try:
            playlist = self.session.query(Playlist).filter_by(id=playlist_id).first()
            track = self.session.query(Track).filter_by(id=track_id).first()
            
            if not playlist or not track:
                logger.error("Playlist or track not found")
                return False
            
            # Get current max position
            max_position = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id
            ).count()
            
            playlist_track = PlaylistTrack(
                playlist_id=playlist_id,
                track_id=track_id,
                position=max_position + 1
            )
            
            self.session.add(playlist_track)
            self.session.commit()
            logger.info(f"Added track {track_id} to playlist {playlist_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to add track to playlist: {e}")
            self.session.rollback()
            return False
    
    def remove_track_from_playlist(self, playlist_id: int, track_id: int) -> bool:
        """Remove a track from a playlist"""
        try:
            playlist_track = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id,
                track_id=track_id
            ).first()
            
            if playlist_track:
                self.session.delete(playlist_track)
                self.session.commit()
                logger.info(f"Removed track {track_id} from playlist {playlist_id}")
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to remove track from playlist: {e}")
            self.session.rollback()
            return False
    
    def get_playlist_tracks(self, playlist_id: int) -> List[Track]:
        """Get all tracks in a playlist"""
        try:
            playlist = self.session.query(Playlist).filter_by(id=playlist_id).first()
            if playlist:
                return [pt.track for pt in playlist.tracks]
            return []
        except Exception as e:
            logger.error(f"Failed to get playlist tracks: {e}")
            return []
    
    def update_playlist(self, playlist_id: int, name: Optional[str] = None, 
                       description: Optional[str] = None) -> bool:
        """Update playlist information"""
        try:
            playlist = self.session.query(Playlist).filter_by(id=playlist_id).first()
            if playlist:
                if name is not None:
                    playlist.name = name
                if description is not None:
                    playlist.description = description
                self.session.commit()
                logger.info(f"Updated playlist {playlist_id}")
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to update playlist: {e}")
            self.session.rollback()
            return False
