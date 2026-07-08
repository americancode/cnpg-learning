#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context
kubectl apply -f "${ROOT_DIR}/manifests/cnpg/primary-backup.yaml"
kubectl -n "${PRIMARY_NAMESPACE}" wait \
  --for=jsonpath='{.status.phase}'=completed \
  backup/appdb-east-initial \
  --timeout=20m
kubectl -n "${PRIMARY_NAMESPACE}" get backup appdb-east-initial
