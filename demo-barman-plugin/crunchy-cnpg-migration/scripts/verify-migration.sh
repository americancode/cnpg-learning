#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

CRUNCHY_POD="$(crunchy_primary_pod)"
CNPG_POD="$(cnpg_primary_pod)"

echo "CRUNCHY_ROWS=$(kubectl -n "${MIGRATION_NS}" exec "${CRUNCHY_POD}" -c database -- \
  psql -U postgres -d app -At -c "SELECT string_agg(name, ',' ORDER BY id) FROM demo_items;")"

echo "CNPG_ROWS=$(kubectl -n "${MIGRATION_NS}" exec "${CNPG_POD}" -c postgres -- \
  psql -U postgres -d app -At -c "SELECT string_agg(name, ',' ORDER BY id) FROM demo_items;")"
