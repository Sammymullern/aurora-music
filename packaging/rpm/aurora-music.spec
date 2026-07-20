Name:           aurora-music
Version:        0.1.0
Release:        1%{?dist}
Summary:        Premium native Linux music application

License:        MIT
URL:            https://auroramusic.com
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch

Requires:       python3 >= 3.13
Requires:       python3-pyside6
Requires:       python3-sqlalchemy
Requires:       python3-mpv
Requires:       python3-watchdog
Requires:       python3-mutagen
Requires:       python3-librosa
Requires:       python3-pillow
Requires:       python3-numpy
Requires:       python3-scipy
Requires:       python3-soundfile
Requires:       mpv-libs

Recommends:     ffmpeg

%description
Aurora Music is a modern music player with a beautiful UI, broad audio
support, SQLite-indexed library, automatic folder monitoring, professional
audio processing, themes, plugins, and AI-powered recommendations.

Features:
- Modern PySide6+QML interface with glassmorphism design
- Support for MP3, FLAC, WAV, OGG, OPUS, AAC, ALAC, AIFF, APE, WavPack, and more
- Gapless playback, crossfade, and ReplayGain
- 10-band equalizer with presets
- Automatic library scanning and folder monitoring
- AI-powered recommendations using librosa
- Extensible plugin system

%prep
%autosetup

%build
# No build step for Python package

%install
mkdir -p %{buildroot}/usr/lib/aurora-music
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps

cp -r app %{buildroot}/usr/lib/aurora-music/
cp -r assets %{buildroot}/usr/lib/aurora-music/
cp -r plugins %{buildroot}/usr/lib/aurora-music/
cp requirements.txt %{buildroot}/usr/lib/aurora-music/
cp pyproject.toml %{buildroot}/usr/lib/aurora-music/

cat > %{buildroot}/usr/bin/aurora << 'EOF'
#!/usr/bin/env python3
import sys
sys.path.insert(0, '/usr/lib/aurora-music')
from app.main import main
main()
EOF
chmod +x %{buildroot}/usr/bin/aurora

cp packaging/aurora-music.desktop %{buildroot}/usr/share/applications/
cp assets/images/logo-icon.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/aurora-music.svg

%files
/usr/lib/aurora-music/*
/usr/bin/aurora
/usr/share/applications/aurora-music.desktop
/usr/share/icons/hicolor/scalable/apps/aurora-music.svg

%changelog
* %(date "+%%a %%b %%d %%Y") Aurora Music Team <team@auroramusic.com> - 0.1.0-1
- Initial release
