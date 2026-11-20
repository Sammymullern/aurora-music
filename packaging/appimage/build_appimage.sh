#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_PYTHON="${NELVA_BUILD_PYTHON:-python3}"
VERSION="0.1.0"
APP_NAME="NelvaMusic"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/nelvamusic-appimage.XXXXXX")"
trap 'rm -rf "${WORK_DIR}"' EXIT
APP_DIR="${WORK_DIR}/${APP_NAME}.AppDir"
DEPLOY_DIR="${WORK_DIR}/deploy"
DIST_DIR="${PROJECT_ROOT}/dist"

if [[ "$(uname -m)" != "x86_64" ]]; then
    echo "The current AppImage recipe supports x86_64 builds only." >&2
    exit 2
fi

if ! command -v "${BUILD_PYTHON}" >/dev/null 2>&1; then
    echo "Python build interpreter not found: ${BUILD_PYTHON}" >&2
    exit 2
fi

if ! "${BUILD_PYTHON}" -c 'import PySide6, librosa, mpv, numpy, scipy, soundfile' >/dev/null 2>&1; then
    echo "The build interpreter needs NelvaMusic dependencies installed. Set NELVA_BUILD_PYTHON to a prepared environment." >&2
    exit 2
fi

LIBMPV_PATH="${NELVA_LIBMPV_PATH:-}"
if [[ -z "${LIBMPV_PATH}" ]]; then
    LIBMPV_PATH="$(ldconfig -p | awk '/libmpv\.so\.2 / { print $NF; exit }')"
fi
if [[ -z "${LIBMPV_PATH}" || ! -f "${LIBMPV_PATH}" ]]; then
    echo "libmpv.so.2 was not found. Install MPV development/runtime libraries or set NELVA_LIBMPV_PATH." >&2
    exit 2
fi

DEPLOY_BIN="$("${BUILD_PYTHON}" -c 'import sys; print(sys.prefix + "/bin/pyside6-deploy")')"
if [[ ! -x "${DEPLOY_BIN}" ]]; then
    echo "pyside6-deploy is missing from ${BUILD_PYTHON}; install the PySide6 package in that environment." >&2
    exit 2
fi

SPEC_FILE="${WORK_DIR}/pysidedeploy.spec"
sed \
    -e "s|^project_dir = .*$|project_dir = ${PROJECT_ROOT}|" \
    -e "s|^exec_directory = .*$|exec_directory = ${DEPLOY_DIR}|" \
    "${PROJECT_ROOT}/packaging/appimage/pysidedeploy.spec" > "${SPEC_FILE}"

echo "Compiling NelvaMusic with its Python and Qt runtime..."
cd "${PROJECT_ROOT}"
"${DEPLOY_BIN}" -c "${SPEC_FILE}" --no-warn -f

DEPLOYED_APP="${DEPLOY_DIR}/${APP_NAME}.dist"
if [[ ! -x "${DEPLOYED_APP}/${APP_NAME}.bin" ]]; then
    echo "pyside6-deploy did not produce ${APP_NAME}.dist/${APP_NAME}.bin." >&2
    exit 1
fi

mkdir -p \
    "${APP_DIR}/usr/bin" \
    "${APP_DIR}/usr/lib/nelvamusic" \
    "${APP_DIR}/usr/share/applications" \
    "${APP_DIR}/usr/share/icons/hicolor/512x512/apps"
cp -a "${DEPLOYED_APP}/." "${APP_DIR}/usr/lib/nelvamusic/"
install -Dm755 "${PROJECT_ROOT}/packaging/appimage/AppRun" "${APP_DIR}/AppRun"
install -Dm755 "${PROJECT_ROOT}/packaging/appimage/nelva" "${APP_DIR}/usr/bin/nelva"
install -Dm644 "${PROJECT_ROOT}/packaging/nelvamusic.desktop" \
    "${APP_DIR}/usr/share/applications/nelvamusic.desktop"
sed -i 's/^Exec=nelva$/Exec=AppRun/' "${APP_DIR}/usr/share/applications/nelvamusic.desktop"
install -Dm644 "${PROJECT_ROOT}/assets/icons/Nelva.png" \
    "${APP_DIR}/usr/share/icons/hicolor/512x512/apps/nelva.png"

LINUXDEPLOY="${WORK_DIR}/linuxdeploy-x86_64.AppImage"
curl --fail --location --retry 2 \
    --output "${LINUXDEPLOY}" \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x "${LINUXDEPLOY}"

mkdir -p "${DIST_DIR}"
export APPIMAGE_EXTRACT_AND_RUN=1
export LD_LIBRARY_PATH="${APP_DIR}/usr/lib:${APP_DIR}/usr/lib/nelvamusic${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
cd "${WORK_DIR}"
"${LINUXDEPLOY}" \
    --appdir "${APP_DIR}" \
    --executable "${APP_DIR}/usr/lib/nelvamusic/${APP_NAME}.bin" \
    --library "${LIBMPV_PATH}" \
    --desktop-file "${APP_DIR}/usr/share/applications/nelvamusic.desktop" \
    --icon-file "${APP_DIR}/usr/share/icons/hicolor/512x512/apps/nelva.png" \
    --output appimage

mv "${WORK_DIR}/${APP_NAME}-x86_64.AppImage" \
    "${DIST_DIR}/${APP_NAME}-${VERSION}-x86_64.AppImage"
echo "Built ${DIST_DIR}/${APP_NAME}-${VERSION}-x86_64.AppImage"
