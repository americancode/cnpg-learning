# Crunchy To CNPG Migration

This project demonstrates the simplest supported migration path from Crunchy Postgres for Kubernetes to CloudNativePG:

1. install Crunchy Postgres for Kubernetes
2. deploy a Crunchy source cluster
3. configure Crunchy pgBackRest backups to MinIO-compatible S3
4. seed source data
5. trigger and verify a Crunchy backup
6. bootstrap a new CNPG cluster from the live Crunchy source using `pg_basebackup`
7. archive CNPG WAL to MinIO using the Barman Cloud plugin Helm chart

This is intentionally the simple path. It does not attempt to restore Crunchy `pgBackRest` backups directly into CNPG.

## Why This Path

CNPG does not natively consume Crunchy `pgBackRest` repositories as a restore source. The clean operator-supported path is to migrate from a running PostgreSQL source using `pg_basebackup`.

Crunchy still uses `pgBackRest` to write S3 backups so the source cluster has a real backup configuration for later experiments.

## Namespaces

- `postgres-operator`
  Crunchy operator namespace
- `migration-db`
  MinIO, Crunchy source cluster, and CNPG target cluster

## Files

- `kind-config.yaml`
- `platform/`
- `manifests/`
- `scripts/`

## Intended Flow

```bash
./demo-barman-plugin/crunchy-cnpg-migration/scripts/init-podman-machine.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/init-cluster.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/install-platform.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/setup-namespace.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/setup-storage.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/deploy-crunchy-source.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/seed-crunchy-source.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/trigger-crunchy-backup.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/deploy-cnpg-target.sh
./demo-barman-plugin/crunchy-cnpg-migration/scripts/verify-migration.sh
```

## Sources

- Crunchy Helm installation:
  https://access.crunchydata.com/documentation/postgres-operator/latest/installation/helm
- Crunchy S3 backups:
  https://access.crunchydata.com/documentation/postgres-operator/latest/tutorials/backups-disaster-recovery/backups
- Crunchy manual pgBackRest backup annotation:
  https://access.crunchydata.com/documentation/postgres-operator/latest/tutorials/backups-disaster-recovery/disaster-recovery
- CNPG bootstrap from another cluster:
  https://cloudnative-pg.io/documentation/1.16/bootstrap
- CNPG replica/external cluster examples with `pg_basebackup` and password auth:
  https://cloudnative-pg.io/docs/devel/replica_cluster/
