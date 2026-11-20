#!/bin/bash
set -e

VERSION="0.1.0"
BUILD_DIR="dist"
DEB_OUTPUT="${BUILD_DIR}/nelvamusic_${VERSION}_all.deb"
PACKAGE_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/nelvamusic-package.XXXXXX")"
PACKAGE_ROOT="${PACKAGE_STAGE}/root"
APP_ROOT="${PACKAGE_ROOT}/usr/lib/nelvamusic"
trap 'rm -rf "${PACKAGE_STAGE}"' EXIT

echo "Preparing NelvaMusic distribution artifacts..."

# Clean previous build
mkdir -p "${BUILD_DIR}"

# Create source tarball
echo "Creating source tarball..."
tar -czf "${BUILD_DIR}/nelvamusic-${VERSION}.tar.gz" \
    --transform="s,^\.,nelvamusic-${VERSION}," \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='dist' \
    --exclude='build' \
    --exclude='.venv' \
    --exclude='build_appimage' \
    --exclude='venv' \
    .

echo "Building Debian package..."
mkdir -p "${APP_ROOT}" "${PACKAGE_ROOT}/usr/bin" \
    "${PACKAGE_ROOT}/usr/share/applications" \
    "${PACKAGE_ROOT}/usr/share/icons/hicolor/512x512/apps" \
    "${PACKAGE_ROOT}/DEBIAN"
cp -r app assets plugins "${APP_ROOT}/"
install -Dm644 pyproject.toml "${APP_ROOT}/pyproject.toml"
install -Dm644 requirements.txt "${APP_ROOT}/requirements.txt"
install -Dm644 packaging/debian/DEBIAN/control "${PACKAGE_ROOT}/DEBIAN/control"
install -Dm755 packaging/debian/DEBIAN/postinst "${PACKAGE_ROOT}/DEBIAN/postinst"
install -Dm755 packaging/debian/DEBIAN/postrm "${PACKAGE_ROOT}/DEBIAN/postrm"
install -Dm644 packaging/nelvamusic.desktop \
    "${PACKAGE_ROOT}/usr/share/applications/nelvamusic.desktop"
install -Dm644 assets/icons/Nelva.png \
    "${PACKAGE_ROOT}/usr/share/icons/hicolor/512x512/apps/nelva.png"
cat > "${PACKAGE_ROOT}/usr/bin/nelva" <<'EOF'
#!/usr/bin/python3
import sys
sys.path.insert(0, "/usr/lib/nelvamusic")
from app.main import main
main()
EOF
chmod 755 "${PACKAGE_ROOT}/usr/bin/nelva"
dpkg-deb --root-owner-group --build "${PACKAGE_ROOT}" "${DEB_OUTPUT}"

echo "Build artifacts created in ${BUILD_DIR}/"
echo ""
echo "To build specific packages:"
echo "  DEB:   ${DEB_OUTPUT}"
echo "  RPM:   rpmbuild -ba packaging/rpm/nelvamusic.spec"
echo "  Flatpak: packaging/flatpak/build.sh"
echo "  AppImage: packaging/appimage/build_appimage.sh (requires PySide6/Nuitka and libmpv)"
