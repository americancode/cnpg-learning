#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

MINIO_POD="$(kubectl -n "${DEMO_NS}" get pods -l app=minio -o jsonpath='{.items[0].metadata.name}')"
ACCESS_KEY_ID="$(kubectl -n "${DEMO_NS}" get secret minio-creds -o jsonpath='{.data.ACCESS_KEY_ID}' | base64 --decode)"
ACCESS_SECRET_KEY="$(kubectl -n "${DEMO_NS}" get secret minio-creds -o jsonpath='{.data.ACCESS_SECRET_KEY}' | base64 --decode)"

kubectl -n "${DEMO_NS}" exec "${MINIO_POD}" -- env \
  MC_HOST_local="http://${ACCESS_KEY_ID}:${ACCESS_SECRET_KEY}@127.0.0.1:9000" \
  mc mb --ignore-existing local/cnpg-backups
