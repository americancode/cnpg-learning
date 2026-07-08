#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context

helm upgrade --install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version "${CERT_MANAGER_VERSION}" \
  -f "${ROOT_DIR}/platform/cert-manager/values.yaml"
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=10m
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=10m
kubectl -n cert-manager rollout status deployment/cert-manager-cainjector --timeout=10m

helm repo add cnpg https://cloudnative-pg.github.io/charts >/dev/null 2>&1 || true
helm repo update
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version "${CNPG_VERSION}" \
  -f "${ROOT_DIR}/platform/cnpg-operator/values.yaml"
kubectl -n cnpg-system rollout status deployment/cnpg-controller-manager --timeout=10m

helm upgrade --install barman-cloud cnpg/plugin-barman-cloud \
  --namespace cnpg-system \
  --create-namespace \
  --version 0.7.0 \
  -f "${ROOT_DIR}/platform/plugin-barman-cloud/values.yaml"
kubectl wait --for=condition=Established crd/objectstores.barmancloud.cnpg.io --timeout=5m
kubectl wait --for=condition=Established crd/backups.postgresql.cnpg.io --timeout=5m
kubectl -n cnpg-system rollout status deployment/barman-cloud --timeout=10m
kubectl -n cnpg-system wait --for=jsonpath='{.subsets[0].addresses[0].ip}' endpoints/cnpg-webhook-service --timeout=5m
