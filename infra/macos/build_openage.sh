#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ACTION="${1:-configure}"
LOG_DIR="${ROOT_DIR}/logs/runtime"
LOG_FILE="${LOG_DIR}/macos-openage.log"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"
VENV_DIR="${VENV_DIR:-${ROOT_DIR}/state/macos/venv}"
PYTHON3_BIN="${PYTHON3_BIN:-${VENV_DIR}/bin/python}"
MAKE_BIN="${MAKE_BIN:-$(command -v gmake || command -v make)}"
EIGEN3_DIR="${EIGEN3_DIR:-$(brew --prefix eigen@3 2>/dev/null)/share/eigen3/cmake}"
NATIVE_BUILD_DIR="${NATIVE_BUILD_DIR:-.bin/opt-homebrew-opt-llvm-bin-clang++-debug-Oauto-sanitize-none}"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/expat/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"

mkdir -p "${LOG_DIR}"

usage() {
  cat <<'EOF'
Usage: build_openage.sh configure|compile|run|game|full|all
EOF
}

record_failure() {
  local action="$1"
  {
    echo
    echo "## $(date -u '+%Y-%m-%dT%H:%M:%SZ') native macOS openage ${action} failed"
    echo
    echo "- Command: infra/macos/build_openage.sh ${action}"
    echo "- Log file: logs/runtime/macos-openage.log"
    echo "- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers."
    echo "- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command."
  } >> "${BUILD_ERROR_LOG}"
}

llvm_clang="$(brew --prefix llvm 2>/dev/null)/bin/clang++"
if [ ! -x "${llvm_clang}" ]; then
  llvm_clang="$(command -v clang++ || true)"
fi

case "${ACTION}" in
  configure|compile|run|game|full|all) ;;
  *)
    usage
    exit 1
    ;;
esac

run_action() {
  cd "${ROOT_DIR}"
  ensure_native_bin() {
    if [ -d "${NATIVE_BUILD_DIR}" ]; then
      if [ -L bin ] || [ ! -e bin ]; then
        ln -sfn "${NATIVE_BUILD_DIR}" bin
      else
        echo "ERROR: bin exists and is not a symlink; refusing to overwrite"
        exit 1
      fi
    else
      echo "ERROR: missing native build dir ${NATIVE_BUILD_DIR}. Run configure first."
      exit 1
    fi
  }
  case "${ACTION}" in
    configure)
      "${PYTHON3_BIN}" ./configure --compiler="${llvm_clang}" --download-nyan -- -DPython3_EXECUTABLE="${PYTHON3_BIN}" -DEigen3_DIR="${EIGEN3_DIR}"
      ;;
    compile)
      ensure_native_bin
      "${MAKE_BIN}" -j"$(sysctl -n hw.ncpu)"
      ;;
    run)
      ensure_native_bin
      test -x ./bin/run && ./bin/run --help
      ;;
    game|full)
      ensure_native_bin
      test -x ./bin/run && ./bin/run main
      ;;
    all)
      "${PYTHON3_BIN}" ./configure --compiler="${llvm_clang}" --download-nyan -- -DPython3_EXECUTABLE="${PYTHON3_BIN}" -DEigen3_DIR="${EIGEN3_DIR}"
      "${MAKE_BIN}" -j"$(sysctl -n hw.ncpu)"
      ./bin/run --help
      ;;
  esac
}

run_action 2>&1 | tee -a "${LOG_FILE}" || {
  record_failure "${ACTION}"
  exit 1
}
