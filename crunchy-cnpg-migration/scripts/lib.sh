#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATION_NS="${MIGRATION_NS:-migration-db}"
CRUNCHY_NS="${CRUNCHY_NS:-postgres-operator}"
CRUNCHY_CLUSTER="${CRUNCHY_CLUSTER:-crunchy-source}"
CNPG_CLUSTER="${CNPG_CLUSTER:-cnpg-target}"

crunchy_primary_pod() {
  kubectl -n "${MIGRATION_NS}" get pod \
    -l "postgres-operator.crunchydata.com/cluster=${CRUNCHY_CLUSTER},postgres-operator.crunchydata.com/role=master" \
    -o jsonpath='{.items[0].metadata.name}'
}

cnpg_primary_pod() {
  kubectl -n "${MIGRATION_NS}" get pod \
    -l "cnpg.io/cluster=${CNPG_CLUSTER},role=primary" \
    -o jsonpath='{.items[0].metadata.name}'
}
