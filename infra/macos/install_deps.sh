#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="${ROOT_DIR}/logs/build"
LOG_FILE="${LOG_DIR}/macos-deps-install.log"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"
PYTHON3_BASE="${PYTHON3_BASE:-/opt/homebrew/opt/python@3.12/bin/python3.12}"
VENV_DIR="${VENV_DIR:-${ROOT_DIR}/state/macos/venv}"
PYTHON3_BIN="${PYTHON3_BIN:-${VENV_DIR}/bin/python}"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/expat/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"

mkdir -p "${LOG_DIR}"

record_failure() {
  {
    echo
    echo "## $(date -u '+%Y-%m-%dT%H:%M:%SZ') native macOS dependency install failed"
    echo
    echo "- Command: infra/macos/install_deps.sh"
    echo "- Log file: logs/build/macos-deps-install.log"
    echo "- Likely root cause: inspect the Homebrew or pip error in the install log."
    echo "- Next step fix: resolve the first package installation error, then rerun this exact command."
  } >> "${BUILD_ERROR_LOG}"
}

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is required for native macOS dependency installation." | tee -a "${LOG_FILE}"
  record_failure
  exit 1
fi

{
  echo "== $(date -u '+%Y-%m-%dT%H:%M:%SZ') installing native macOS deps =="
  brew install --cask font-dejavu || true
  brew install cmake python@3.12 expat libepoxy freetype fontconfig harfbuzz opus opusfile qt6 libogg libpng toml11 eigen@3 llvm flex make
  "${PYTHON3_BASE}" -m venv "${VENV_DIR}"
  "${PYTHON3_BIN}" -m pip install --upgrade pip setuptools wheel
  "${PYTHON3_BIN}" -m pip install --upgrade "cython>=3.0.10,<4.0.0" numpy mako lz4 pillow pygments toml
} 2>&1 | tee -a "${LOG_FILE}" || {
  record_failure
  exit 1
}
