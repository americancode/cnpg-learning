#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context
kubectl apply -f "${ROOT_DIR}/manifests/minio.yaml"
kubectl -n "${STORAGE_NAMESPACE}" rollout status deployment/minio --timeout=10m

kubectl -n "${STORAGE_NAMESPACE}" delete pod minio-bootstrap --ignore-not-found
kubectl -n "${STORAGE_NAMESPACE}" run minio-bootstrap \
  --restart=Never \
  --image=quay.io/minio/mc:RELEASE.2025-05-21T01-59-54Z \
  --env="MC_HOST_local=http://minioadmin:minioadmin123@minio.${STORAGE_NAMESPACE}.svc.cluster.local:9000" \
  --command -- sh -c "mc mb --ignore-existing local/cnpg-backups"
kubectl -n "${STORAGE_NAMESPACE}" wait --for=jsonpath='{.status.phase}'=Succeeded pod/minio-bootstrap --timeout=5m
kubectl -n "${STORAGE_NAMESPACE}" logs pod/minio-bootstrap
kubectl -n "${STORAGE_NAMESPACE}" delete pod minio-bootstrap --ignore-not-found

kubectl apply -f "${ROOT_DIR}/manifests/cnpg/objectstores.yaml"
