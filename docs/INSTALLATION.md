# Installation Guide

## From Source

### Prerequisites

- Python 3.13 or higher
- pip
- MPV library
- FFmpeg (optional, for additional format support)

### Installation Steps

```bash
# Clone the repository
git clone https://github.com/auroramusic/aurora-music.git
cd aurora-music

# Create virtual environment
python3.13 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m app.main
```

## Package Installation

### DEB (Debian/Ubuntu)

```bash
# Download the .deb package
wget https://github.com/auroramusic/aurora-music/releases/download/v0.1.0/aurora-music_0.1.0_amd64.deb

# Install
sudo dpkg -i aurora-music_0.1.0_amd64.deb

# Fix dependencies if needed
sudo apt-get install -f
```

### RPM (Fedora/RHEL/openSUSE)

```bash
# Download the .rpm package
wget https://github.com/auroramusic/aurora-music/releases/download/v0.1.0/aurora-music-0.1.0-1.x86_64.rpm

# Install
sudo dnf install aurora-music-0.1.0-1.x86_64.rpm
# or on openSUSE:
sudo zypper install aurora-music-0.1.0-1.x86_64.rpm
```

### Flatpak

```bash
# Install from Flathub (when available)
flatpak install flathub com.auroramusic.AuroraMusic

# Or build from source
flatpak-builder build packaging/flatpak/com.auroramusic.AuroraMusic.json
flatpak install build/com.auroramusic.AuroraMusic.flatpak

# Run
flatpak run com.auroramusic.AuroraMusic
```

### AppImage

```bash
# Download the AppImage
wget https://github.com/auroramusic/aurora-music/releases/download/v0.1.0/AuroraMusic-0.1.0-x86_64.AppImage

# Make executable
chmod +x AuroraMusic-0.1.0-x86_64.AppImage

# Run
./AuroraMusic-0.1.0-x86_64.AppImage
```

## Development Installation

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

# Run tests
pytest

# Run with linting
ruff check app/
black app/
mypy app/
```

## System Requirements

### Minimum Requirements

- **OS**: Linux (kernel 5.4 or higher)
- **CPU**: x86_64 or ARM64
- **RAM**: 2 GB
- **Storage**: 500 MB for application, additional space for music library
- **Python**: 3.13 or higher

### Recommended Requirements

- **OS**: Linux (kernel 6.0 or higher)
- **CPU**: Modern multi-core processor
- **RAM**: 4 GB or more
- **Storage**: SSD recommended for faster library scanning
- **Audio**: PulseAudio or PipeWire

## Dependencies

### Core Dependencies

- PySide6 >= 6.6.0
- SQLAlchemy >= 2.0.0
- python-mpv >= 1.0.0
- watchdog >= 4.0.0
- mutagen >= 1.47.0

### Audio Analysis

- librosa >= 0.10.0
- numpy >= 1.24.0
- scipy >= 1.11.0
- soundfile >= 0.12.0

### Image Processing

- Pillow >= 10.0.0

### System Libraries

- libmpv2
- ffmpeg (optional)

## Troubleshooting

### MPV Not Found

If you encounter an error about MPV not being found:

```bash
# Ubuntu/Debian
sudo apt-get install libmpv2

# Fedora/RHEL
sudo dnf install mpv-libs

# Arch Linux
sudo pacman -S mpv
```

### Audio Backend Issues

If you experience audio playback issues:

```bash
# Install PulseAudio
sudo apt-get install pulseaudio

# Or PipeWire (recommended)
sudo apt-get install pipewire pipewire-pulse
```

### Python Version

Aurora Music requires Python 3.13. If your distribution doesn't provide it:

```bash
# Install from pyenv
curl https://pyenv.run | bash
pyenv install 3.13.0
pyenv global 3.13.0
```

## Uninstallation

### From Source

```bash
# Remove virtual environment
rm -rf venv

# Remove source directory
rm -rf aurora-music
```

### DEB Package

```bash
sudo apt-get remove aurora-music
```

### RPM Package

```bash
sudo dnf remove aurora-music
```

### Flatpak

```bash
flatpak uninstall com.auroramusic.AuroraMusic
```

### AppImage

Simply delete the AppImage file.
