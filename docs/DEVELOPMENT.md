# Development Guide

## Setting Up Development Environment

### Prerequisites

- Python 3.13
- Git
- Virtual environment tool (venv or conda)

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/auroramusic/aurora-music.git
cd aurora-music

# Create virtual environment
python3.13 -m venv venv
source venv/bin/activate

# Install development dependencies
pip install -r requirements-dev.txt

# Install in editable mode
pip install -e .
```

## Project Structure

```
aurora-music/
├── app/
│   ├── ui/              # PySide6+QML user interface
│   ├── player/          # Audio playback engine
│   ├── library/         # Library management
│   ├── database/        # SQLite database models
│   ├── metadata/        # Metadata extraction
│   ├── recommendations/ # AI recommendations
│   ├── themes/          # Theme system
│   └── plugins/         # Plugin system
├── assets/              # Images, icons, themes
├── plugins/             # User plugins
├── tests/               # Test suite
├── docs/                # Documentation
└── packaging/           # Packaging configurations
```

## Code Style

We use the following tools to maintain code quality:

- **Black**: Code formatting
- **Ruff**: Linting
- **MyPy**: Type checking

### Running Linters

```bash
# Format code
black app/

# Check for issues
ruff check app/

# Type checking
mypy app/
```

## Testing

### Running Tests

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_player.py

# Run with coverage
pytest --cov=app --cov-report=html
```

### Writing Tests

Tests are located in the `tests/` directory. Each module should have corresponding test file.

```python
# tests/test_player.py
import pytest
from unittest.mock import Mock, patch

from app.player.player import Player

class TestPlayer:
    @patch('app.player.player.mpv.MPV')
    def test_player_initialization(self, mock_mpv):
        player = Player()
        assert player._is_initialized
```

## Building the UI

### QML Files

QML files are located in `app/ui/qml/`. To reload QML changes during development:

1. Restart the application
2. Or use Qt Quick's live reload (if enabled)

### Python-QML Bridge

To expose Python objects to QML:

```python
# In main_window.py
context = self.engine.rootContext()
context.setContextProperty("player", self.player)
```

## Database Management

### Database Schema

The database schema is defined in `app/database/models.py`. To modify the schema:

1. Update the model classes
2. Create a migration script (in production, use Alembic)
3. Test with a temporary database

### Accessing Database

```python
from app.database.session import db

# Initialize
db.initialize("aurora.db")

# Get session
session = db.get_session()

# Query
tracks = session.query(Track).all()

# Close
db.close()
```

## Plugin Development

### Creating a Plugin

Create a new file in `plugins/` directory:

```python
from app.plugins.base import Plugin, PluginInfo

class MyPlugin(Plugin):
    def get_info(self) -> PluginInfo:
        return PluginInfo(
            name="My Plugin",
            version="1.0.0",
            description="Description",
            author="Your Name",
            license="MIT"
        )
    
    def initialize(self) -> bool:
        # Initialize plugin
        return True
    
    def shutdown(self) -> None:
        # Cleanup
        pass
```

## Audio Features

### Adding Audio Formats

To add support for a new audio format:

1. Update `app/metadata/extractor.py` to add the format to `SUPPORTED_FORMATS`
2. Test with sample files
3. Add to documentation

### Equalizer Presets

To add a new equalizer preset:

1. Add to `PRESETS` dictionary in `app/player/equalizer.py`
2. Update the UI to include the new preset

## Recommendations

### Training Custom Models

The recommendation engine uses librosa for audio analysis. To customize:

1. Modify `app/recommendations/engine.py`
2. Adjust feature extraction weights
3. Test with your music library

## Packaging

### Building Packages

```bash
# Build all packages
bash packaging/build.sh

# Build specific package
# DEB
sudo dpkg-deb --build packaging/debian aurora-music.deb

# RPM
rpmbuild -ba packaging/rpm/aurora-music.spec

# Flatpak
flatpak-builder build packaging/flatpak/com.auroramusic.AuroraMusic.json

# AppImage
bash packaging/appimage/build_appimage.sh
```

## Debugging

### Logging

Aurora Music uses Python's logging module. To enable debug logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Common Issues

**MPV not working**: Ensure libmpv2 is installed
**QML not loading**: Check file paths in main_window.py
**Database locked**: Close other instances of the application

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run linters
6. Submit a pull request

## Release Process

1. Update version in `pyproject.toml`
2. Update CHANGELOG.md
3. Create git tag
4. Build packages
5. Upload to release page
6. Update documentation
