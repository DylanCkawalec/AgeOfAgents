#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="${ROOT_DIR}/logs/build"
LOG_FILE="${LOG_DIR}/macos-deps.log"
MISSING=0
PYTHON3_BASE="${PYTHON3_BASE:-/opt/homebrew/opt/python@3.12/bin/python3.12}"
VENV_DIR="${VENV_DIR:-${ROOT_DIR}/state/macos/venv}"
PYTHON3_BIN="${PYTHON3_BIN:-${VENV_DIR}/bin/python}"
PIP3_BIN="${PIP3_BIN:-${VENV_DIR}/bin/pip}"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/expat/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"

mkdir -p "${LOG_DIR}"
: > "${LOG_FILE}"

check_cmd() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    echo "[PASS] command ${cmd}: $(command -v "${cmd}")" | tee -a "${LOG_FILE}"
  else
    echo "[FAIL] command ${cmd} missing" | tee -a "${LOG_FILE}"
    MISSING=$((MISSING + 1))
  fi
}

check_brew_pkg() {
  local pkg="$1"
  if brew list --versions "${pkg}" >/dev/null 2>&1; then
    echo "[PASS] brew ${pkg}: $(brew list --versions "${pkg}")" | tee -a "${LOG_FILE}"
  else
    echo "[FAIL] brew ${pkg} missing" | tee -a "${LOG_FILE}"
    MISSING=$((MISSING + 1))
  fi
}

check_python_pkg() {
  local pkg="$1"
  if "${PYTHON3_BIN}" -c "import ${pkg}" >/dev/null 2>&1; then
    echo "[PASS] python ${pkg}" | tee -a "${LOG_FILE}"
  else
    echo "[FAIL] python ${pkg} missing" | tee -a "${LOG_FILE}"
    MISSING=$((MISSING + 1))
  fi
}

check_cmd brew
check_cmd cmake
if [ -x "${PYTHON3_BIN}" ]; then
  echo "[PASS] command python3: ${PYTHON3_BIN}" | tee -a "${LOG_FILE}"
else
  echo "[FAIL] command python3 missing at ${PYTHON3_BIN}" | tee -a "${LOG_FILE}"
  MISSING=$((MISSING + 1))
fi
if [ -x "${PIP3_BIN}" ]; then
  echo "[PASS] command pip3: ${PIP3_BIN}" | tee -a "${LOG_FILE}"
else
  echo "[FAIL] command pip3 missing at ${PIP3_BIN}" | tee -a "${LOG_FILE}"
  MISSING=$((MISSING + 1))
fi
check_cmd clang++
check_cmd make

if command -v brew >/dev/null 2>&1; then
  for pkg in cmake python@3.12 libepoxy freetype fontconfig harfbuzz opus opusfile qt6 libogg libpng toml11 eigen@3 llvm flex make; do
    check_brew_pkg "${pkg}"
  done
else
  echo "[FAIL] Homebrew missing; cannot check Homebrew packages" | tee -a "${LOG_FILE}"
  MISSING=$((MISSING + 1))
fi
if [ -x "${PYTHON3_BASE}" ]; then
  echo "[PASS] command python3 base: ${PYTHON3_BASE}" | tee -a "${LOG_FILE}"
else
  echo "[FAIL] command python3 base missing at ${PYTHON3_BASE}" | tee -a "${LOG_FILE}"
  MISSING=$((MISSING + 1))
fi

for pkg in Cython numpy mako lz4 PIL pygments setuptools toml; do
  check_python_pkg "${pkg}"
done

if [ "${MISSING}" -gt 0 ]; then
  echo "Native macOS dependency check failed with ${MISSING} missing item(s)." | tee -a "${LOG_FILE}"
  exit 1
fi

echo "Native macOS dependency check passed." | tee -a "${LOG_FILE}"
