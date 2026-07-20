"""
Tests for metadata extraction
"""

import pytest
from pathlib import Path

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
