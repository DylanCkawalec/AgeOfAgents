#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_NAME="${VM_NAME:-ageofagents}"
VM_MOUNT_POINT="${VM_MOUNT_POINT:-/mnt/developer}"
LOG_DIR="${ROOT_DIR}/logs/runtime"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"
ACTION="${1:-all}"
GUEST_REPO="${VM_MOUNT_POINT}/openage-ageofagents"
GUEST_OPENAGE_STDIN="$(python3 -c 'import os, shlex; print(shlex.quote(os.environ.get("OPENAGE_STDIN", "")))')"
GUEST_AGE_MODPACKS="$(python3 -c 'import os, shlex; print(shlex.quote(os.environ.get("AGE_MODPACKS", "")))')"
GUEST_AGE_DEMO_ID="$(python3 -c 'import os, shlex; print(shlex.quote(os.environ.get("AGE_DEMO_ID", "0")))')"
GUEST_AGE_CONVERT_JOBS="$(python3 -c 'import os, shlex; print(shlex.quote(os.environ.get("AGE_CONVERT_JOBS", "")))')"
HOST_DEVELOPER_ROOT="$(cd "${ROOT_DIR}/.." && pwd)"
GUEST_ASSET_SOURCE_DIR=""
if [ -n "${AGE_ASSET_SOURCE_DIR:-}" ]; then
  if [ ! -d "${AGE_ASSET_SOURCE_DIR}" ]; then
    echo "ERROR: AGE_ASSET_SOURCE_DIR does not exist or is not a directory: ${AGE_ASSET_SOURCE_DIR}" >&2
    exit 1
  fi
  case "${AGE_ASSET_SOURCE_DIR}" in
    "${HOST_DEVELOPER_ROOT}"/*)
      GUEST_ASSET_SOURCE_DIR="${VM_MOUNT_POINT}/${AGE_ASSET_SOURCE_DIR#"${HOST_DEVELOPER_ROOT}"/}"
      ;;
    *)
      GUEST_ASSET_SOURCE_DIR="${AGE_GUEST_ASSET_SOURCE_DIR:-}"
      if [ -z "${GUEST_ASSET_SOURCE_DIR}" ]; then
        echo "ERROR: AGE_ASSET_SOURCE_DIR is outside the shared developer mount; set AGE_GUEST_ASSET_SOURCE_DIR for Lima conversion." >&2
        exit 1
      fi
      ;;
  esac
fi
GUEST_ASSET_SOURCE_DIR_QUOTED="$(python3 -c 'import shlex, sys; print(shlex.quote(sys.argv[1]))' "${GUEST_ASSET_SOURCE_DIR}")"

mkdir -p "${LOG_DIR}"

case "${ACTION}" in
  configure|compile|run|game|full|convert|demo|all) ;;
  *)
    echo "Usage: run_engine.sh [configure|compile|run|game|full|convert|demo|all]" >&2
    exit 1
    ;;
esac

if ! limactl shell "${VM_NAME}" -- bash -lc "
  set -euo pipefail
  OPENAGE_STDIN=${GUEST_OPENAGE_STDIN}
  AGE_MODPACKS=${GUEST_AGE_MODPACKS}
  AGE_ASSET_SOURCE_DIR=${GUEST_ASSET_SOURCE_DIR_QUOTED}
  AGE_DEMO_ID=${GUEST_AGE_DEMO_ID}
  AGE_CONVERT_JOBS=${GUEST_AGE_CONVERT_JOBS}
  export OPENAGE_STDIN
  export AGE_MODPACKS AGE_ASSET_SOURCE_DIR AGE_DEMO_ID AGE_CONVERT_JOBS
  cd '${GUEST_REPO}'
  case '${ACTION}' in
    configure)
      ./configure --download-nyan
      ;;
    compile)
      cmake --build build -j\$(nproc)
      ;;
    run)
      cd bin && ./run --help
      ;;
    game|full)
      test -x ./bin/run
      cd bin
      if [ -n \"\${AGE_MODPACKS:-}\" ]; then
        read -r -a modpacks <<< \"\${AGE_MODPACKS}\"
        ./run game --modpacks \"\${modpacks[@]}\"
      elif [ -n \"\${OPENAGE_STDIN:-}\" ]; then
        printf '%s\n' \"\${OPENAGE_STDIN}\" | ./run main
      else
        ./run main
      fi
      ;;
    convert)
      if [ -z \"\${AGE_ASSET_SOURCE_DIR:-}\" ]; then
        echo \"ERROR: AGE_ASSET_SOURCE_DIR must point to a supported game installation before conversion.\"
        exit 1
      fi
      test -x ./bin/run
      cd bin
      convert_args=(convert --force --no-prompts --source-dir \"\${AGE_ASSET_SOURCE_DIR}\" --output-dir '${GUEST_REPO}/assets')
      if [ -n \"\${AGE_CONVERT_JOBS:-}\" ]; then
        convert_args+=(-j \"\${AGE_CONVERT_JOBS}\")
      fi
      ./run \"\${convert_args[@]}\"
      ;;
    demo)
      test -x ./bin/run
      cd bin && ./run test -d openage.main.tests.engine_demo \"\${AGE_DEMO_ID:-0}\"
      ;;
    all)
      ./configure --download-nyan
      cmake --build build -j\$(nproc)
      cd bin && ./run --help
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
