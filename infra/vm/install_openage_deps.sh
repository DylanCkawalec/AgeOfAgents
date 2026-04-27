#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_NAME="${VM_NAME:-ageofagents}"
LOG_DIR="${ROOT_DIR}/logs/build"

mkdir -p "${LOG_DIR}"

if ! command -v limactl >/dev/null 2>&1; then
  echo "ERROR: limactl not found on host." | tee -a "${LOG_DIR}/deps-install.log"
  exit 1
fi

limactl shell "${VM_NAME}" -- bash -lc '
  set -euo pipefail
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    g++ \
    cmake \
    ninja-build \
    git \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-setuptools \
    python3-mako \
    python3-numpy \
    python3-lz4 \
    python3-pil \
    python3-pygments \
    python3-toml \
    libeigen3-dev \
    libpng-dev \
    libepoxy-dev \
    libfreetype-dev \
    libopusfile-dev \
    libopus-dev \
    libogg-dev \
    libharfbuzz-dev \
    libfontconfig1-dev \
    libtoml11-dev \
    libncurses-dev \
    qt6-declarative-dev \
    qt6-multimedia-dev \
    qml6-module-qtquick-controls \
    qml6-module-qtquick3d-spatialaudio \
    fonts-dejavu-core \
    mesa-utils
  python3 -m pip install --break-system-packages "cython>=3.0.10"
' 2>&1 | tee -a "${LOG_DIR}/deps-install.log"

echo "Dependency install complete for VM ${VM_NAME}" | tee -a "${LOG_DIR}/deps-install.log"
