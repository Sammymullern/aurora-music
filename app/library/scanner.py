"""
Library scanner for indexing audio files
"""

import logging
from pathlib import Path
from typing import List, Optional, Callable
from concurrent.futures import ThreadPoolExecutor, as_completed

from sqlalchemy.orm import Session

from app.database.models import Track, Artist, Album
from app.database.session import db
from app.metadata.extractor import MetadataExtractor

logger = logging.getLogger(__name__)


class LibraryScanner:
    """Scanner for building and updating music library"""
    
    def __init__(self, session: Session):
        self.session = session
        self.extractor = MetadataExtractor()
        self._cancel_flag = False
    
    def scan_directory(self, directory: str | Path, progress_callback: Optional[Callable] = None) -> int:
        """Scan a directory for audio files and add to library"""
        directory = Path(directory)
        
        if not directory.exists() or not directory.is_dir():
            logger.error(f"Invalid directory: {directory}")
            return 0
        
        logger.info(f"Scanning directory: {directory}")
        
        # Find all audio files
        audio_files = self._find_audio_files(directory)
        total_files = len(audio_files)
        
        if total_files == 0:
            logger.warning("No audio files found")
            return 0
        
        logger.info(f"Found {total_files} audio files")
        
        # Process files
        added_count = 0
        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = {
                executor.submit(self._process_file, file_path): file_path 
                for file_path in audio_files
            }
            
            for i, future in enumerate(as_completed(futures)):
                if self._cancel_flag:
                    logger.info("Scan cancelled")
                    break
                
                file_path = futures[future]
                try:
                    if future.result():
                        added_count += 1
                except Exception as e:
                    logger.error(f"Error processing {file_path}: {e}")
                
                if progress_callback:
                    progress = (i + 1) / total_files * 100
                    progress_callback(progress)
        
        self.session.commit()
        logger.info(f"Scan complete: {added_count} tracks added")
        return added_count
    
    def _find_audio_files(self, directory: Path) -> List[Path]:
        """Recursively find all supported audio files"""
        audio_files = []
        
        for file_path in directory.rglob("*"):
            if file_path.is_file() and MetadataExtractor.is_supported(file_path):
                audio_files.append(file_path)
        
        return audio_files
    
    def _process_file(self, file_path: Path) -> bool:
        """Process a single audio file"""
        # Check if track already exists
        existing = self.session.query(Track).filter_by(file_path=str(file_path)).first()
        if existing:
            # Update if file was modified
            if file_path.stat().st_mtime > existing.scanned_at.timestamp():
                return self._update_track(existing, file_path)
            return False
        
        # Extract metadata
        metadata = self.extractor.extract(file_path)
        if not metadata:
            return False
        
        # Create or get artist
        artist = self._get_or_create_artist(metadata)
        
        # Create or get album
        album = self._get_or_create_album(metadata, artist)
        
        # Create track
        track = Track(
            file_path=metadata["file_path"],
            file_name=metadata["file_name"],
            file_size=metadata["file_size"],
            format=metadata["format"],
            title=metadata["title"],
            artist=artist,
            album=album,
            track_number=metadata.get("track_number"),
            disc_number=metadata.get("disc_number", 1),
            year=metadata.get("year"),
            genre=metadata.get("genre"),
            duration=metadata.get("duration"),
            bitrate=metadata.get("bitrate"),
            sample_rate=metadata.get("sample_rate"),
            channels=metadata.get("channels"),
            bit_depth=metadata.get("bit_depth"),
            track_gain=metadata.get("track_gain"),
            track_peak=metadata.get("track_peak"),
            album_gain=metadata.get("album_gain"),
            album_peak=metadata.get("album_peak"),
            comment=metadata.get("comment"),
            composer=metadata.get("composer"),
            performer=metadata.get("performer"),
            lyricist=metadata.get("lyricist"),
        )
        
        self.session.add(track)
        return True
    
    def _update_track(self, track: Track, file_path: Path) -> bool:
        """Update existing track with new metadata"""
        metadata = self.extractor.extract(file_path)
        if not metadata:
            return False
        
        # Update artist
        if metadata.get("artist"):
            artist = self._get_or_create_artist(metadata)
            track.artist = artist
        
        # Update album
        if metadata.get("album"):
            album = self._get_or_create_album(metadata, track.artist)
            track.album = album
        
        # Update track fields
        track.title = metadata["title"]
        track.track_number = metadata.get("track_number")
        track.disc_number = metadata.get("disc_number", 1)
        track.year = metadata.get("year")
        track.genre = metadata.get("genre")
        track.duration = metadata.get("duration")
        track.bitrate = metadata.get("bitrate")
        track.sample_rate = metadata.get("sample_rate")
        track.channels = metadata.get("channels")
        track.bit_depth = metadata.get("bit_depth")
        track.file_size = metadata["file_size"]
        track.scanned_at = track.scanned_at  # Will be updated by onupdate
        
        return True
    
    def _get_or_create_artist(self, metadata: dict) -> Artist:
        """Get existing artist or create new one"""
        artist_name = metadata.get("artist")
        if not artist_name:
            return None
        
        artist = self.session.query(Artist).filter_by(name=artist_name).first()
        if not artist:
            artist = Artist(name=artist_name)
            self.session.add(artist)
        
        return artist
    
    def _get_or_create_album(self, metadata: dict, artist: Optional[Artist]) -> Optional[Album]:
        """Get existing album or create new one"""
        album_title = metadata.get("album")
        if not album_title:
            return None
        
        album = self.session.query(Album).filter_by(
            title=album_title,
            artist_id=artist.id if artist else None
        ).first()
        
        if not album:
            album = Album(
                title=album_title,
                artist=artist,
                year=metadata.get("year"),
                genre=metadata.get("genre")
            )
            self.session.add(album)
        
        return album
    
    def cancel(self) -> None:
        """Cancel ongoing scan"""
        self._cancel_flag = True
    
    def reset(self) -> None:
        """Reset cancel flag"""
        self._cancel_flag = False
