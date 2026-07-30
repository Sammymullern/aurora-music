"""
Playlist controller for QML integration
"""

import logging
from typing import List
from PySide6.QtCore import QObject, Signal, Slot, QAbstractListModel, Qt, QModelIndex

from app.database.session import db
from app.library.playlist import PlaylistManager
from app.database.models import Playlist, Track

logger = logging.getLogger(__name__)


class PlaylistModel(QAbstractListModel):
    """Qt model for playlist list"""
    
    RoleName = Qt.UserRole + 1
    RoleDescription = Qt.UserRole + 2
    RoleTrackCount = Qt.UserRole + 3
    RoleId = Qt.UserRole + 4
    
    modelChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._playlists: List[Playlist] = []
        self._manager = PlaylistManager(db.get_session())
        self._load_playlists()
    
    def _load_playlists(self):
        """Load playlists from database"""
        self.beginResetModel()
        self._playlists = self._manager.get_all_playlists()
        self.endResetModel()
        self.modelChanged.emit()
    
    def rowCount(self, parent=QModelIndex()):
        return len(self._playlists)
    
    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._playlists):
            return None
        
        playlist = self._playlists[index.row()]
        
        if role == Qt.DisplayRole:
            return playlist.name
        elif role == self.RoleName:
            return playlist.name
        elif role == self.RoleDescription:
            return playlist.description or ""
        elif role == self.RoleTrackCount:
            return len(playlist.tracks)
        elif role == self.RoleId:
            return playlist.id
        
        return None
    
    def roleNames(self):
        return {
            Qt.DisplayRole: b"display",
            self.RoleName: b"name",
            self.RoleDescription: b"description",
            self.RoleTrackCount: b"trackCount",
            self.RoleId: b"id"
        }
    
    def refresh(self):
        """Refresh the model from database"""
        self._load_playlists()


class PlaylistController(QObject):
    """Controller for playlist operations exposed to QML"""
    
    playlistsChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._manager = PlaylistManager(db.get_session())
        self._model = PlaylistModel()
    
    @property
    def model(self):
        """Get the playlist model"""
        return self._model
    
    @Slot(str, str)
    def createPlaylist(self, name: str, description: str = "") -> bool:
        """Create a new playlist"""
        try:
            result = self._manager.create_playlist(name, description if description else None)
            if result:
                self._model.refresh()
                self.playlistsChanged.emit()
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to create playlist: {e}")
            return False
    
    @Slot(int)
    def deletePlaylist(self, playlist_id: int) -> bool:
        """Delete a playlist"""
        try:
            result = self._manager.delete_playlist(playlist_id)
            if result:
                self._model.refresh()
                self.playlistsChanged.emit()
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to delete playlist: {e}")
            return False
    
    @Slot(int, str, str, result=bool)
    def updatePlaylist(self, playlist_id: int, name: str, description: str = "") -> bool:
        """Update playlist information"""
        try:
            result = self._manager.update_playlist(
                playlist_id, 
                name if name else None, 
                description if description else None
            )
            if result:
                self._model.refresh()
                self.playlistsChanged.emit()
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to update playlist: {e}")
            return False
    
    @Slot(int, result=bool)
    def duplicatePlaylist(self, playlist_id: int) -> bool:
        """Duplicate a playlist"""
        try:
            result = self._manager.duplicate_playlist(playlist_id)
            if result:
                self._model.refresh()
                self.playlistsChanged.emit()
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to duplicate playlist: {e}")
            return False
    
    @Slot(int, int, result=bool)
    def addTrackToPlaylist(self, playlist_id: int, track_id: int) -> bool:
        """Add a track to a playlist"""
        try:
            result = self._manager.add_track_to_playlist(playlist_id, track_id)
            if result:
                self._model.refresh()
            return result
        except Exception as e:
            logger.error(f"Failed to add track to playlist: {e}")
            return False
    
    @Slot(int, int, result=bool)
    def removeTrackFromPlaylist(self, playlist_id: int, track_id: int) -> bool:
        """Remove a track from a playlist"""
        try:
            result = self._manager.remove_track_from_playlist(playlist_id, track_id)
            if result:
                self._model.refresh()
            return result
        except Exception as e:
            logger.error(f"Failed to remove track from playlist: {e}")
            return False
    
    @Slot(int, int, int, result=bool)
    def moveTrackInPlaylist(self, playlist_id: int, track_id: int, new_position: int) -> bool:
        """Move a track to a new position in the playlist"""
        try:
            return self._manager.move_track_in_playlist(playlist_id, track_id, new_position)
        except Exception as e:
            logger.error(f"Failed to move track in playlist: {e}")
            return False
    
    @Slot(int, result="QVariantList")
    def getPlaylistTracks(self, playlist_id: int):
        """Get all tracks in a playlist with metadata"""
        try:
            tracks = self._manager.get_playlist_tracks(playlist_id)
            track_list = []
            for track in tracks:
                track_list.append({
                    "id": track.id,
                    "title": track.title,
                    "artist": track.artist.name if track.artist else None,
                    "album": track.album.title if track.album else None,
                    "duration": track.duration,
                    "file_path": track.file_path
                })
            return track_list
        except Exception as e:
            logger.error(f"Failed to get playlist tracks: {e}")
            return []
    
    @Slot(int, result="QVariantMap")
    def getPlaylistStats(self, playlist_id: int):
        """Get playlist statistics (song count, total duration, etc.)"""
        try:
            tracks = self._manager.get_playlist_tracks(playlist_id)
            total_duration = sum(t.duration for t in tracks if t.duration) or 0
            hours = int(total_duration // 3600)
            minutes = int((total_duration % 3600) // 60)
            
            duration_str = ""
            if hours > 0:
                duration_str = f"{hours}h {minutes}m"
            else:
                duration_str = f"{minutes}m"
            
            return {
                "songCount": len(tracks),
                "totalDuration": duration_str,
                "totalDurationSeconds": total_duration
            }
        except Exception as e:
            logger.error(f"Failed to get playlist stats: {e}")
            return {"songCount": 0, "totalDuration": "0m", "totalDurationSeconds": 0}
