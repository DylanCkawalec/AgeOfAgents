#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

mkdir -p \
  "${ROOT_DIR}/logs/vm" \
  "${ROOT_DIR}/logs/build" \
  "${ROOT_DIR}/logs/runtime" \
  "${ROOT_DIR}/logs/agents" \
  "${ROOT_DIR}/logs/qgot" \
  "${ROOT_DIR}/logs/opseeq"

mkdir -p \
  "${ROOT_DIR}/state/agents" \
  "${ROOT_DIR}/state/quests" \
  "${ROOT_DIR}/state/qgot" \
  "${ROOT_DIR}/state/opseeq"

touch "${ROOT_DIR}/state/events.jsonl"

echo "Host-visible logs and state paths are ready."
