"""
Tests for metadata extraction
"""

import pytest
from pathlib import Path
from types import SimpleNamespace

from app.metadata.extractor import MetadataExtractor


class TestMetadataExtractor:
    """Test MetadataExtractor"""
    
    def test_supported_formats(self):
        """Test that common formats are supported"""
        assert MetadataExtractor.is_supported(Path("test.mp3"))
        assert MetadataExtractor.is_supported(Path("test.flac"))
        assert MetadataExtractor.is_supported(Path("test.ogg"))
        assert MetadataExtractor.is_supported(Path("test.wav"))
        assert MetadataExtractor.is_supported(Path("test.m4a"))
    
    def test_unsupported_format(self):
        """Test that unsupported formats are rejected"""
        assert not MetadataExtractor.is_supported(Path("test.txt"))
        assert not MetadataExtractor.is_supported(Path("test.pdf"))
    
    def test_parse_track_number(self):
        """Test track number parsing"""
        assert MetadataExtractor._parse_track_number("5") == 5
        assert MetadataExtractor._parse_track_number("5/10") == 5
        assert MetadataExtractor._parse_track_number("10/15") == 10
        assert MetadataExtractor._parse_track_number(None) is None
        assert MetadataExtractor._parse_track_number("invalid") is None
    
    def test_parse_year(self):
        """Test year parsing"""
        assert MetadataExtractor._parse_year("2024") == 2024
        assert MetadataExtractor._parse_year("2024-01-01") == 2024
        assert MetadataExtractor._parse_year("2024/05/15") == 2024
        assert MetadataExtractor._parse_year(None) is None
    
    def test_parse_replaygain(self):
        """Test ReplayGain parsing"""
        assert MetadataExtractor._parse_replaygain("-7.5 dB") == -7.5
        assert MetadataExtractor._parse_replaygain("3.2 dB") == 3.2
        assert MetadataExtractor._parse_replaygain("-7.5") == -7.5
        assert MetadataExtractor._parse_replaygain(None) is None

    def test_embedded_artwork_is_cached_without_modifying_audio(self, tmp_path, monkeypatch):
        monkeypatch.setenv("XDG_CACHE_HOME", str(tmp_path / "cache"))
        audio_file = SimpleNamespace(pictures=[SimpleNamespace(data=b"image-bytes", mime="image/png")])

        result = MetadataExtractor._extract_artwork(audio_file, tmp_path / "song.flac")

        assert result is not None
        assert Path(result).suffix == ".png"
        assert Path(result).read_bytes() == b"image-bytes"

    def test_folder_cover_is_used_when_embedding_is_missing(self, tmp_path, monkeypatch):
        monkeypatch.setenv("XDG_CACHE_HOME", str(tmp_path / "cache"))
        cover = tmp_path / "cover.jpg"
        cover.write_bytes(b"folder-cover")

        result = MetadataExtractor._extract_artwork(SimpleNamespace(), tmp_path / "song.mp3")

        assert result == str(cover)
