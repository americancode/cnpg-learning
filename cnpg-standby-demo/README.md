# CNPG Standby Demo

This demo uses:

- `kind` on `podman`
- `cert-manager`
- the CloudNativePG operator chart
- the Barman Cloud plugin Helm chart
- the `cnpg/cluster` chart with local values files
- small post-install cluster patches for plugin fields the chart does not expose yet

It creates:

- a `kind` cluster
- MinIO in the `storage` namespace
- a primary CNPG cluster in `db-east`
- a replica CNPG cluster in `db-west`

The west cluster does not connect directly to the east cluster. It bootstraps from, and continues replaying WAL from, the same S3-compatible MinIO bucket path written by the east cluster.

Files:

- `platform/`
- `manifests/`
- `values/`
- `scripts/`

Recommended flow:

```bash
./cnpg-standby-demo/scripts/init-podman-machine.sh
./cnpg-standby-demo/scripts/init-cluster.sh
./cnpg-standby-demo/scripts/install-platform.sh
./cnpg-standby-demo/scripts/setup-namespaces.sh
./cnpg-standby-demo/scripts/setup-storage.sh
./cnpg-standby-demo/scripts/deploy-primary.sh
./cnpg-standby-demo/scripts/create-base-backup.sh
./cnpg-standby-demo/scripts/deploy-standby.sh
./cnpg-standby-demo/scripts/verify-replication.sh
```

`scripts/deploy.sh` remains as a convenience wrapper, but it only composes the individual steps and does not destroy the cluster.

If you previously deployed the older integrated-backup version of this demo into the same `kind` cluster, run `./cnpg-standby-demo/scripts/reset-demo.sh` once before applying the new plugin-based manifests.
