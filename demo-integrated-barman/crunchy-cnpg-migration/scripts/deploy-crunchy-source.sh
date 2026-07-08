#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "${ROOT_DIR}/manifests/crunchy/pgbackrest-secret.yaml"
kubectl apply -f "${ROOT_DIR}/manifests/crunchy/source-cluster.yaml"
while [[ "$(kubectl -n migration-db get pods -l 'postgres-operator.crunchydata.com/cluster=crunchy-source,postgres-operator.crunchydata.com/data=postgres' --no-headers 2>/dev/null | wc -l | tr -d ' ')" == "0" ]]; do
  sleep 2
done
kubectl -n migration-db wait \
  --for=condition=Ready \
  pod \
  -l "postgres-operator.crunchydata.com/cluster=crunchy-source,postgres-operator.crunchydata.com/data=postgres" \
  --timeout=20m
