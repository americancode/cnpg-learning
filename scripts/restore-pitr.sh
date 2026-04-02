#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

kubectl apply -f "${ROOT_DIR}/demo-db/cluster-appdb-restore.yaml"
wait_cluster_ready "${RESTORE_CLUSTER}"
kubectl -n "${DEMO_NS}" get cluster "${RESTORE_CLUSTER}"
