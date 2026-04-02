#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

wait_cluster_ready "${SOURCE_CLUSTER}"

psql_exec "${SOURCE_CLUSTER}" app "
CREATE TABLE IF NOT EXISTS demo_items (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
TRUNCATE TABLE demo_items RESTART IDENTITY;
INSERT INTO demo_items(name) VALUES
  ('alpha'),
  ('bravo'),
  ('charlie');
SELECT 'ROWS=' || string_agg(name, ',' ORDER BY id) FROM demo_items;
"
