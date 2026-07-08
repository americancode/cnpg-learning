#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context

helm repo add cnpg https://cloudnative-pg.github.io/charts >/dev/null 2>&1 || true
helm upgrade --install appdb-east cnpg/cluster \
  --namespace "${PRIMARY_NAMESPACE}" \
  --create-namespace \
  -f "${ROOT_DIR}/values/primary-values.yaml"
kubectl -n "${PRIMARY_NAMESPACE}" patch cluster appdb-east --type=merge --patch-file "${ROOT_DIR}/manifests/cnpg/primary-plugin-patch.yaml"
wait_cluster_ready "${PRIMARY_NAMESPACE}" appdb-east
