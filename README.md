# CNPG Kind + Podman Demo

This repo now uses Helm values for upstream platform installs where official charts exist, Kustomize for the Barman Cloud plugin because it is published as a manifest, and plain YAML for the namespace, MinIO, object stores, and CNPG clusters. Runtime demo actions are host-side Bash scripts using `kubectl exec`, not Kubernetes Jobs.

## Versions

- `kind` node image: `kindest/node:v1.35.0`
- CloudNativePG operator: `v1.28.0`
- Barman Cloud Plugin: `v0.11.0`
- cert-manager: `v1.20.0`
- PostgreSQL image: `ghcr.io/cloudnative-pg/postgresql:17.5`

## Apply Order

Create the kind cluster:

```bash
kind delete cluster --name cnpg-demo || true
KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name cnpg-demo --config kind-config.yaml
kubectl config use-context kind-cnpg-demo
```

Install platform components:

```bash
helm upgrade --install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.0 \
  -f platform/cert-manager/values.yaml
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=10m

helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version 0.27.0 \
  -f platform/cnpg-operator/values.yaml
kubectl -n cnpg-system rollout status deployment/cnpg-controller-manager --timeout=10m

kubectl apply -k platform/barman-cloud-plugin
kubectl -n cnpg-system rollout status deployment/barman-cloud --timeout=10m
```

Install the restricted namespace, quota, MinIO, object stores, and source cluster:

```bash
kubectl apply -k demo-db
kubectl -n demo-db rollout status deployment/minio --timeout=10m
kubectl -n demo-db wait --for=condition=complete job/minio-make-bucket --timeout=5m
kubectl -n demo-db wait --for=condition=Ready cluster/appdb --timeout=20m
```

Seed data and create the base backup:

```bash
./scripts/seed-initial-data.sh
./scripts/create-plugin-backup.sh
```

Generate the PITR window:

```bash
./scripts/create-pitr-window.sh
```

The script prints a line in this format and renders `demo-db/cluster-appdb-restore.yaml` automatically:

```text
TARGET_TIME=2026-04-02T20:30:15.123Z
```

Apply the rendered restore cluster:

```bash
./scripts/restore-pitr.sh
```

Verify source and restored data:

```bash
./scripts/verify-source.sh
./scripts/verify-restore.sh
./scripts/list-minio-backups.sh
```

## Expected Demo Outcome

The source cluster should contain the post-target changes:

- `alpha`
- `charlie`
- `pitr-kept-row`
- `after-target-row`

The restored cluster should stop before those post-target changes are replayed. With a correct `TARGET_TIME`, it should contain:

- `alpha`
- `bravo`
- `charlie`
- `pitr-kept-row`
