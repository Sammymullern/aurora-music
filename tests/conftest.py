"""
Pytest configuration and fixtures
"""

import pytest
import tempfile
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database.models import Base
from app.database.session import DatabaseSession


@pytest.fixture
def temp_db():
    """Create a temporary database for testing"""
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = f.name
    
    engine = create_engine(f"sqlite:///{db_path}")
    Base.metadata.create_all(engine)
    
    Session = sessionmaker(bind=engine)
    session = Session()
    
    yield session, db_path
    
    session.close()
    Path(db_path).unlink(missing_ok=True)


@pytest.fixture
def sample_audio_file():
    """Create a sample audio file path for testing"""
    return Path("/tmp/test_audio.mp3")


@pytest.fixture
def sample_metadata():
    """Sample metadata for testing"""
    return {
        "file_path": "/tmp/test_audio.mp3",
        "file_name": "test_audio.mp3",
        "file_size": 1024000,
        "format": "mp3",
        "title": "Test Track",
        "artist": "Test Artist",
        "album": "Test Album",
        "track_number": 1,
        "disc_number": 1,
        "year": 2024,
        "genre": "Test Genre",
        "duration": 180.5,
        "bitrate": 320000,
        "sample_rate": 44100,
        "channels": 2,
    }
