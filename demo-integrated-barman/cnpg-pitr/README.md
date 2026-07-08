# CNPG PITR

This project demonstrates CloudNativePG point-in-time recovery with:

- `kind` on `podman`
- `cert-manager`
- CloudNativePG `1.28.x`
- integrated Barman object-store backup support
- MinIO in-cluster

The known-good PITR path in this project uses:

- `targetTime` in `YYYY-MM-DD HH:MM:SS.US+00` format

## Layout

- `kind-config.yaml`
- `platform/`
- `demo-db/`
- `scripts/`

## Main Flow

Initialize the podman VM if needed:

```bash
./demo-integrated-barman/cnpg-pitr/scripts/init-podman-machine.sh
```

Create or reuse the cluster:

```bash
./demo-integrated-barman/cnpg-pitr/scripts/init-cluster.sh
```

Install platform components:

```bash
./demo-integrated-barman/cnpg-pitr/scripts/install-platform.sh
```

Install the demo namespace, MinIO, and source cluster:

```bash
./demo-integrated-barman/cnpg-pitr/scripts/setup-namespace.sh
./demo-integrated-barman/cnpg-pitr/scripts/setup-storage.sh
./demo-integrated-barman/cnpg-pitr/scripts/deploy-source-cluster.sh
```

Seed data, create a backup, and run PITR:

```bash
./demo-integrated-barman/cnpg-pitr/scripts/seed-initial-data.sh
./demo-integrated-barman/cnpg-pitr/scripts/create-plugin-backup.sh
./demo-integrated-barman/cnpg-pitr/scripts/create-pitr-window.sh
./demo-integrated-barman/cnpg-pitr/scripts/restore-pitr.sh
```
