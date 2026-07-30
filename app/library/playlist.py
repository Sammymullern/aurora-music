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
            
            # Check if track already exists in playlist
            existing = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id,
                track_id=track_id
            ).first()
            
            if existing:
                logger.warning(f"Track {track_id} already in playlist {playlist_id}")
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
        """Remove a track from a playlist and recompact positions"""
        try:
            playlist_track = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id,
                track_id=track_id
            ).first()
            
            if playlist_track:
                removed_position = playlist_track.position
                self.session.delete(playlist_track)
                
                # Recompact positions to fill the gap
                self.session.query(PlaylistTrack).filter(
                    PlaylistTrack.playlist_id == playlist_id,
                    PlaylistTrack.position > removed_position
                ).update({"position": PlaylistTrack.position - 1})
                
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
    
    def move_track_in_playlist(self, playlist_id: int, track_id: int, new_position: int) -> bool:
        """Move a track to a new position within the playlist"""
        try:
            playlist_track = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id,
                track_id=track_id
            ).first()
            
            if not playlist_track:
                logger.error(f"Track {track_id} not found in playlist {playlist_id}")
                return False
            
            current_position = playlist_track.position
            
            if current_position == new_position:
                return True
            
            # Get total track count
            total_tracks = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id
            ).count()
            
            if new_position < 1 or new_position > total_tracks:
                logger.error(f"Invalid position {new_position} for playlist {playlist_id}")
                return False
            
            if new_position < current_position:
                # Moving up: shift tracks between new_position and current_position-1 down
                self.session.query(PlaylistTrack).filter(
                    PlaylistTrack.playlist_id == playlist_id,
                    PlaylistTrack.position >= new_position,
                    PlaylistTrack.position < current_position
                ).update({"position": PlaylistTrack.position + 1})
            else:
                # Moving down: shift tracks between current_position+1 and new_position up
                self.session.query(PlaylistTrack).filter(
                    PlaylistTrack.playlist_id == playlist_id,
                    PlaylistTrack.position > current_position,
                    PlaylistTrack.position <= new_position
                ).update({"position": PlaylistTrack.position - 1})
            
            # Update the moved track's position
            playlist_track.position = new_position
            
            self.session.commit()
            logger.info(f"Moved track {track_id} to position {new_position} in playlist {playlist_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to move track in playlist: {e}")
            self.session.rollback()
            return False
    
    def add_tracks_to_playlist(self, playlist_id: int, track_ids: List[int]) -> int:
        """Add multiple tracks to a playlist, returns count of successfully added tracks"""
        added_count = 0
        try:
            playlist = self.session.query(Playlist).filter_by(id=playlist_id).first()
            if not playlist:
                logger.error(f"Playlist {playlist_id} not found")
                return 0
            
            # Get current max position
            max_position = self.session.query(PlaylistTrack).filter_by(
                playlist_id=playlist_id
            ).count()
            
            for track_id in track_ids:
                track = self.session.query(Track).filter_by(id=track_id).first()
                if not track:
                    logger.warning(f"Track {track_id} not found")
                    continue
                
                # Check if track already exists in playlist
                existing = self.session.query(PlaylistTrack).filter_by(
                    playlist_id=playlist_id,
                    track_id=track_id
                ).first()
                
                if existing:
                    logger.warning(f"Track {track_id} already in playlist {playlist_id}")
                    continue
                
                max_position += 1
                playlist_track = PlaylistTrack(
                    playlist_id=playlist_id,
                    track_id=track_id,
                    position=max_position
                )
                self.session.add(playlist_track)
                added_count += 1
            
            self.session.commit()
            logger.info(f"Added {added_count} tracks to playlist {playlist_id}")
            return added_count
        except Exception as e:
            logger.error(f"Failed to add tracks to playlist: {e}")
            self.session.rollback()
            return added_count
    
    def remove_tracks_from_playlist(self, playlist_id: int, track_ids: List[int]) -> int:
        """Remove multiple tracks from a playlist, returns count of removed tracks"""
        removed_count = 0
        try:
            for track_id in track_ids:
                playlist_track = self.session.query(PlaylistTrack).filter_by(
                    playlist_id=playlist_id,
                    track_id=track_id
                ).first()
                
                if playlist_track:
                    self.session.delete(playlist_track)
                    removed_count += 1
            
            if removed_count > 0:
                # Recompact positions
                self.session.query(PlaylistTrack).filter(
                    PlaylistTrack.playlist_id == playlist_id
                ).order_by(PlaylistTrack.position).all()
                
                # Reset positions to be sequential
                tracks = self.session.query(PlaylistTrack).filter_by(
                    playlist_id=playlist_id
                ).order_by(PlaylistTrack.position).all()
                
                for idx, pt in enumerate(tracks, start=1):
                    pt.position = idx
                
                self.session.commit()
                logger.info(f"Removed {removed_count} tracks from playlist {playlist_id}")
            
            return removed_count
        except Exception as e:
            logger.error(f"Failed to remove tracks from playlist: {e}")
            self.session.rollback()
            return removed_count
    
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
    
    def duplicate_playlist(self, playlist_id: int, new_name: Optional[str] = None) -> Optional[Playlist]:
        """Duplicate a playlist with its tracks"""
        try:
            original = self.session.query(Playlist).filter_by(id=playlist_id).first()
            if not original:
                logger.error(f"Playlist {playlist_id} not found")
                return None
            
            # Generate name if not provided
            if not new_name:
                new_name = f"{original.name} (copy)"
            
            # Check for name conflicts
            existing = self.session.query(Playlist).filter_by(name=new_name).first()
            if existing:
                # Append number to make unique
                counter = 1
                while True:
                    test_name = f"{new_name} ({counter})"
                    if not self.session.query(Playlist).filter_by(name=test_name).first():
                        new_name = test_name
                        break
                    counter += 1
            
            # Create new playlist
            new_playlist = Playlist(
                name=new_name,
                description=original.description
            )
            self.session.add(new_playlist)
            self.session.flush()  # Get the ID
            
            # Copy all tracks
            for pt in original.tracks:
                new_playlist_track = PlaylistTrack(
                    playlist_id=new_playlist.id,
                    track_id=pt.track_id,
                    position=pt.position
                )
                self.session.add(new_playlist_track)
            
            self.session.commit()
            logger.info(f"Duplicated playlist {playlist_id} as {new_name}")
            return new_playlist
        except Exception as e:
            logger.error(f"Failed to duplicate playlist: {e}")
            self.session.rollback()
            return None
