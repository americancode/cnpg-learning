#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

kubectl apply -f "${ROOT_DIR}/demo-db/cluster-appdb.yaml"
wait_cluster_ready "${SOURCE_CLUSTER}"
