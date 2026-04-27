#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_NAME="${VM_NAME:-ageofagents}"
HOST_DEV_ROOT="${HOST_DEV_ROOT:-/Users/dylanckawalec/Desktop/developer}"
VM_MOUNT_POINT="${VM_MOUNT_POINT:-/mnt/developer}"
VM_LOG_DIR="${ROOT_DIR}/logs/vm"
VM_TYPE="${VM_TYPE:-vz}"
MOUNT_TYPE="${MOUNT_TYPE:-virtiofs}"

mkdir -p "${VM_LOG_DIR}"

if ! command -v limactl >/dev/null 2>&1; then
  echo "ERROR: limactl not found. Install with: brew install lima" | tee -a "${VM_LOG_DIR}/bootstrap.log"
  exit 1
fi

if ! command -v qemu-system-aarch64 >/dev/null 2>&1; then
  echo "WARN: qemu not found. Lima will use VM_TYPE=${VM_TYPE}; install qemu only if you switch to qemu." | tee -a "${VM_LOG_DIR}/bootstrap.log"
fi

TMP_TEMPLATE="$(mktemp)"
cat > "${TMP_TEMPLATE}" <<EOF
arch: aarch64
vmType: "${VM_TYPE}"
mountType: "${MOUNT_TYPE}"
images:
  - location: "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"
mounts:
  - location: "${HOST_DEV_ROOT}"
    writable: true
    mountPoint: "${VM_MOUNT_POINT}"
ssh:
  loadDotSSHPubKeys: true
cpus: ${VM_CPUS:-6}
memory: "${VM_MEMORY:-16}GiB"
disk: "${VM_DISK:-120}GiB"
EOF
if limactl list | awk 'NR > 1 {print $1}' | grep -Fx "${VM_NAME}" >/dev/null 2>&1; then
  VM_STATUS="$(limactl list | awk -v vm="${VM_NAME}" 'NR > 1 && $1 == vm {print $2}')"
  if [ "${VM_STATUS}" = "Running" ]; then
    echo "VM ${VM_NAME} already running." | tee -a "${VM_LOG_DIR}/bootstrap.log"
  else
    echo "VM ${VM_NAME} already exists with status=${VM_STATUS}; starting..." | tee -a "${VM_LOG_DIR}/bootstrap.log"
    limactl start "${VM_NAME}" 2>&1 | tee -a "${VM_LOG_DIR}/bootstrap.log"
  fi
else
  echo "Creating VM ${VM_NAME}..." | tee -a "${VM_LOG_DIR}/bootstrap.log"
  limactl start --name "${VM_NAME}" "${TMP_TEMPLATE}" 2>&1 | tee -a "${VM_LOG_DIR}/bootstrap.log"
fi

echo "VM bootstrap complete: ${VM_NAME}" | tee -a "${VM_LOG_DIR}/bootstrap.log"
