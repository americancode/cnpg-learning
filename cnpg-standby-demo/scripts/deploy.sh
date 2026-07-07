#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-cnpg-standby-demo}"
PRIMARY_NAMESPACE="${PRIMARY_NAMESPACE:-db-east}"
STANDBY_NAMESPACE="${STANDBY_NAMESPACE:-db-west}"
STORAGE_NAMESPACE="${STORAGE_NAMESPACE:-storage}"
CNPG_VERSION="${CNPG_VERSION:-0.27.0}"
CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.20.0}"

kind delete cluster --name "${CLUSTER_NAME}" >/dev/null 2>&1 || true
kind create cluster --name "${CLUSTER_NAME}" --config "${ROOT_DIR}/kind-config.yaml"
kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null

helm upgrade --install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version "${CERT_MANAGER_VERSION}" \
  -f "${ROOT_DIR}/../cnpg-pitr/platform/cert-manager/values.yaml"
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=10m
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=10m
kubectl -n cert-manager rollout status deployment/cert-manager-cainjector --timeout=10m

helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version "${CNPG_VERSION}" \
  -f "${ROOT_DIR}/../cnpg-pitr/platform/cnpg-operator/values.yaml"
kubectl -n cnpg-system rollout status deployment/cnpg-controller-manager --timeout=10m
kubectl apply -k "${ROOT_DIR}/../cnpg-pitr/platform/barman-cloud-plugin"
kubectl wait --for=condition=Established crd/objectstores.barmancloud.cnpg.io --timeout=5m
kubectl wait --for=condition=Established crd/backups.postgresql.cnpg.io --timeout=5m
kubectl -n cnpg-system rollout status deployment/barman-cloud --timeout=10m

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
kubectl -n "${STORAGE_NAMESPACE}" delete pod/minio-bootstrap --ignore-not-found

helm upgrade --install appdb-east cnpg/cluster \
  --namespace "${PRIMARY_NAMESPACE}" \
  --create-namespace \
  -f "${ROOT_DIR}/primary-values.yaml"
kubectl -n "${PRIMARY_NAMESPACE}" wait --for=condition=Ready cluster/appdb-east --timeout=20m
kubectl -n "${PRIMARY_NAMESPACE}" apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: appdb-east-initial
spec:
  cluster:
    name: appdb-east
  method: plugin
  pluginConfiguration:
    name: barman-cloud.cloudnative-pg.io
EOF
for _ in $(seq 1 120); do
  backup_phase="$(kubectl -n "${PRIMARY_NAMESPACE}" get backup appdb-east-initial -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  if [ "${backup_phase}" = "completed" ] || [ "${backup_phase}" = "Completed" ]; then
    break
  fi
  if [ "${backup_phase}" = "failed" ] || [ "${backup_phase}" = "Failed" ]; then
    kubectl -n "${PRIMARY_NAMESPACE}" get backup appdb-east-initial -o yaml
    exit 1
  fi
  sleep 10
done
kubectl -n "${PRIMARY_NAMESPACE}" get backup appdb-east-initial

helm upgrade --install appdb-west cnpg/cluster \
  --namespace "${STANDBY_NAMESPACE}" \
  --create-namespace \
  -f "${ROOT_DIR}/standby-values.yaml"
kubectl -n "${STANDBY_NAMESPACE}" wait --for=condition=Ready cluster/appdb-west --timeout=20m

EAST_POD="$(kubectl -n "${PRIMARY_NAMESPACE}" get pods -l cnpg.io/cluster=appdb-east -o jsonpath='{.items[0].metadata.name}')"
WEST_POD="$(kubectl -n "${STANDBY_NAMESPACE}" get pods -l cnpg.io/cluster=appdb-west -o jsonpath='{.items[0].metadata.name}')"
kubectl -n "${PRIMARY_NAMESPACE}" exec "${EAST_POD}" -c postgres -- psql -U postgres -d app -v ON_ERROR_STOP=1 -c "create table if not exists replica_check(id int primary key, note text); insert into replica_check(id, note) values (1, 'replicated via minio wal') on conflict (id) do update set note = excluded.note;"
for _ in $(seq 1 18); do
  if kubectl -n "${STANDBY_NAMESPACE}" exec "${WEST_POD}" -c postgres -- psql -U postgres -d app -At -c "select note from replica_check where id = 1;" 2>/dev/null | grep -q "replicated via minio wal"; then
    break
  fi
  sleep 10
done
kubectl -n "${STANDBY_NAMESPACE}" exec "${WEST_POD}" -c postgres -- psql -U postgres -d app -At -c "select pg_is_in_recovery(), note from replica_check where id = 1;"

kubectl get ns "${PRIMARY_NAMESPACE}" "${STANDBY_NAMESPACE}" "${STORAGE_NAMESPACE}" cnpg-system
kubectl -n "${PRIMARY_NAMESPACE}" get cluster,pods
kubectl -n "${STANDBY_NAMESPACE}" get cluster,pods
kubectl -n "${STORAGE_NAMESPACE}" get pods,svc
