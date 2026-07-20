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

### Prerequisites

**System Dependencies:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install python3.13 libmpv2 mpv

# Fedora/RHEL
sudo dnf install python3.13 mpv-libs

# Arch Linux
sudo pacman -S python mpv
```

### From Source

```bash
# Clone the repository
git clone https://github.com/sammymullern/aurora-music.git
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

## Usage

### First Run

When you first launch Aurora Music:

1. **Add Music Library**: Navigate to Settings → Music Library and add your music folders
2. **Scan Library**: The app will automatically scan and index your audio files
3. **Start Playing**: Browse your library and click play on any track

### Main Features

**Library Management**
- Automatic folder monitoring with watchdog
- Support for 12+ audio formats
- Metadata extraction using Mutagen
- Instant search and filtering

**Playback Controls**
- Play/Pause, Next/Previous track
- Progress bar with seeking
- Volume control
- Queue management
- Shuffle and repeat modes

**Audio Enhancement**
- 10-band equalizer with 9 presets (Flat, Bass Boost, Treble Boost, Vocal, Rock, Classical, Electronic, Jazz, Pop)
- Custom equalizer settings
- ReplayGain support (track/album mode)
- Crossfade (configurable duration)
- Audio normalization
- Voice enhancement

**Smart Features**
- AI-powered recommendations using librosa audio analysis
- Mood-based playlists
- Similar track suggestions
- Automatic BPM detection

**Customization**
- 4 built-in themes (Dark, Light, Midnight, Aurora)
- Glassmorphism UI design
- Animated backgrounds
- Album-art dynamic backgrounds
- Custom theme support

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Play/Pause |
| → | Next track |
| ← | Previous track |
| ↑ | Volume up |
| ↓ | Volume down |
| F | Fullscreen |
| Ctrl+F | Focus search |
| Ctrl+Q | Quit |
| Ctrl+N | New playlist |
| Ctrl+P | Preferences |

## Configuration

### Settings Location

Aurora Music stores configuration in:
- Linux: `~/.config/Aurora Music/aurora-music.conf`
- Database: `~/.local/share/aurora-music/aurora.db`

### Audio Settings

Configure audio backend and output device in Settings → Audio:
- **Audio Backend**: MPV (recommended) or GStreamer
- **Output Device**: Default, PulseAudio, PipeWire, or ALSA
- **Buffer Size**: Adjust for performance vs latency

### Library Settings

Configure library behavior in Settings → Music Library:
- **Watch Folders**: Automatically monitor for changes
- **Scan Frequency**: How often to check for new files
- **Import Mode**: Reference (keep files in place) or Managed (copy to library)

## Troubleshooting

### Common Issues

**Application won't start**
```bash
# Ensure system dependencies are installed
sudo apt-get install libmpv2 mpv

# Check Python version
python3 --version  # Should be 3.13+
```

**No audio output**
```bash
# Check MPV installation
mpv --version

# Test audio system
pactl info  # For PulseAudio
pwpctl info # For PipeWire
```

**Library scan stuck**
- Check folder permissions
- Ensure audio files are not corrupted
- Try scanning smaller folders first

**High CPU usage**
- Disable AI recommendations in settings
- Reduce equalizer bands
- Lower audio buffer size

### Debug Mode

Run with debug logging:
```bash
export AURORA_DEBUG=1
python -m app.main
```

## Screenshots

![Main Window](https://github.com/sammymullern/aurora-music/raw/main/assets/screenshots/main.png)
*Main interface with library view*

![Now Playing](https://github.com/sammymullern/aurora-music/raw/main/assets/screenshots/now-playing.png)
*Now playing view with album art*

![Equalizer](https://github.com/sammymullern/aurora-music/raw/main/assets/screenshots/equalizer.png)
*10-band equalizer with presets*

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Run linting: `ruff check app/` and `black app/`
6. Run tests: `pytest`
7. Submit a pull request

### Code Style

- Use Black for formatting
- Follow PEP 8 guidelines
- Add docstrings to functions
- Write tests for new features

## Roadmap

### Planned Features

- [ ] Lyrics display and synchronization
- [ ] Podcast support
- [ ] Internet radio streaming
- [ ] Cloud storage integration
- [ ] Mobile companion app
- [ ] Social features (sharing, playlists)
- [ ] Advanced audio visualization
- [ ] CD ripping support
- [ ] MusicBrainz integration
- [ ] Last.fm scrobbling
- [ ] MPRIS D-Bus interface
- [ ] Command-line interface

## Acknowledgments

- **MPV** - Audio playback engine
- **PySide6** - Qt framework for Python
- **Librosa** - Audio analysis library
- **Mutagen** - Audio metadata handling
- **SQLAlchemy** - Database ORM

## License

MIT License - See LICENSE file for details

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
