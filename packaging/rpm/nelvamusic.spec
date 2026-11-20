Name:           nelvamusic
Version:        0.1.0
Release:        1%{?dist}
Summary:        Premium native Linux music application

License:        MIT
URL:            https://github.com/sammymullern/aurora-music
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch

Requires:       python3 >= 3.11
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
NelvaMusic is a modern music player with a beautiful UI, broad audio
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
mkdir -p %{buildroot}/usr/lib/nelvamusic
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/512x512/apps

cp -r app %{buildroot}/usr/lib/nelvamusic/
cp -r assets %{buildroot}/usr/lib/nelvamusic/
cp -r plugins %{buildroot}/usr/lib/nelvamusic/
cp requirements.txt %{buildroot}/usr/lib/nelvamusic/
cp pyproject.toml %{buildroot}/usr/lib/nelvamusic/

cat > %{buildroot}/usr/bin/nelva << 'EOF'
#!/usr/bin/env python3
import sys
sys.path.insert(0, '/usr/lib/nelvamusic')
from app.main import main
main()
EOF
chmod +x %{buildroot}/usr/bin/nelva

cp packaging/nelvamusic.desktop %{buildroot}/usr/share/applications/
cp assets/icons/Nelva.png %{buildroot}/usr/share/icons/hicolor/512x512/apps/nelva.png

%files
/usr/lib/nelvamusic/*
/usr/bin/nelva
/usr/share/applications/nelvamusic.desktop
/usr/share/icons/hicolor/512x512/apps/nelva.png

%changelog
* %(date "+%%a %%b %%d %%Y") NelvaMusic Team <team@auroramusic.com> - 0.1.0-1
- Initial release
