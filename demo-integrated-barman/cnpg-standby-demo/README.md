# CNPG Standby Demo

This demo uses:

- `kind` on `podman`
- `cert-manager`
- the CloudNativePG operator chart
- integrated Barman object-store backup support
- the `cnpg/cluster` chart with local values files

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
./demo-integrated-barman/cnpg-standby-demo/scripts/init-podman-machine.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/init-cluster.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/install-platform.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/setup-namespaces.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/setup-storage.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/deploy-primary.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/create-base-backup.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/deploy-standby.sh
./demo-integrated-barman/cnpg-standby-demo/scripts/verify-replication.sh
```

`scripts/deploy.sh` remains as a convenience wrapper, but it only composes the individual steps and does not destroy the cluster.

Run `./demo-integrated-barman/cnpg-standby-demo/scripts/reset-demo.sh` if you want to replace an existing copy of the integrated standby demo in the same cluster.
