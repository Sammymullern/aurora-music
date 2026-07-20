"""
SQLAlchemy database models for Aurora Music
"""

from datetime import datetime
from typing import Optional

from sqlalchemy import (
    Boolean, DateTime, Float, ForeignKey, Integer, String, Text, UniqueConstraint
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    """Base class for all models"""
    pass


class Artist(Base):
    """Artist model"""
    __tablename__ = "artists"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    sort_name: Mapped[Optional[str]] = mapped_column(String(255))
    musicbrainz_id: Mapped[Optional[str]] = mapped_column(String(100))
    
    # Relationships
    tracks: Mapped[list["Track"]] = relationship(back_populates="artist", cascade="all, delete-orphan")
    albums: Mapped[list["Album"]] = relationship(back_populates="artist", cascade="all, delete-orphan")
    
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Album(Base):
    """Album model"""
    __tablename__ = "albums"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    artist_id: Mapped[Optional[int]] = mapped_column(ForeignKey("artists.id"), nullable=True)
    year: Mapped[Optional[int]] = mapped_column(Integer)
    genre: Mapped[Optional[str]] = mapped_column(String(100))
    musicbrainz_id: Mapped[Optional[str]] = mapped_column(String(100))
    
    # Artwork
    artwork_path: Mapped[Optional[str]] = mapped_column(String(500))
    
    # Relationships
    artist: Mapped[Optional["Artist"]] = relationship(back_populates="albums")
    tracks: Mapped[list["Track"]] = relationship(back_populates="album", cascade="all, delete-orphan")
    
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    __table_args__ = (UniqueConstraint("title", "artist_id", name="unique_album_artist"),)


class Track(Base):
    """Track model"""
    __tablename__ = "tracks"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    
    # File information
    file_path: Mapped[str] = mapped_column(String(500), nullable=False, unique=True)
    file_name: Mapped[str] = mapped_column(String(255), nullable=False)
    file_size: Mapped[int] = mapped_column(Integer, nullable=False)
    format: Mapped[str] = mapped_column(String(10))
    
    # Metadata
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    artist_id: Mapped[Optional[int]] = mapped_column(ForeignKey("artists.id"), nullable=True)
    album_id: Mapped[Optional[int]] = mapped_column(ForeignKey("albums.id"), nullable=True)
    track_number: Mapped[Optional[int]] = mapped_column(Integer)
    disc_number: Mapped[Optional[int]] = mapped_column(Integer, default=1)
    year: Mapped[Optional[int]] = mapped_column(Integer)
    genre: Mapped[Optional[str]] = mapped_column(String(100))
    
    # Audio properties
    duration: Mapped[Optional[float]] = mapped_column(Float)
    bitrate: Mapped[Optional[int]] = mapped_column(Integer)
    sample_rate: Mapped[Optional[int]] = mapped_column(Integer)
    channels: Mapped[Optional[int]] = mapped_column(Integer)
    bit_depth: Mapped[Optional[int]] = mapped_column(Integer)
    
    # ReplayGain
    track_gain: Mapped[Optional[float]] = mapped_column(Float)
    track_peak: Mapped[Optional[float]] = mapped_column(Float)
    album_gain: Mapped[Optional[float]] = mapped_column(Float)
    album_peak: Mapped[Optional[float]] = mapped_column(Float)
    
    # Additional metadata
    comment: Mapped[Optional[str]] = mapped_column(Text)
    composer: Mapped[Optional[str]] = mapped_column(String(255))
    performer: Mapped[Optional[str]] = mapped_column(String(255))
    lyricist: Mapped[Optional[str]] = mapped_column(String(255))
    
    # Lyrics
    lyrics_path: Mapped[Optional[str]] = mapped_column(String(500))
    
    # Waveform
    waveform_path: Mapped[Optional[str]] = mapped_column(String(500))
    
    # User data
    rating: Mapped[Optional[int]] = mapped_column(Integer, default=0)  # 0-5 stars
    play_count: Mapped[int] = mapped_column(Integer, default=0)
    last_played: Mapped[Optional[datetime]] = mapped_column(DateTime)
    favorite: Mapped[bool] = mapped_column(Boolean, default=False)
    
    # Mood and analysis
    mood: Mapped[Optional[str]] = mapped_column(String(50))
    bpm: Mapped[Optional[int]] = mapped_column(Integer)
    energy: Mapped[Optional[float]] = mapped_column(Float)
    danceability: Mapped[Optional[float]] = mapped_column(Float)
    
    # Relationships
    artist: Mapped[Optional["Artist"]] = relationship(back_populates="tracks")
    album: Mapped[Optional["Album"]] = relationship(back_populates="tracks")
    
    # Timestamps
    added_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    modified_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    scanned_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class Playlist(Base):
    """Playlist model"""
    __tablename__ = "playlists"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    description: Mapped[Optional[str]] = mapped_column(Text)
    
    # Relationships
    tracks: Mapped[list["PlaylistTrack"]] = relationship(
        back_populates="playlist", cascade="all, delete-orphan", order_by="PlaylistTrack.position"
    )
    
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class PlaylistTrack(Base):
    """Playlist track association model"""
    __tablename__ = "playlist_tracks"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    playlist_id: Mapped[int] = mapped_column(ForeignKey("playlists.id"), nullable=False)
    track_id: Mapped[int] = mapped_column(ForeignKey("tracks.id"), nullable=False)
    position: Mapped[int] = mapped_column(Integer, nullable=False)
    
    # Relationships
    playlist: Mapped["Playlist"] = relationship(back_populates="tracks")
    track: Mapped["Track"] = relationship()
    
    added_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    __table_args__ = (UniqueConstraint("playlist_id", "track_id", "position", name="unique_playlist_track"),)
