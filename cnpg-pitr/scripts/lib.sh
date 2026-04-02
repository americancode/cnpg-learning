#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_NS="${DEMO_NS:-demo-db}"
SOURCE_CLUSTER="${SOURCE_CLUSTER:-appdb}"
RESTORE_CLUSTER="${RESTORE_CLUSTER:-appdb-restore}"

primary_pod() {
  kubectl -n "${DEMO_NS}" get pods \
    -l "cnpg.io/cluster=${1},role=primary" \
    -o jsonpath='{.items[0].metadata.name}'
}

wait_cluster_ready() {
  kubectl -n "${DEMO_NS}" wait --for=condition=Ready "cluster/${1}" --timeout="${2:-20m}"
}

psql_exec() {
  local cluster_name="$1"
  local database_name="$2"
  local sql="$3"
  kubectl -n "${DEMO_NS}" exec "$(primary_pod "${cluster_name}")" -c postgres -- \
    psql -v ON_ERROR_STOP=1 -U postgres -d "${database_name}" -At -c "${sql}"
}
