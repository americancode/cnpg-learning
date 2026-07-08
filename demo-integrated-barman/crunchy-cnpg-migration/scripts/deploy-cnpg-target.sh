#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/scripts/lib.sh"

CRUNCHY_PASSWORD="$(kubectl -n "${MIGRATION_NS}" get secret "${CRUNCHY_CLUSTER}-pguser-migrator" -o jsonpath='{.data.password}' | base64 --decode)"

sed "s/__CRUNCHY_SOURCE_MIGRATOR_PASSWORD__/${CRUNCHY_PASSWORD}/g" \
  "${ROOT_DIR}/manifests/cnpg/target-cluster.yaml.template" \
  > "${ROOT_DIR}/manifests/cnpg/target-cluster.yaml"

kubectl apply -f "${ROOT_DIR}/manifests/cnpg/target-app-secret.yaml"
kubectl apply -f "${ROOT_DIR}/manifests/cnpg/target-cluster.yaml"
kubectl -n "${MIGRATION_NS}" wait --for=condition=Ready cluster/"${CNPG_CLUSTER}" --timeout=20m
