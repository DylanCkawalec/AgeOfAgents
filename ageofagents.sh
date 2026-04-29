#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGECTL="${ROOT_DIR}/tools/agectl/agectl"
LOG_DIR="${ROOT_DIR}/logs/runtime"
RUN_ID="$(date -u '+%Y%m%dT%H%M%SZ')"
LOG_FILE="${LOG_DIR}/ageofagents-launch-${RUN_ID}.log"

AGE_BACKEND="${AGE_BACKEND:-auto}"
AGE_BACKEND_ORDER="${AGE_BACKEND_ORDER:-native,orbstack,lima}"
AGE_VM_BOOT_TIMEOUT="${AGE_VM_BOOT_TIMEOUT:-180}"
AGE_DOCTOR_TIMEOUT="${AGE_DOCTOR_TIMEOUT:-120}"
AGE_HEALTH_TIMEOUT="${AGE_HEALTH_TIMEOUT:-120}"
AGE_VERIFY_TIMEOUT="${AGE_VERIFY_TIMEOUT:-90}"
AGE_GAME_TIMEOUT="${AGE_GAME_TIMEOUT:-45}"
AGE_DEMO_TIMEOUT="${AGE_DEMO_TIMEOUT:-45}"
AGE_CONVERT_TIMEOUT="${AGE_CONVERT_TIMEOUT:-3600}"
AGE_BUILD_IF_MISSING="${AGE_BUILD_IF_MISSING:-1}"
AGE_TIMEOUT_IS_SUCCESS="${AGE_TIMEOUT_IS_SUCCESS:-1}"
AGE_ASSET_PROMPT_ANSWER="${AGE_ASSET_PROMPT_ANSWER:-${OPENAGE_STDIN:-}}"
AGE_DEMO_ID="${AGE_DEMO_ID:-0}"
AGE_MODPACKS="${AGE_MODPACKS:-}"
AGE_AUTO_STARTER="${AGE_AUTO_STARTER:-1}"
OPENAGE_SKIP_GUI="${OPENAGE_SKIP_GUI:-1}"
export OPENAGE_STDIN="${AGE_ASSET_PROMPT_ANSWER}"
export AGE_DEMO_ID AGE_MODPACKS OPENAGE_SKIP_GUI

mkdir -p "${LOG_DIR}"

usage() {
  cat <<'EOF'
Usage:
  ./ageofagents.sh launch     # doctor -> boot -> health -> full game -> verifier fallback
  ./ageofagents.sh doctor     # host/backend dependency checks
  ./ageofagents.sh health     # backend healthcheck
  ./ageofagents.sh verify     # non-GUI ./bin/run --help verifier
  ./ageofagents.sh game       # full game launch only
  ./ageofagents.sh demo       # standalone engine/window/input demo verifier
  ./ageofagents.sh boot       # boot/start selected backend
  ./ageofagents.sh status     # status summary

Environment:
  AGE_BACKEND=auto|lima|orbstack|native
  AGE_BACKEND_ORDER=native,orbstack,lima
  AGE_VM_BOOT_TIMEOUT=180
  AGE_GAME_TIMEOUT=45
  AGE_DEMO_TIMEOUT=45
  AGE_CONVERT_TIMEOUT=3600
  AGE_BUILD_IF_MISSING=1
  AGE_TIMEOUT_IS_SUCCESS=1
  AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install
  AGE_MODPACKS=trial_base  # optional; auto-selected from converted playable modpacks when unset
  AGE_ASSET_PROMPT_ANSWER=n  # optional: answer openage asset conversion prompt non-interactively
  AGE_AUTO_STARTER=1  # auto-bootstrap the ageofagents_base starter modpack when no source is set
Default launch tries native macOS first for an actual window, then OrbStack, then Lima.
EOF
}

timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

log() {
  printf '[%s] %s\n' "$(timestamp)" "$*" | tee -a "${LOG_FILE}"
}

emit_event() {
  local event_type="$1"
  local backend="${2:-}"
  local phase="${3:-}"
  local result="${4:-}"
  local payload
  payload="{\"run_id\":\"${RUN_ID}\",\"backend\":\"${backend}\",\"phase\":\"${phase}\",\"result\":\"${result}\",\"log_file\":\"${LOG_FILE}\"}"
  "${AGECTL}" events emit "${event_type}" "${payload}" --source ageofagents-launcher --actor operator --quiet >/dev/null 2>&1 || true
}

timeout_cmd() {
  local seconds="$1"
  shift

  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "${seconds}" "$@"
    return $?
  fi

  if command -v timeout >/dev/null 2>&1; then
    timeout "${seconds}" "$@"
    return $?
  fi

  python3 - "${seconds}" "$@" <<'PY'
import os
import signal
import subprocess
import sys

timeout = float(sys.argv[1])
cmd = sys.argv[2:]
proc = subprocess.Popen(cmd, start_new_session=True)
try:
    raise SystemExit(proc.wait(timeout=timeout))
except subprocess.TimeoutExpired:
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()
    raise SystemExit(124)
PY
}

run_timed() {
  local label="$1"
  local seconds="$2"
  shift 2

  log "RUN ${label} timeout=${seconds}s :: $*"
  timeout_cmd "${seconds}" "$@" 2>&1 | tee -a "${LOG_FILE}"
  local rc=${PIPESTATUS[0]}
  if [ "${rc}" -eq 0 ]; then
    log "PASS ${label}"
  elif [ "${rc}" -eq 124 ]; then
    log "TIMEOUT ${label} after ${seconds}s"
  else
    log "FAIL ${label} rc=${rc}"
  fi
  return "${rc}"
}

backend_list() {
  if [ "${AGE_BACKEND}" = "auto" ]; then
    IFS=',' read -r -a backends <<< "${AGE_BACKEND_ORDER}"
  else
    backends=("${AGE_BACKEND}")
  fi
  printf '%s\n' "${backends[@]}"
}

check_command() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    log "PASS command ${cmd}: $(command -v "${cmd}")"
    return 0
  fi
  log "FAIL command ${cmd} missing"
  return 1
}

doctor_global() {
  local failures=0
  log "Doctor: global checks"
  for cmd in bash python3 git; do
    check_command "${cmd}" || failures=$((failures + 1))
  done
  if [ -x "${AGECTL}" ]; then
    log "PASS agectl executable: ${AGECTL}"
  else
    log "FAIL agectl missing or not executable: ${AGECTL}"
    failures=$((failures + 1))
  fi
  run_timed "event bus status" "${AGE_DOCTOR_TIMEOUT}" "${AGECTL}" events status || failures=$((failures + 1))
  return "${failures}"
}

doctor_backend() {
  local backend="$1"
  local failures=0
  log "Doctor: backend=${backend}"
  case "${backend}" in
    lima)
      check_command limactl || failures=$((failures + 1))
      run_timed "lima status" 30 "${AGECTL}" vm status || failures=$((failures + 1))
      ;;
    orbstack)
      check_command docker || failures=$((failures + 1))
      if command -v orb >/dev/null 2>&1; then
        log "PASS command orb: $(command -v orb)"
      else
        log "WARN command orb missing; Docker may still be usable"
      fi
      run_timed "orbstack status" "${AGE_DOCTOR_TIMEOUT}" "${AGECTL}" orbstack status || failures=$((failures + 1))
      ;;
    native)
      run_timed "native dependency check" "${AGE_DOCTOR_TIMEOUT}" "${AGECTL}" native check-deps || failures=$((failures + 1))
      ;;
    *)
      log "FAIL unknown backend: ${backend}"
      failures=$((failures + 1))
      ;;
  esac
  return "${failures}"
}

boot_backend() {
  local backend="$1"
  log "Boot: backend=${backend}"
  emit_event runtime.started "${backend}" boot started
  case "${backend}" in
    lima)
      run_timed "lima boot" "${AGE_VM_BOOT_TIMEOUT}" "${AGECTL}" vm start
      ;;
    orbstack)
      if docker info >/dev/null 2>&1; then
        log "PASS OrbStack Docker daemon reachable"
      elif [ -d /Applications/OrbStack.app ]; then
        log "OrbStack Docker not reachable; opening OrbStack.app"
        open -ga OrbStack >/dev/null 2>&1 || true
        sleep 5
      fi
      if ! docker info >/dev/null 2>&1; then
        log "FAIL OrbStack Docker daemon is not reachable"
        return 1
      fi
      if ! docker image inspect ageofagents-openage:ubuntu2404 >/dev/null 2>&1; then
        if [ "${AGE_BUILD_IF_MISSING}" = "1" ]; then
          run_timed "orbstack image build" 1200 "${AGECTL}" orbstack build-image
        else
          log "FAIL missing image ageofagents-openage:ubuntu2404"
          return 1
        fi
      else
        log "PASS OrbStack image present: ageofagents-openage:ubuntu2404"
      fi
      ;;
    native)
      log "PASS native backend does not require VM boot"
      ;;
    *)
      log "FAIL unknown backend: ${backend}"
      return 1
      ;;
  esac
}
asset_status() {
  log "Asset status"
  run_timed "asset status" "${AGE_DOCTOR_TIMEOUT}" "${AGECTL}" assets status
}

asset_source_check() {
  if [ -z "${AGE_ASSET_SOURCE_DIR:-}" ]; then
    log "WARN AGE_ASSET_SOURCE_DIR is not set; full game conversion cannot run automatically"
    return 0
  fi
  run_timed "asset source validation" "${AGE_DOCTOR_TIMEOUT}" "${AGECTL}" assets validate-source "${AGE_ASSET_SOURCE_DIR}"
}

asset_verify() {
  run_timed "playable converted modpack verification" "${AGE_VERIFY_TIMEOUT}" "${AGECTL}" assets verify
}

select_modpacks() {
  if [ -n "${AGE_MODPACKS:-}" ]; then
    export AGE_MODPACKS
    log "Using configured playable modpack(s): ${AGE_MODPACKS}"
    return 0
  fi

  local selected
  selected="$("${AGECTL}" assets list --playable --names-only 2>/dev/null | awk 'NF { printf "%s%s", sep, $0; sep=" " }')"
  if [ -z "${selected}" ]; then
    log "FAIL no playable modpack can be selected"
    return 1
  fi

  AGE_MODPACKS="${selected}"
  export AGE_MODPACKS
  log "Selected playable modpack(s): ${AGE_MODPACKS}"
}

convert_assets_backend() {
  local backend="$1"
  if [ -z "${AGE_ASSET_SOURCE_DIR:-}" ]; then
    log "Full game blocked: no playable converted modpack and AGE_ASSET_SOURCE_DIR is not set"
    log "Set AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install, then rerun ./ageofagents.sh launch"
    return 1
  fi

  log "Attempting asset conversion for backend=${backend}"
  run_timed "asset conversion backend=${backend}" "${AGE_CONVERT_TIMEOUT}" "${AGECTL}" assets convert "${backend}"
}

bootstrap_starter_modpack() {
  if [ "${AGE_AUTO_STARTER}" != "1" ]; then
    log "Skip starter modpack bootstrap (AGE_AUTO_STARTER=${AGE_AUTO_STARTER})"
    return 1
  fi
  log "Bootstrapping AgeOfAgents starter modpack so the engine can launch standalone"
  run_timed "asset bootstrap-starter" "${AGE_DOCTOR_TIMEOUT}" "${AGECTL}" assets bootstrap-starter
}

prepare_playable_assets() {
  local backend="$1"

  asset_status || true
  if asset_verify; then
    select_modpacks
    return $?
  fi

  if [ -n "${AGE_ASSET_SOURCE_DIR:-}" ]; then
    if convert_assets_backend "${backend}"; then
      asset_status || true
      asset_verify && select_modpacks
      return $?
    fi
    return 1
  fi

  if bootstrap_starter_modpack; then
    asset_status || true
    asset_verify && select_modpacks
    return $?
  fi

  return 1
}

demo_backend() {
  local backend="$1"
  log "Standalone engine demo launch: backend=${backend}"
  emit_event runtime.started "${backend}" demo started
  case "${backend}" in
    lima)
      run_timed "lima standalone engine demo" "${AGE_DEMO_TIMEOUT}" "${AGECTL}" demo
      ;;
    orbstack)
      run_timed "orbstack standalone engine demo" "${AGE_DEMO_TIMEOUT}" "${AGECTL}" orbstack demo
      ;;
    native)
      run_timed "native standalone engine demo" "${AGE_DEMO_TIMEOUT}" "${AGECTL}" native demo
      ;;
    *)
      log "FAIL unknown backend: ${backend}"
      return 1
      ;;
  esac
  local rc=$?
  if [ "${rc}" -eq 124 ] && [ "${AGE_TIMEOUT_IS_SUCCESS}" = "1" ]; then
    log "OBSERVED ${backend} standalone demo still running after ${AGE_DEMO_TIMEOUT}s; treating as launched for this bounded check"
    emit_event runtime.started "${backend}" demo observed_timeout
    return 0
  fi
  if [ "${rc}" -eq 0 ]; then
    emit_event runtime.started "${backend}" demo exited_zero
  else
    emit_event system.error "${backend}" demo failed
  fi
  return "${rc}"
}

health_backend() {
  local backend="$1"
  log "Health: backend=${backend}"
  case "${backend}" in
    lima)
      run_timed "lima healthcheck" "${AGE_HEALTH_TIMEOUT}" "${ROOT_DIR}/infra/vm/healthcheck.sh"
      ;;
    orbstack)
      run_timed "orbstack status" "${AGE_HEALTH_TIMEOUT}" "${AGECTL}" orbstack status
      ;;
    native)
      run_timed "native dependency check" "${AGE_HEALTH_TIMEOUT}" "${AGECTL}" native check-deps
      ;;
    *)
      log "FAIL unknown backend: ${backend}"
      return 1
      ;;
  esac
}

verify_backend() {
  local backend="$1"
  log "Verifier: backend=${backend}"
  case "${backend}" in
    lima)
      run_timed "lima smoke ./bin/run --help" "${AGE_VERIFY_TIMEOUT}" "${AGECTL}" run
      ;;
    orbstack)
      run_timed "orbstack smoke ./bin/run --help" "${AGE_VERIFY_TIMEOUT}" "${AGECTL}" orbstack run
      ;;
    native)
      run_timed "native smoke ./bin/run --help" "${AGE_VERIFY_TIMEOUT}" "${AGECTL}" native run
      ;;
    *)
      log "FAIL unknown backend: ${backend}"
      return 1
      ;;
  esac
}

game_backend() {
  local backend="$1"
  log "Full game launch: backend=${backend} modpacks=${AGE_MODPACKS:-auto}"
  emit_event runtime.started "${backend}" game started
  case "${backend}" in
    lima)
      run_timed "lima full game ./bin/run main" "${AGE_GAME_TIMEOUT}" "${AGECTL}" game
      ;;
    orbstack)
      run_timed "orbstack full game ./bin/run main" "${AGE_GAME_TIMEOUT}" "${AGECTL}" orbstack game
      ;;
    native)
      run_timed "native full game ./bin/run main" "${AGE_GAME_TIMEOUT}" "${AGECTL}" native game
      ;;
    *)
      log "FAIL unknown backend: ${backend}"
      return 1
      ;;
  esac
  local rc=$?
  if [ "${rc}" -eq 124 ] && [ "${AGE_TIMEOUT_IS_SUCCESS}" = "1" ]; then
    log "OBSERVED ${backend} full game still running after ${AGE_GAME_TIMEOUT}s; treating as launched for this bounded check"
    emit_event runtime.started "${backend}" game observed_timeout
    return 0
  fi
  if [ "${rc}" -eq 0 ]; then
    emit_event runtime.started "${backend}" game exited_zero
  else
    emit_event system.error "${backend}" game failed
  fi
  return "${rc}"
}

doctor_command() {
  local failures=0
  doctor_global || failures=$((failures + $?))
  asset_status || failures=$((failures + 1))
  asset_source_check || failures=$((failures + 1))
  while IFS= read -r backend; do
    doctor_backend "${backend}" || failures=$((failures + $?))
  done < <(backend_list)
  if [ "${failures}" -eq 0 ]; then
    log "Doctor passed"
    emit_event system.healthcheck.passed "${AGE_BACKEND}" doctor passed
  else
    log "Doctor failed with ${failures} failure(s)"
    emit_event system.healthcheck.failed "${AGE_BACKEND}" doctor failed
  fi
  return "${failures}"
}

health_command() {
  local failures=0
  asset_status || failures=$((failures + 1))
  while IFS= read -r backend; do
    health_backend "${backend}" || failures=$((failures + 1))
  done < <(backend_list)
  return "${failures}"
}

verify_command() {
  local failures=0
  while IFS= read -r backend; do
    verify_backend "${backend}" || failures=$((failures + 1))
  done < <(backend_list)
  return "${failures}"
}

boot_command() {
  local failures=0
  while IFS= read -r backend; do
    boot_backend "${backend}" || failures=$((failures + 1))
  done < <(backend_list)
  return "${failures}"
}

game_command() {
  local failures=0
  while IFS= read -r backend; do
    if prepare_playable_assets "${backend}"; then
      game_backend "${backend}" || failures=$((failures + 1))
    else
      log "Skipping full game for ${backend}: playable converted assets are not ready"
      failures=$((failures + 1))
    fi
  done < <(backend_list)
  return "${failures}"
}

demo_command() {
  local failures=0
  while IFS= read -r backend; do
    demo_backend "${backend}" || failures=$((failures + 1))
  done < <(backend_list)
  return "${failures}"
}

launch_command() {
  local attempted=0
  local backend

  doctor_global || {
    log "Global doctor failed; aborting launch"
    return 1
  }

  while IFS= read -r backend; do
    attempted=1
    log "Launch candidate backend=${backend}"

    if ! doctor_backend "${backend}"; then
      log "Skipping ${backend}: doctor failed"
      continue
    fi

    if ! boot_backend "${backend}"; then
      log "Skipping ${backend}: boot failed"
      continue
    fi

    if ! health_backend "${backend}"; then
      log "Skipping ${backend}: health failed"
      continue
    fi
    if ! prepare_playable_assets "${backend}"; then
      log "Full converted-game launch blocked for backend=${backend}; running standalone demo and smoke verifier"
      demo_backend "${backend}" || true
      verify_backend "${backend}" || true
      continue
    fi

    log "Running full game first for backend=${backend}"
    if game_backend "${backend}"; then
      log "Full game launch path passed for backend=${backend}"
      emit_event system.healthcheck.passed "${backend}" launch full_game_passed
      return 0
    fi

    log "Full game launch failed for backend=${backend}; running verifier to classify failure"
    verify_backend "${backend}" || true
  done < <(backend_list)

  if [ "${attempted}" -eq 0 ]; then
    log "No backends attempted"
  fi
  emit_event system.healthcheck.failed "${AGE_BACKEND}" launch failed
  return 1
}

status_command() {
  log "Status summary"
  "${AGECTL}" events status 2>&1 | tee -a "${LOG_FILE}" || true
  "${AGECTL}" assets status 2>&1 | tee -a "${LOG_FILE}" || true
  "${AGECTL}" vm status 2>&1 | tee -a "${LOG_FILE}" || true
  "${AGECTL}" orbstack status 2>&1 | tee -a "${LOG_FILE}" || true
}

main() {
  local command="${1:-launch}"
  log "AgeOfAgents launcher run_id=${RUN_ID} command=${command} backend=${AGE_BACKEND} order=${AGE_BACKEND_ORDER}"
  log "Log file: ${LOG_FILE}"
  if [ -n "${AGE_ASSET_PROMPT_ANSWER}" ]; then
    log "Asset conversion prompt answer is configured via AGE_ASSET_PROMPT_ANSWER"
  fi

  case "${command}" in
    launch) launch_command ;;
    doctor) doctor_command ;;
    health) health_command ;;
    verify) verify_command ;;
    game|full) game_command ;;
    demo) demo_command ;;
    boot) boot_command ;;
    status) status_command ;;
    help|-h|--help) usage ;;
    *)
      usage
      return 2
      ;;
  esac
}

main "$@"
