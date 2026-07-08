# CNPG PITR

This project demonstrates CloudNativePG point-in-time recovery with:

- `kind` on `podman`
- `cert-manager`
- CloudNativePG `1.28.x`
- Barman Cloud plugin
- MinIO in-cluster

The known-good PITR path in this project uses:

- `targetTime` in `YYYY-MM-DD HH:MM:SS.US+00` format
- a unique restore `serverName` for each PITR run

`archiveAdditionalCommandArgs` for `--max-concurrency=1` is not required for the working flow.

## Layout

- `kind-config.yaml`
- `platform/`
- `demo-db/`
- `scripts/`

## Main Flow

Initialize the podman VM if needed:

```bash
./cnpg-pitr/scripts/init-podman-machine.sh
```

Create or reuse the cluster:

```bash
./cnpg-pitr/scripts/init-cluster.sh
```

Install platform components:

```bash
./cnpg-pitr/scripts/install-platform.sh
```

Install the demo namespace, MinIO, object stores, and source cluster:

```bash
./cnpg-pitr/scripts/setup-namespace.sh
./cnpg-pitr/scripts/setup-storage.sh
./cnpg-pitr/scripts/deploy-source-cluster.sh
```

Seed data, create a backup, and run PITR:

```bash
cnpg-pitr/scripts/seed-initial-data.sh
cnpg-pitr/scripts/create-plugin-backup.sh
cnpg-pitr/scripts/create-pitr-window.sh
cnpg-pitr/scripts/restore-pitr.sh
```
