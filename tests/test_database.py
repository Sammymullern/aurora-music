"""
Tests for database models and operations
"""

import pytest
from datetime import datetime

from app.database.models import Track, Artist, Album, Playlist, PlaylistTrack


class TestArtist:
    """Test Artist model"""
    
    def test_create_artist(self, temp_db):
        session, _ = temp_db
        
        artist = Artist(name="Test Artist")
        session.add(artist)
        session.commit()
        
        retrieved = session.query(Artist).filter_by(name="Test Artist").first()
        assert retrieved is not None
        assert retrieved.name == "Test Artist"
    
    def test_artist_unique_name(self, temp_db):
        session, _ = temp_db
        
        artist1 = Artist(name="Test Artist")
        artist2 = Artist(name="Test Artist")
        session.add(artist1)
        session.commit()
        
        with pytest.raises(Exception):  # Integrity error
            session.add(artist2)
            session.commit()


class TestAlbum:
    """Test Album model"""
    
    def test_create_album(self, temp_db):
        session, _ = temp_db
        
        album = Album(title="Test Album")
        session.add(album)
        session.commit()
        
        retrieved = session.query(Album).filter_by(title="Test Album").first()
        assert retrieved is not None
        assert retrieved.title == "Test Album"
    
    def test_album_with_artist(self, temp_db):
        session, _ = temp_db
        
        artist = Artist(name="Test Artist")
        session.add(artist)
        session.commit()
        
        album = Album(title="Test Album", artist=artist)
        session.add(album)
        session.commit()
        
        retrieved = session.query(Album).filter_by(title="Test Album").first()
        assert retrieved.artist.name == "Test Artist"


class TestTrack:
    """Test Track model"""
    
    def test_create_track(self, temp_db):
        session, _ = temp_db
        
        track = Track(
            file_path="/tmp/test.mp3",
            file_name="test.mp3",
            file_size=1024000,
            format="mp3",
            title="Test Track"
        )
        session.add(track)
        session.commit()
        
        retrieved = session.query(Track).filter_by(title="Test Track").first()
        assert retrieved is not None
        assert retrieved.title == "Test Track"
        assert retrieved.file_path == "/tmp/test.mp3"
    
    def test_track_with_artist_and_album(self, temp_db):
        session, _ = temp_db
        
        artist = Artist(name="Test Artist")
        album = Album(title="Test Album", artist=artist)
        track = Track(
            file_path="/tmp/test.mp3",
            file_name="test.mp3",
            file_size=1024000,
            format="mp3",
            title="Test Track",
            artist=artist,
            album=album
        )
        
        session.add_all([artist, album, track])
        session.commit()
        
        retrieved = session.query(Track).filter_by(title="Test Track").first()
        assert retrieved.artist.name == "Test Artist"
        assert retrieved.album.title == "Test Album"


class TestPlaylist:
    """Test Playlist model"""
    
    def test_create_playlist(self, temp_db):
        session, _ = temp_db
        
        playlist = Playlist(name="Test Playlist")
        session.add(playlist)
        session.commit()
        
        retrieved = session.query(Playlist).filter_by(name="Test Playlist").first()
        assert retrieved is not None
        assert retrieved.name == "Test Playlist"
    
    def test_add_track_to_playlist(self, temp_db):
        session, _ = temp_db
        
        playlist = Playlist(name="Test Playlist")
        track = Track(
            file_path="/tmp/test.mp3",
            file_name="test.mp3",
            file_size=1024000,
            format="mp3",
            title="Test Track"
        )
        
        session.add_all([playlist, track])
        session.commit()
        
        playlist_track = PlaylistTrack(
            playlist_id=playlist.id,
            track_id=track.id,
            position=1
        )
        session.add(playlist_track)
        session.commit()
        
        retrieved = session.query(Playlist).filter_by(name="Test Playlist").first()
        assert len(retrieved.tracks) == 1
        assert retrieved.tracks[0].track.title == "Test Track"
