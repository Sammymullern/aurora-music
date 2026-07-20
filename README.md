# Aurora Music

A premium native Linux music application with modern UI, broad audio support, SQLite-indexed library, automatic folder monitoring, professional audio processing, themes, plugins, and AI-powered recommendations.

## Features

- **Native Linux App**: Available as DEB/RPM/AppImage/Flatpak
- **Modern UI**: PySide6+QML with glassmorphism design
- **Audio Support**: MP3, FLAC, WAV, OGG, OPUS, AAC, ALAC, AIFF, APE, WavPack, MIDI, DSD and more
- **Advanced Playback**: Gapless playback, crossfade, ReplayGain, DSP & voice enhancement
- **Smart Library**: SQLite-indexed with automatic folder monitoring
- **Filters**: Artist, Album, Genre, Year, Mood, BPM, Bitrate, Favorites, Recently Added, Lossless, Rating
- **Customization**: Multiple themes, animated backgrounds, album-art dynamic backgrounds
- **AI Recommendations**: Powered by librosa for intelligent music suggestions
- **Plugin System**: Extensible architecture for custom features

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/yourusername/aurora-music.git
cd aurora-music

# Create virtual environment
python3.13 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m app.main
```

### Development Setup

```bash
pip install -r requirements-dev.txt
```

## Project Structure

```
aurora-music/
├── app/
│   ├── ui/           # PySide6+QML user interface
│   ├── player/       # Audio playback engine (MPV/GStreamer)
│   ├── library/      # Library management and scanner
│   ├── database/     # SQLite database models and operations
│   ├── metadata/     # Audio metadata extraction (Mutagen)
│   ├── recommendations/  # AI-powered recommendations
│   ├── themes/       # Theme system and assets
│   └── plugins/      # Plugin system
├── assets/           # Images, icons, themes
├── tests/            # Unit and integration tests
└── docs/             # Documentation
```

## Development Phases

1. **Phase 1**: Project setup and playback engine
2. **Phase 2**: Library scanning and SQLite
3. **Phase 3**: Modern UI
4. **Phase 4**: Playback controls & playlists
5. **Phase 5**: Equalizer & DSP
6. **Phase 6**: Themes and branding
7. **Phase 7**: Recommendations & AI
8. **Phase 8**: Plugin system
9. **Phase 9**: Packaging and testing

## Technology Stack

- **Python 3.13**: Core language
- **PySide6/QML**: User interface framework
- **SQLite + SQLAlchemy**: Database
- **python-mpv**: Audio playback engine
- **Watchdog**: File system monitoring
- **Mutagen**: Audio metadata extraction
- **Librosa**: Audio analysis for recommendations
- **Pillow**: Image processing
- **pytest**: Testing framework
- **Ruff**: Linting
- **Black**: Code formatting

## License

MIT License - See LICENSE file for details
