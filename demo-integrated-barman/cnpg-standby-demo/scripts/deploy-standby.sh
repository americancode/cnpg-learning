#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context

helm repo add cnpg https://cloudnative-pg.github.io/charts >/dev/null 2>&1 || true
helm upgrade --install appdb-west cnpg/cluster \
  --namespace "${STANDBY_NAMESPACE}" \
  --create-namespace \
  -f "${ROOT_DIR}/values/standby-values.yaml"
wait_cluster_ready "${STANDBY_NAMESPACE}" appdb-west
