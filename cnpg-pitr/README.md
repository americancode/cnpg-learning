# CNPG PITR

This project demonstrates CloudNativePG point-in-time recovery with:

- `kind` on `podman`
- `cert-manager`
- CloudNativePG `1.28.x`
- Barman Cloud plugin
- MinIO in-cluster

The known-good PITR path in this project uses:

- `targetTime` in `YYYY-MM-DD HH:MM:SS.US+00` format
- increased Barman plugin sidecar memory in the `ObjectStore`
- a unique restore `serverName` for each PITR run

`archiveAdditionalCommandArgs` for `--max-concurrency=1` is not required for the working flow.

## Layout

- `kind-config.yaml`
- `platform/`
- `demo-db/`
- `scripts/`

## Main Flow

Create the cluster:

```bash
kind delete cluster --name cnpg-demo || true
KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name cnpg-demo --config cnpg-pitr/kind-config.yaml
kubectl config use-context kind-cnpg-demo
```

Install platform components:

```bash
helm upgrade --install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.0 \
  -f cnpg-pitr/platform/cert-manager/values.yaml

helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version 0.27.0 \
  -f cnpg-pitr/platform/cnpg-operator/values.yaml

kubectl apply -k cnpg-pitr/platform/barman-cloud-plugin
```

Install the demo namespace, MinIO, object stores, and source cluster:

```bash
kubectl apply -k cnpg-pitr/demo-db
kubectl -n demo-db rollout status deployment/minio --timeout=10m
cnpg-pitr/scripts/create-minio-bucket.sh
kubectl -n demo-db wait --for=condition=Ready cluster/appdb --timeout=20m
```

Seed data, create a backup, and run PITR:

```bash
cnpg-pitr/scripts/seed-initial-data.sh
cnpg-pitr/scripts/create-plugin-backup.sh
cnpg-pitr/scripts/create-pitr-window.sh
cnpg-pitr/scripts/restore-pitr.sh
```
