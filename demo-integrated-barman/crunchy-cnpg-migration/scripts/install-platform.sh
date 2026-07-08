#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

helm upgrade --install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.0 \
  -f "${ROOT_DIR}/platform/cert-manager/values.yaml"

helm upgrade --install pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
  --namespace postgres-operator \
  --create-namespace \
  --version 6.0.0 \
  -f "${ROOT_DIR}/platform/crunchy-operator/values.yaml"

helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version 0.27.0 \
  -f "${ROOT_DIR}/platform/cnpg-operator/values.yaml"

kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=10m
kubectl -n postgres-operator rollout status deployment/pgo --timeout=10m
kubectl -n cnpg-system rollout status deployment/cnpg-controller-manager --timeout=10m
kubectl wait --for=condition=Established crd/backups.postgresql.cnpg.io --timeout=5m
