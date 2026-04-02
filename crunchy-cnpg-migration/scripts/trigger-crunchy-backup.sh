#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

kubectl -n "${MIGRATION_NS}" annotate postgrescluster "${CRUNCHY_CLUSTER}" --overwrite \
  postgres-operator.crunchydata.com/pgbackrest-backup="$(date '+%F_%H:%M:%S')"

sleep 5

kubectl -n "${MIGRATION_NS}" get jobs | grep "${CRUNCHY_CLUSTER}.*pgbackrest" || true
