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
from mutagen.easyid3 import EasyID3
from mutagen.mp4 import MP4

logger = logging.getLogger(__name__)


class MetadataExtractor:
    """Extract metadata from audio files using Mutagen"""
    
    SUPPORTED_FORMATS = {
        ".mp3", ".flac", ".ogg", ".opus", ".oga", ".aac", ".m4a", 
        ".wav", ".wv", ".aiff", ".ape", ".wma", ".mp4"
    }

    # Formats where Easy wrapper drops the .info attribute (EasyMP3 bug on some streams).
    # For these we always use RAW mutagen for audio properties (duration / bitrate etc.)
    _RAW_AUDIO_PROPS_PREFERRED = {".mp3", ".aac", ".wav", ".aiff", ".m4a", ".mp4"}
    
    @classmethod
    def is_supported(cls, file_path: Path) -> bool:
        """Check if file format is supported"""
        return file_path.suffix.lower() in cls.SUPPORTED_FORMATS
    
    @classmethod
    def extract(cls, file_path: str | Path) -> Optional[Dict[str, Any]]:
        """Extract metadata from audio file.

        Strategy:
          1. Open RAW mutagen handle first (ensures .info with duration/bitrate is present).
          2. Try an easy= True wrapper separately JUST for tag extraction (title/artist/...).
          3. If easy mode fails to read a tag, fall back to raw-file tags where possible.

        This avoids the EasyMP3 / EasyMP4 bug where audio `.info` becomes None on certain
        streams (VBR MP3s / youtube-dl rips common in user libraries).
        """
        file_path = Path(file_path)
        
        if not file_path.exists():
            logger.error(f"File not found: {file_path}")
            return None
        
        if not cls.is_supported(file_path):
            logger.warning(f"Unsupported format: {file_path.suffix}")
            return None
        
        try:
            # RAW HANDLE — always used for audio properties, NEVER stripped of .info
            raw_audio = File(file_path, easy=False)
            if raw_audio is None:
                logger.error(f"Could not read file (mutagen returned None): {file_path}")
                return None

            # EASY HANDLE — used for human-readable tags only
            easy_audio = None
            try:
                easy_audio = File(file_path, easy=True)
            except Exception:
                easy_audio = None

            # For certain formats we re-open a specific class for most reliable duration
            suffix = file_path.suffix.lower()
            class_handle = None
            try:
                if suffix == ".mp3":
                    class_handle = MP3(file_path)
                elif suffix in (".m4a", ".mp4"):
                    class_handle = MP4(file_path)
                elif suffix == ".flac":
                    class_handle = FLAC(file_path)
                elif suffix in (".ogg", ".oga"):
                    try:
                        class_handle = OggVorbis(file_path)
                    except Exception:
                        class_handle = OggOpus(file_path) if suffix != ".oga" else None
                elif suffix == ".opus":
                    class_handle = OggOpus(file_path)
                elif suffix == ".aac":
                    class_handle = AAC(file_path)
                elif suffix == ".wv":
                    class_handle = WavPack(file_path)
                elif suffix == ".aiff":
                    class_handle = AIFF(file_path)
            except Exception as e:
                logger.debug(f"Format-specific open failed for {file_path.name}: {e}")

            # Select the most reliable source for AUDIO PROPERTIES (duration/bitrate/etc.)
            # Order of preference: class_handle.info > raw_audio.info
            info_sources = []
            if class_handle and hasattr(class_handle, "info") and class_handle.info is not None:
                info_sources.append(class_handle.info)
            if hasattr(raw_audio, "info") and raw_audio.info is not None:
                info_sources.append(raw_audio.info)

            # Pick first source that actually HAS duration info
            duration = None
            bitrate = None
            sample_rate = None
            channels = None
            bit_depth = None
            for info in info_sources:
                if duration is None:
                    duration = getattr(info, "length", None)
                    if isinstance(duration, (int, float)) and duration <= 0:
                        duration = None
                if bitrate is None:
                    br = getattr(info, "bitrate", None)
                    if isinstance(br, (int, float)) and br > 0:
                        bitrate = int(br)
                if sample_rate is None:
                    sr = getattr(info, "sample_rate", None)
                    if isinstance(sr, (int, float)) and sr > 0:
                        sample_rate = int(sr)
                if channels is None:
                    ch = getattr(info, "channels", None)
                    if isinstance(ch, (int, float)) and ch > 0:
                        channels = int(ch)
                if bit_depth is None:
                    bd = getattr(info, "bits_per_sample", None)
                    if isinstance(bd, (int, float)) and bd > 0:
                        bit_depth = int(bd)

            metadata = {
                "file_path": str(file_path),
                "file_name": file_path.name,
                "file_size": file_path.stat().st_size,
                "format": suffix.lstrip(".").lower(),
                "title": file_path.stem,  # Default to filename
            }
            
            # Use EASY handle for tags with fallback to class_handle/raw_audio for raw tag dicts
            tag_provider = easy_audio if easy_audio is not None else raw_audio
            try:
                metadata["title"] = cls._get_tag(tag_provider, "title") or file_path.stem
                metadata["artist"] = cls._get_tag(tag_provider, "artist")
                metadata["album"] = cls._get_tag(tag_provider, "album")
                metadata["albumartist"] = cls._get_tag(tag_provider, "albumartist")
                metadata["track_number"] = cls._parse_track_number(cls._get_tag(tag_provider, "tracknumber"))
                metadata["disc_number"] = cls._parse_disc_number(cls._get_tag(tag_provider, "discnumber"))
                metadata["year"] = cls._parse_year(cls._get_tag(tag_provider, "date") or cls._get_tag(tag_provider, "year"))
                metadata["genre"] = cls._get_tag(tag_provider, "genre")
                metadata["comment"] = cls._get_tag(tag_provider, "comment")
                metadata["composer"] = cls._get_tag(tag_provider, "composer")
                metadata["performer"] = cls._get_tag(tag_provider, "performer")
                metadata["lyricist"] = cls._get_tag(tag_provider, "lyricist")

                # ReplayGain
                metadata["track_gain"] = cls._parse_replaygain(cls._get_tag(tag_provider, "replaygain_track_gain"))
                metadata["track_peak"] = cls._parse_replaygain_peak(cls._get_tag(tag_provider, "replaygain_track_peak"))
                metadata["album_gain"] = cls._parse_replaygain(cls._get_tag(tag_provider, "replaygain_album_gain"))
                metadata["album_peak"] = cls._parse_replaygain_peak(cls._get_tag(tag_provider, "replaygain_album_peak"))
            except Exception as e:
                logger.warning(f"Could not extract tags from {file_path.name}, using basic info: {e}")

            # Attach audio properties (may be None for broken containers, that's fine)
            metadata["duration"] = duration
            metadata["bitrate"] = bitrate
            metadata["sample_rate"] = sample_rate
            metadata["channels"] = channels
            metadata["bit_depth"] = bit_depth

            logger.debug(
                f"Extracted metadata from {file_path.name}: "
                f"duration={duration!r}s, title={metadata.get('title')!r}"
            )
            return metadata
            
        except Exception as e:
            logger.error(f"Error extracting metadata from {file_path}: {e}")
            return None
    
    @staticmethod
    def _get_tag(audio_file, tag_name: str) -> Optional[str]:
        """Get tag value from audio file"""
        try:
            if tag_name in audio_file:
                value = audio_file[tag_name]
                if isinstance(value, list):
                    return value[0] if value else None
                return str(value)
        except (KeyError, TypeError, AttributeError) as e:
            logger.debug(f"Could not get tag '{tag_name}': {e}")
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
