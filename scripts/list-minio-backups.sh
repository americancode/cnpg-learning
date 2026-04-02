#!/usr/bin/env bash

set -euo pipefail

DEMO_NS="${DEMO_NS:-demo-db}"

if ! command -v mc >/dev/null 2>&1; then
  echo "minio client 'mc' is required on the host to list backup objects" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  if [[ -n "${PF_PID:-}" ]]; then
    kill "${PF_PID}" >/dev/null 2>&1 || true
  fi
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

kubectl -n "${DEMO_NS}" port-forward svc/minio 9000:9000 >/dev/null 2>&1 &
PF_PID=$!
sleep 2

export MC_CONFIG_DIR="${TMP_DIR}"
mc alias set local http://127.0.0.1:9000 minioadmin minioadmin123 >/dev/null
mc ls --recursive local/cnpg-backups
