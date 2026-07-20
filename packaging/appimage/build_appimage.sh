#!/bin/bash
set -e

VERSION="0.1.0"
APPNAME="AuroraMusic"
BUILD_DIR="build_appimage"
APPDIR="${BUILD_DIR}/${APPNAME}.AppDir"

echo "Building Aurora Music AppImage..."

# Clean previous build
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Create AppDir structure
mkdir -p "${APPDIR}/usr/bin"
mkdir -p "${APPDIR}/usr/lib"
mkdir -p "${APPDIR}/usr/share/applications"
mkdir -p "${APPDIR}/usr/share/icons/hicolor/scalable/apps"
mkdir -p "${APPDIR}/usr/share/metainfo"

# Copy Python application
cp -r app "${APPDIR}/usr/"
cp -r assets "${APPDIR}/usr/"
cp -r plugins "${APPDIR}/usr/"
cp requirements.txt "${APPDIR}/usr/"
cp pyproject.toml "${APPDIR}/usr/"

# Copy desktop file
cp packaging/aurora-music.desktop "${APPDIR}/usr/share/applications/${APPNAME}.desktop"

# Copy icon
cp assets/images/logo-icon.svg "${APPDIR}/usr/share/icons/hicolor/scalable/apps/${APPNAME}.svg"

# Copy AppRun
cp packaging/appimage/AppRun "${APPDIR}/"
chmod +x "${APPDIR}/AppRun"

# Download and extract linuxdeploy
if [ ! -f "linuxdeploy-x86_64.AppImage" ]; then
    wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
    chmod +x linuxdeploy-x86_64.AppImage
fi

if [ ! -f "linuxdeploy-plugin-qt-x86_64.AppImage" ]; then
    wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
    chmod +x linuxdeploy-plugin-qt-x86_64.AppImage
fi

# Build AppImage
export LD_LIBRARY_PATH="${APPDIR}/usr/lib"
export QMAKE=/usr/bin/qmake6

./linuxdeploy-x86_64.AppImage \
    --appdir="${APPDIR}" \
    --plugin qt \
    --output appimage

echo "AppImage build complete!"
