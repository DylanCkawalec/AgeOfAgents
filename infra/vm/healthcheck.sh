#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_NAME="${VM_NAME:-ageofagents}"
VM_MOUNT_POINT="${VM_MOUNT_POINT:-/mnt/developer}"
LOG_DIR="${ROOT_DIR}/logs/vm"
OUT_FILE="${LOG_DIR}/healthcheck.log"

mkdir -p "${LOG_DIR}"
: > "${OUT_FILE}"

pass() { echo "[PASS] $*" | tee -a "${OUT_FILE}"; }
warn() { echo "[WARN] $*" | tee -a "${OUT_FILE}"; }
FAILURES=0
fail() {
  echo "[FAIL] $*" | tee -a "${OUT_FILE}"
  FAILURES=$((FAILURES + 1))
}

if command -v limactl >/dev/null 2>&1; then pass "limactl installed on host"; else fail "limactl missing"; fi
if command -v qemu-system-aarch64 >/dev/null 2>&1; then pass "qemu installed on host"; else warn "qemu missing; acceptable for Lima vmType=vz"; fi

if limactl list | awk 'NR > 1 {print $1}' | grep -Fx "${VM_NAME}" >/dev/null 2>&1; then
  pass "VM ${VM_NAME} exists"
else
  fail "VM ${VM_NAME} missing"
fi

if limactl shell "${VM_NAME}" -- uname -a >/dev/null 2>&1; then
  pass "iTerm2 shell access into VM works"
else
  fail "cannot shell into VM ${VM_NAME}"
fi

if limactl shell "${VM_NAME}" -- test -d "${VM_MOUNT_POINT}" >/dev/null 2>&1; then
  pass "shared mount point ${VM_MOUNT_POINT} exists"
else
  fail "shared mount point ${VM_MOUNT_POINT} missing"
fi
if limactl shell "${VM_NAME}" -- test -d "${VM_MOUNT_POINT}/openage-ageofagents" >/dev/null 2>&1; then
  pass "openage-ageofagents repo visible at ${VM_MOUNT_POINT}/openage-ageofagents"
else
  fail "openage-ageofagents repo not visible at ${VM_MOUNT_POINT}/openage-ageofagents"
fi

if limactl shell "${VM_NAME}" -- test -w "${VM_MOUNT_POINT}/openage-ageofagents" >/dev/null 2>&1; then
  pass "shared repo mount is writable"
else
  fail "shared repo mount is not writable"
fi

for cmd in g++ cmake ninja python3 pip3; do
  if limactl shell "${VM_NAME}" -- bash -lc "command -v ${cmd}" >/dev/null 2>&1; then
    pass "${cmd} present in VM"
  else
    fail "${cmd} missing in VM"
  fi
done
if limactl shell "${VM_NAME}" -- bash -lc "python3 - <<'PY'
import Cython
from packaging.version import Version
raise SystemExit(0 if Version(Cython.__version__) >= Version('3.0.10') else 1)
PY" >/dev/null 2>&1; then
  pass "Cython >= 3.0.10 present in VM"
else
  fail "Cython >= 3.0.10 missing in VM"
fi

for pkg in qt6-declarative-dev qt6-multimedia-dev qml6-module-qtquick-controls libepoxy-dev libtoml11-dev libeigen3-dev; do
  if limactl shell "${VM_NAME}" -- dpkg -s "${pkg}" >/dev/null 2>&1; then
    pass "${pkg} installed in VM"
  else
    fail "${pkg} missing in VM"
  fi
done

if test -d "${ROOT_DIR}/logs/runtime"; then pass "host runtime log path exists"; else fail "host runtime log path missing"; fi
if test -f "${ROOT_DIR}/docs/build/BUILD_ERRORS.md"; then pass "build error log exists"; else fail "build error log missing"; fi

echo "Healthcheck complete. See ${OUT_FILE}"
if [ "${FAILURES}" -gt 0 ]; then
  echo "Healthcheck failed with ${FAILURES} failure(s)." | tee -a "${OUT_FILE}"
  exit 1
fi
