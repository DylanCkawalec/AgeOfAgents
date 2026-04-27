#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_NAME="${VM_NAME:-ageofagents}"
VM_MOUNT_POINT="${VM_MOUNT_POINT:-/mnt/developer}"
LOG_DIR="${ROOT_DIR}/logs/runtime"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"
ACTION="${1:-all}"
GUEST_REPO="${VM_MOUNT_POINT}/openage-ageofagents"

mkdir -p "${LOG_DIR}"

case "${ACTION}" in
  configure|compile|run|game|full|all) ;;
  *)
    echo "Usage: run_engine.sh [configure|compile|run|all]" >&2
    exit 1
    ;;
esac

if ! limactl shell "${VM_NAME}" -- bash -lc "
  set -euo pipefail
  cd '${GUEST_REPO}'
  case '${ACTION}' in
    configure)
      ./configure --download-nyan
      ;;
    compile)
      cmake --build build -j\$(nproc)
      ;;
    run)
      ./bin/run --help
      ;;
    game|full)
      test -x ./bin/run
      ./bin/run main
      ;;
    all)
      ./configure --download-nyan
      cmake --build build -j\$(nproc)
      ./bin/run --help
      ;;
  esac
" 2>&1 | tee -a "${LOG_DIR}/run-engine.log"; then
  {
    echo
    echo "## $(date -u '+%Y-%m-%dT%H:%M:%SZ') run_engine ${ACTION} failed"
    echo
    echo "- Command: infra/vm/run_engine.sh ${ACTION}"
    echo "- VM command: cd ${GUEST_REPO} && action=${ACTION}"
    echo "- Log file: logs/runtime/run-engine.log"
    echo "- Likely root cause: inspect the runtime log for the first missing dependency, build error, or display/runtime blocker."
    echo "- Next step fix: address the first failing dependency or runtime blocker, then rerun this exact command."
  } >> "${BUILD_ERROR_LOG}"
  exit 1
fi

echo "Run/build validation completed for ${VM_NAME} action=${ACTION}" | tee -a "${LOG_DIR}/run-engine.log"
