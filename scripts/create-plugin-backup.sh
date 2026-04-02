#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

kubectl apply -f "${ROOT_DIR}/demo-db/backup-appdb.yaml"
kubectl -n "${DEMO_NS}" wait \
  --for=jsonpath='{.status.phase}'=completed \
  backup/appdb-plugin-basebackup \
  --timeout=20m
kubectl -n "${DEMO_NS}" get backup appdb-plugin-basebackup
