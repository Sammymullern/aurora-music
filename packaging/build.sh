#!/bin/bash
set -e

VERSION="0.1.0"
BUILD_DIR="dist"

echo "Building Aurora Music packages..."

# Clean previous build
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Create source tarball
echo "Creating source tarball..."
tar -czf "${BUILD_DIR}/aurora-music-${VERSION}.tar.gz" \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='dist' \
    --exclude='build' \
    --exclude='.venv' \
    --exclude='venv' \
    .

echo "Build artifacts created in ${BUILD_DIR}/"
echo ""
echo "To build specific packages:"
echo "  DEB:   sudo dpkg-deb --build packaging/debian aurora-music_${VERSION}_amd64.deb"
echo "  RPM:   rpmbuild -ba packaging/rpm/aurora-music.spec"
echo "  Flatpak: flatpak-builder build packaging/flatpak/com.auroramusic.AuroraMusic.json"
echo "  AppImage: bash packaging/appimage/build_appimage.sh"
