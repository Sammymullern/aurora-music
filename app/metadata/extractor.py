"""
Audio metadata extraction using Mutagen
"""

import logging
from pathlib import Path
from typing import Optional, Dict, Any

from mutagen import File
from mutagen.id3 import ID3NoHeaderError
from mutagen.flac import FLAC
from mutagen.mp3 import MP3
from mutagen.oggopus import OggOpus
from mutagen.oggvorbis import OggVorbis
from mutagen.aac import AAC
from mutagen.wavpack import WavPack
from mutagen.aiff import AIFF
from mutagen.apev2 import APEv2File

logger = logging.getLogger(__name__)


class MetadataExtractor:
    """Extract metadata from audio files using Mutagen"""
    
    SUPPORTED_FORMATS = {
        ".mp3", ".flac", ".ogg", ".opus", ".oga", ".aac", ".m4a", 
        ".wav", ".wv", ".aiff", ".ape", ".wma", ".mp4"
    }
    
    @classmethod
    def is_supported(cls, file_path: Path) -> bool:
        """Check if file format is supported"""
        return file_path.suffix.lower() in cls.SUPPORTED_FORMATS
    
    @classmethod
    def extract(cls, file_path: str | Path) -> Optional[Dict[str, Any]]:
        """Extract metadata from audio file"""
        file_path = Path(file_path)
        
        if not file_path.exists():
            logger.error(f"File not found: {file_path}")
            return None
        
        if not cls.is_supported(file_path):
            logger.warning(f"Unsupported format: {file_path.suffix}")
            return None
        
        try:
            audio_file = File(file_path, easy=True)
            if audio_file is None:
                logger.error(f"Could not read file: {file_path}")
                return None
            
            metadata = {
                "file_path": str(file_path),
                "file_name": file_path.name,
                "file_size": file_path.stat().st_size,
                "format": file_path.suffix.lstrip(".").lower(),
            }
            
            # Extract basic metadata
            if audio_file:
                metadata["title"] = cls._get_tag(audio_file, "title") or file_path.stem
                metadata["artist"] = cls._get_tag(audio_file, "artist")
                metadata["album"] = cls._get_tag(audio_file, "album")
                metadata["albumartist"] = cls._get_tag(audio_file, "albumartist")
                metadata["track_number"] = cls._parse_track_number(cls._get_tag(audio_file, "tracknumber"))
                metadata["disc_number"] = cls._parse_disc_number(cls._get_tag(audio_file, "discnumber"))
                metadata["year"] = cls._parse_year(cls._get_tag(audio_file, "date") or cls._get_tag(audio_file, "year"))
                metadata["genre"] = cls._get_tag(audio_file, "genre")
                metadata["comment"] = cls._get_tag(audio_file, "comment")
                metadata["composer"] = cls._get_tag(audio_file, "composer")
                metadata["performer"] = cls._get_tag(audio_file, "performer")
                metadata["lyricist"] = cls._get_tag(audio_file, "lyricist")
                
                # Audio properties
                if hasattr(audio_file, "info"):
                    info = audio_file.info
                    metadata["duration"] = getattr(info, "length", None)
                    metadata["bitrate"] = getattr(info, "bitrate", None)
                    metadata["sample_rate"] = getattr(info, "sample_rate", None)
                    metadata["channels"] = getattr(info, "channels", None)
                    metadata["bit_depth"] = getattr(info, "bits_per_sample", None)
                
                # ReplayGain
                metadata["track_gain"] = cls._parse_replaygain(cls._get_tag(audio_file, "replaygain_track_gain"))
                metadata["track_peak"] = cls._parse_replaygain_peak(cls._get_tag(audio_file, "replaygain_track_peak"))
                metadata["album_gain"] = cls._parse_replaygain(cls._get_tag(audio_file, "replaygain_album_gain"))
                metadata["album_peak"] = cls._parse_replaygain_peak(cls._get_tag(audio_file, "replaygain_album_peak"))
            
            logger.debug(f"Extracted metadata from {file_path.name}")
            return metadata
            
        except Exception as e:
            logger.error(f"Error extracting metadata from {file_path}: {e}")
            return None
    
    @staticmethod
    def _get_tag(audio_file, tag_name: str) -> Optional[str]:
        """Get tag value from audio file"""
        if tag_name in audio_file:
            value = audio_file[tag_name]
            if isinstance(value, list):
                return value[0] if value else None
            return str(value)
        return None
    
    @staticmethod
    def _parse_track_number(value: Optional[str]) -> Optional[int]:
        """Parse track number from tag"""
        if value is None:
            return None
        try:
            # Handle "1/10" format
            if "/" in value:
                value = value.split("/")[0]
            return int(value)
        except (ValueError, AttributeError):
            return None
    
    @staticmethod
    def _parse_disc_number(value: Optional[str]) -> Optional[int]:
        """Parse disc number from tag"""
        if value is None:
            return 1
        try:
            if "/" in value:
                value = value.split("/")[0]
            return int(value)
        except (ValueError, AttributeError):
            return 1
    
    @staticmethod
    def _parse_year(value: Optional[str]) -> Optional[int]:
        """Parse year from date tag"""
        if value is None:
            return None
        try:
            # Handle various date formats
            value = str(value).strip()
            if len(value) >= 4:
                return int(value[:4])
            return int(value)
        except (ValueError, AttributeError):
            return None
    
    @staticmethod
    def _parse_replaygain(value: Optional[str]) -> Optional[float]:
        """Parse ReplayGain value (e.g., "-7.5 dB")"""
        if value is None:
            return None
        try:
            value = str(value).strip().replace("dB", "").strip()
            return float(value)
        except (ValueError, AttributeError):
            return None
    
    @staticmethod
    def _parse_replaygain_peak(value: Optional[str]) -> Optional[float]:
        """Parse ReplayGain peak value"""
        if value is None:
            return None
        try:
            return float(str(value).strip())
        except (ValueError, AttributeError):
            return None
