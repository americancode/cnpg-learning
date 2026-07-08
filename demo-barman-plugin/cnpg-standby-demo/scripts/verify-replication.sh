#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context

east_pod="$(primary_pod "${PRIMARY_NAMESPACE}" appdb-east)"
west_pod="$(primary_pod "${STANDBY_NAMESPACE}" appdb-west)"

kubectl -n "${PRIMARY_NAMESPACE}" exec "${east_pod}" -c postgres -- \
  psql -U postgres -d app -v ON_ERROR_STOP=1 -c \
  "create table if not exists replica_check(id int primary key, note text); insert into replica_check(id, note) values (1, 'replicated via minio wal') on conflict (id) do update set note = excluded.note;"

for _ in $(seq 1 18); do
  if kubectl -n "${STANDBY_NAMESPACE}" exec "${west_pod}" -c postgres -- \
    psql -U postgres -d app -At -c "select note from replica_check where id = 1;" 2>/dev/null | grep -q "replicated via minio wal"; then
    break
  fi
  sleep 10
done

kubectl -n "${STANDBY_NAMESPACE}" exec "${west_pod}" -c postgres -- \
  psql -U postgres -d app -At -c "select pg_is_in_recovery(), note from replica_check where id = 1;"
