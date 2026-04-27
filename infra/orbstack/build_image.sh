#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE_TAG="${AGEOFAGENTS_ORBSTACK_IMAGE:-ageofagents-openage:ubuntu2404}"
DOCKERFILE="${ROOT_DIR}/packaging/docker/devenv/Dockerfile.ubuntu.2404"
LOG_DIR="${ROOT_DIR}/logs/build"
LOG_FILE="${LOG_DIR}/orbstack-image.log"
BUILD_ERROR_LOG="${ROOT_DIR}/docs/build/BUILD_ERRORS.md"

mkdir -p "${LOG_DIR}"

record_failure() {
  {
    echo
    echo "## $(date -u '+%Y-%m-%dT%H:%M:%SZ') OrbStack image build failed"
    echo
    echo "- Command: infra/orbstack/build_image.sh"
    echo "- Docker command: docker build --platform linux/arm64 -t ${IMAGE_TAG} -f packaging/docker/devenv/Dockerfile.ubuntu.2404 ."
    echo "- Log file: logs/build/orbstack-image.log"
    echo "- Likely root cause: inspect the Docker build log for package, network, or OrbStack daemon errors."
    echo "- Next step fix: resolve the first Docker build error, then rerun this exact command."
  } >> "${BUILD_ERROR_LOG}"
}

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found. OrbStack Docker CLI is required." | tee -a "${LOG_FILE}"
  record_failure
  exit 1
fi

if [ ! -f "${DOCKERFILE}" ]; then
  echo "ERROR: missing ${DOCKERFILE}" | tee -a "${LOG_FILE}"
  record_failure
  exit 1
fi

{
  echo "== $(date -u '+%Y-%m-%dT%H:%M:%SZ') building ${IMAGE_TAG} =="
  docker context ls
  docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
  docker build --platform linux/arm64 -t "${IMAGE_TAG}" -f "${DOCKERFILE}" "${ROOT_DIR}"
} 2>&1 | tee -a "${LOG_FILE}" || {
  record_failure
  exit 1
}
