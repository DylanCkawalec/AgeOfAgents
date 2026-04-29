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
if [ -x "${PYTHON3_BIN}" ]; then
  PYTHON_SITE_PACKAGES="$("${PYTHON3_BIN}" -c 'import site; print(":".join(site.getsitepackages()))' 2>/dev/null || true)"
  if [ -n "${PYTHON_SITE_PACKAGES}" ]; then
    export PYTHONPATH="${PYTHON_SITE_PACKAGES}${PYTHONPATH:+:${PYTHONPATH}}"
  fi
fi
export OPENAGE_SKIP_GUI="${OPENAGE_SKIP_GUI:-1}"

mkdir -p "${LOG_DIR}"

usage() {
  cat <<'EOF'
Usage: build_openage.sh configure|compile|run|game|full|convert|demo|all
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
  configure|compile|run|game|full|convert|demo|all) ;;
  *)
    usage
    exit 1
    ;;
esac

run_action() {
  cd "${ROOT_DIR}"
  ensure_native_bin() {
    if [ -d "${NATIVE_BUILD_DIR}" ]; then
      if [ -L bin ]; then
        rm -f bin
        ln -s "${NATIVE_BUILD_DIR}" bin
      elif [ ! -e bin ]; then
        ln -s "${NATIVE_BUILD_DIR}" bin
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
      test -x ./bin/run && cd bin && ./run --help
      ;;
    game|full)
      ensure_native_bin
      test -x ./bin/run && cd bin
      if [ -n "${AGE_MODPACKS:-}" ]; then
        read -r -a modpacks <<< "${AGE_MODPACKS}"
        ./run game --modpacks "${modpacks[@]}"
      elif [ -n "${OPENAGE_STDIN:-}" ]; then
        printf '%s\n' "${OPENAGE_STDIN}" | ./run main
      else
        ./run main
      fi
      ;;
    convert)
      ensure_native_bin
      if [ -z "${AGE_ASSET_SOURCE_DIR:-}" ]; then
        echo "ERROR: AGE_ASSET_SOURCE_DIR must point to a supported game installation before conversion."
        exit 1
      fi
      if [ ! -d "${AGE_ASSET_SOURCE_DIR}" ]; then
        echo "ERROR: AGE_ASSET_SOURCE_DIR does not exist or is not a directory: ${AGE_ASSET_SOURCE_DIR}"
        exit 1
      fi
      test -x ./bin/run && cd bin
      convert_args=(convert --force --no-prompts --source-dir "${AGE_ASSET_SOURCE_DIR}" --output-dir "${AGE_ASSET_OUTPUT_DIR:-${ROOT_DIR}/assets}")
      if [ -n "${AGE_CONVERT_JOBS:-}" ]; then
        convert_args+=(-j "${AGE_CONVERT_JOBS}")
      fi
      ./run "${convert_args[@]}"
      ;;
    demo)
      ensure_native_bin
      test -x ./bin/run && cd bin && ./run test -d openage.main.tests.engine_demo "${AGE_DEMO_ID:-0}"
      ;;
    all)
      "${PYTHON3_BIN}" ./configure --compiler="${llvm_clang}" --download-nyan -- -DPython3_EXECUTABLE="${PYTHON3_BIN}" -DEigen3_DIR="${EIGEN3_DIR}"
      "${MAKE_BIN}" -j"$(sysctl -n hw.ncpu)"
      cd bin && ./run --help
      ;;
  esac
}

run_action 2>&1 | tee -a "${LOG_FILE}" || {
  record_failure "${ACTION}"
  exit 1
}
