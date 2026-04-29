#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE_TAG="${AGEOFAGENTS_ORBSTACK_IMAGE:-ageofagents-openage:ubuntu2404}"
ACTION="${1:-status}"
CONTAINER_REPO="/workspace/openage-ageofagents"
CONTAINER_HOME="${CONTAINER_REPO}/state/orbstack/home"
CONTAINER_ASSET_SOURCE="/workspace/source-assets"
ORBSTACK_BUILD_DIR="${ORBSTACK_BUILD_DIR:-.bin/g++-debug-Oauto-sanitize-none}"
LOG_DIR="${ROOT_DIR}/logs/runtime"
LOG_FILE="${LOG_DIR}/orbstack-openage.log"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"

mkdir -p "${LOG_DIR}" "${ROOT_DIR}/state/orbstack/home" "${ROOT_DIR}/state/orbstack/cache"

usage() {
  cat <<'EOF'
Usage: run_openage.sh status|configure|compile|run|game|full|convert|demo|all|shell
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
  local docker_args=(
    --rm
    --platform linux/arm64
    --user "$(id -u):$(id -g)"
    -e "HOME=${CONTAINER_HOME}"
    -e "QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-offscreen}"
    -e "OPENAGE_STDIN=${OPENAGE_STDIN:-}"
    -e "AGE_MODPACKS=${AGE_MODPACKS:-}"
    -e "AGE_CONVERT_JOBS=${AGE_CONVERT_JOBS:-}"
    -v "${ROOT_DIR}:${CONTAINER_REPO}"
    -w "${CONTAINER_REPO}"
  )

  if [ -n "${AGE_ASSET_SOURCE_DIR:-}" ]; then
    if [ ! -d "${AGE_ASSET_SOURCE_DIR}" ]; then
      echo "ERROR: AGE_ASSET_SOURCE_DIR does not exist or is not a directory: ${AGE_ASSET_SOURCE_DIR}" | tee -a "${LOG_FILE}"
      record_failure "${ACTION}"
      exit 1
    fi
    docker_args+=(-e "AGE_ASSET_SOURCE_DIR=${CONTAINER_ASSET_SOURCE}" -v "${AGE_ASSET_SOURCE_DIR}:${CONTAINER_ASSET_SOURCE}:ro")
  else
    docker_args+=(-e "AGE_ASSET_SOURCE_DIR=")
  fi

  docker run "${docker_args[@]}" \
    "${IMAGE_TAG}" \
    bash -lc "mkdir -p '${CONTAINER_HOME}' '${CONTAINER_REPO}/state/orbstack/cache'; ${script}"
}

ensure_orbstack_bin='if [ -d "'"${ORBSTACK_BUILD_DIR}"'" ]; then if [ -L bin ]; then rm -f bin; ln -s "'"${ORBSTACK_BUILD_DIR}"'" bin; elif [ ! -e bin ]; then ln -s "'"${ORBSTACK_BUILD_DIR}"'" bin; else echo "ERROR: bin exists and is not a symlink; refusing to overwrite"; exit 1; fi; else echo "ERROR: missing OrbStack build dir '"${ORBSTACK_BUILD_DIR}"'. Run configure first."; exit 1; fi'

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
    container_exec "${ensure_orbstack_bin}; test -x ./bin/run && cd bin && ./run --help" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  game|full)
    require_image
    container_exec "${ensure_orbstack_bin}; test -x ./bin/run && cd bin && if [ -n \"\${AGE_MODPACKS:-}\" ]; then read -r -a modpacks <<< \"\${AGE_MODPACKS}\"; ./run game --modpacks \"\${modpacks[@]}\"; elif [ -n \"\${OPENAGE_STDIN:-}\" ]; then printf '%s\n' \"\${OPENAGE_STDIN}\" | ./run main; else ./run main; fi" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  convert)
    require_image
    container_exec "${ensure_orbstack_bin}; if [ -z \"\${AGE_ASSET_SOURCE_DIR:-}\" ]; then echo \"ERROR: AGE_ASSET_SOURCE_DIR must point to a supported game installation before conversion.\"; exit 1; fi; test -x ./bin/run && cd bin && convert_args=(convert --force --no-prompts --source-dir \"\${AGE_ASSET_SOURCE_DIR}\" --output-dir \"${CONTAINER_REPO}/assets\"); if [ -n \"\${AGE_CONVERT_JOBS:-}\" ]; then convert_args+=(-j \"\${AGE_CONVERT_JOBS}\"); fi; ./run \"\${convert_args[@]}\"" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  demo)
    require_image
    container_exec "${ensure_orbstack_bin}; test -x ./bin/run && cd bin && ./run test -d openage.main.tests.engine_demo \"${AGE_DEMO_ID:-0}\"" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
    ;;
  all)
    require_image
    container_exec "./configure --download-nyan && make -j\$(nproc) && cd bin && ./run --help" 2>&1 | tee -a "${LOG_FILE}" || { record_failure "${ACTION}"; exit 1; }
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
