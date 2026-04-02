# Postgres Migration Demos

This repo contains two separate projects:

- `cnpg-pitr`
  A CloudNativePG point-in-time recovery demo using MinIO and the Barman Cloud plugin.
- `crunchy-cnpg-migration`
  A simple migration demo that uses Crunchy Postgres for Kubernetes as the source and bootstraps CloudNativePG from it using `pg_basebackup`.

The projects are intentionally isolated so their manifests, namespaces, and scripts do not collide.
