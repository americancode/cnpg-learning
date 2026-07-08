#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

helm uninstall appdb-east -n "${PRIMARY_NAMESPACE}" >/dev/null 2>&1 || true
helm uninstall appdb-west -n "${STANDBY_NAMESPACE}" >/dev/null 2>&1 || true

kubectl delete namespace "${PRIMARY_NAMESPACE}" "${STANDBY_NAMESPACE}" "${STORAGE_NAMESPACE}" --ignore-not-found=true

for ns in "${PRIMARY_NAMESPACE}" "${STANDBY_NAMESPACE}" "${STORAGE_NAMESPACE}"; do
  while kubectl get namespace "${ns}" >/dev/null 2>&1; do
    sleep 2
  done
done
