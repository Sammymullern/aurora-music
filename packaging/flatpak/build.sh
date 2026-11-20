#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLATPAK_DIR="${PROJECT_ROOT}/packaging/flatpak"
BUILD_ROOT="${PROJECT_ROOT}/dist/flatpak-build"
MANIFEST="${FLATPAK_DIR}/com.nelva.NelvaMusic.json"
SOURCE_SET="${FLATPAK_DIR}/python3-dependencies.json"
PIP_GENERATOR="${FLATPAK_PIP_GENERATOR:-flatpak-pip-generator}"
FLATPAK_BUILDER="${FLATPAK_BUILDER:-flatpak-builder}"

if ! command -v "${PIP_GENERATOR}" >/dev/null 2>&1; then
    echo "flatpak-pip-generator is required. Install it from flatpak/flatpak-builder-tools/pip." >&2
    exit 2
fi
if ! command -v "${FLATPAK_BUILDER}" >/dev/null 2>&1; then
    echo "flatpak-builder is required to build NelvaMusic." >&2
    exit 2
fi

flatpak install --user -y flathub org.kde.Platform//6.11 org.kde.Sdk//6.11

"${PIP_GENERATOR}" \
    --runtime=org.kde.Sdk//6.11 \
    --requirements-file="${FLATPAK_DIR}/requirements.txt" \
    --prefer-wheels=PySide6,PySide6_Essentials,PySide6_Addons,shiboken6,numpy,scipy,scikit-learn,numba,llvmlite,soundfile,soxr,Pillow \
    --wheel-arches=x86_64 \
    --output="${SOURCE_SET}"

mkdir -p "${BUILD_ROOT}"
"${FLATPAK_BUILDER}" \
    --user \
    --install-deps-from=flathub \
    --force-clean \
    --repo="${BUILD_ROOT}/repo" \
    "${BUILD_ROOT}/build" \
    "${MANIFEST}"
flatpak build-bundle \
    "${BUILD_ROOT}/repo" \
    "${PROJECT_ROOT}/dist/NelvaMusic.flatpak" \
    com.nelva.NelvaMusic
