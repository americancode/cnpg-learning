#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

kubectl apply -f "${ROOT_DIR}/demo-db/minio.yaml"
kubectl -n "${DEMO_NS}" rollout status deployment/minio --timeout=10m
"${ROOT_DIR}/scripts/create-minio-bucket.sh"
kubectl apply -f "${ROOT_DIR}/demo-db/objectstores.yaml"
