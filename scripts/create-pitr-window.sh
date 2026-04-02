#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

wait_cluster_ready "${SOURCE_CLUSTER}"

psql_exec "${SOURCE_CLUSTER}" app "
INSERT INTO demo_items(name) VALUES ('pitr-kept-row');
"

TARGET_TIME="$(psql_exec "${SOURCE_CLUSTER}" app "
SELECT to_char(clock_timestamp(), 'YYYY-MM-DD\"T\"HH24:MI:SS.MSTZH:TZM');
")"

sleep 5

psql_exec "${SOURCE_CLUSTER}" app "
INSERT INTO demo_items(name) VALUES ('after-target-row');
DELETE FROM demo_items WHERE name = 'bravo';
SELECT pg_switch_wal();
CHECKPOINT;
SELECT 'SOURCE_ROWS=' || string_agg(name, ',' ORDER BY id) FROM demo_items;
"

sed "s/__TARGET_TIME__/${TARGET_TIME}/g" \
  "${ROOT_DIR}/demo-db/cluster-appdb-restore.template.yaml" \
  > "${ROOT_DIR}/demo-db/cluster-appdb-restore.yaml"

printf 'TARGET_TIME=%s\n' "${TARGET_TIME}"
printf 'Rendered %s\n' "${ROOT_DIR}/demo-db/cluster-appdb-restore.yaml"
