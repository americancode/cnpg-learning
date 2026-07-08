# Postgres Migration Demos

This repo contains three separate projects:

- `cnpg-pitr`
  A CloudNativePG point-in-time recovery demo using MinIO and the Barman Cloud plugin.
- `cnpg-standby-demo`
  A CloudNativePG primary/standby object-store replication demo using MinIO and the Barman Cloud plugin.
- `crunchy-cnpg-migration`
  A simple migration demo that uses Crunchy Postgres for Kubernetes as the source and bootstraps CloudNativePG from it using `pg_basebackup`.

Each project is intentionally isolated so its platform assets, manifests, namespaces, and scripts do not depend on another demo directory.
