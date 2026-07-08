#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

POD="$(crunchy_primary_pod)"

kubectl -n "${MIGRATION_NS}" exec "${POD}" -c database -- \
  psql -U postgres -d app -v ON_ERROR_STOP=1 -c "
CREATE TABLE IF NOT EXISTS demo_items (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
TRUNCATE TABLE demo_items RESTART IDENTITY;
INSERT INTO demo_items(name) VALUES ('alpha'), ('bravo'), ('charlie');
"
