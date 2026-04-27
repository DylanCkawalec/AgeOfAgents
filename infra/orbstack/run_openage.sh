#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE_TAG="${AGEOFAGENTS_ORBSTACK_IMAGE:-ageofagents-openage:ubuntu2404}"
ACTION="${1:-status}"
CONTAINER_REPO="/workspace/openage-ageofagents"
CONTAINER_HOME="${CONTAINER_REPO}/state/orbstack/home"
ORBSTACK_BUILD_DIR="${ORBSTACK_BUILD_DIR:-.bin/g++-debug-Oauto-sanitize-none}"
LOG_DIR="${ROOT_DIR}/logs/runtime"
LOG_FILE="${LOG_DIR}/orbstack-openage.log"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"

mkdir -p "${LOG_DIR}" "${ROOT_DIR}/state/orbstack/home" "${ROOT_DIR}/state/orbstack/cache"

usage() {
  cat <<'EOF'
Usage: run_openage.sh status|configure|compile|run|game|full|all|shell
EOF
}

record_failure() {
  local action="$1"
  {
    echo
    echo "## $(date -u '+%Y-%m-%dT%H:%M:%SZ') OrbStack openage ${action} failed"
    echo
    echo "- Command: infra/orbstack/run_openage.sh ${action}"
    echo "- Image: ${IMAGE_TAG}"
    echo "- Log file: logs/runtime/orbstack-openage.log"
    echo "- Likely root cause: inspect the command log for missing image, configure/build failure, or runtime/display limitation."
    echo "- Next step fix: fix the first failing dependency/build/runtime error, then rerun this exact command."
  } >> "${BUILD_ERROR_LOG}"
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker not found. OrbStack Docker CLI is required." | tee -a "${LOG_FILE}"
    record_failure "${ACTION}"
    exit 1
  fi
}

require_image() {
  if ! docker image inspect "${IMAGE_TAG}" >/dev/null 2>&1; then
    echo "ERROR: missing Docker image ${IMAGE_TAG}. Run infra/orbstack/build_image.sh first." | tee -a "${LOG_FILE}"
    record_failure "${ACTION}"
    exit 1
  fi
}

container_exec() {
  local script="$1"
  docker run --rm \
    --platform linux/arm64 \
    --user "$(id -u):$(id -g)" \
    -e HOME="${CONTAINER_HOME}" \
    -e QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
    -v "${ROOT_DIR}:${CONTAINER_REPO}" \
    -w "${CONTAINER_REPO}" \
    "${IMAGE_TAG}" \
    bash -lc "mkdir -p '${CONTAINER_HOME}' '${CONTAINER_REPO}/state/orbstack/cache'; ${script}"
}

ensure_orbstack_bin='if [ -d "'"${ORBSTACK_BUILD_DIR}"'" ]; then if [ -L bin ] || [ ! -e bin ]; then ln -sfn "'"${ORBSTACK_BUILD_DIR}"'" bin; else echo "ERROR: bin exists and is not a symlink; refusing to overwrite"; exit 1; fi; else echo "ERROR: missing OrbStack build dir '"${ORBSTACK_BUILD_DIR}"'. Run configure first."; exit 1; fi'

require_docker

case "${ACTION}" in
  status)
    {
      echo "== $(date -u '+%Y-%m-%dT%H:%M:%SZ') OrbStack status =="
      docker context ls
      docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
      if docker image inspect "${IMAGE_TAG}" >/dev/null 2>&1; then
        echo "Image ${IMAGE_TAG}: present"
      else
        echo "Image ${IMAGE_TAG}: missing"
      fi
    } 2>&1 | tee -a "${LOG_FILE}"
    ;;
  configure)
    require_image
    container_exec "./configure --download-nyan" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  compile)
    require_image
    container_exec "${ensure_orbstack_bin}; make -j\$(nproc)" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  run)
    require_image
    container_exec "${ensure_orbstack_bin}; test -x ./bin/run && ./bin/run --help" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  game|full)
    require_image
    container_exec "${ensure_orbstack_bin}; test -x ./bin/run && ./bin/run main" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  all)
    require_image
    container_exec "./configure --download-nyan && make -j\$(nproc) && ./bin/run --help" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  shell)
    require_image
    docker run --rm -it \
      --platform linux/arm64 \
      --user "$(id -u):$(id -g)" \
      -e HOME="${CONTAINER_HOME}" \
      -e QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
      -v "${ROOT_DIR}:${CONTAINER_REPO}" \
      -w "${CONTAINER_REPO}" \
      "${IMAGE_TAG}" \
      bash
    ;;
  *)
    usage
    exit 1
    ;;
esac
