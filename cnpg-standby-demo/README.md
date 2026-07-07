# CNPG Standby Demo

This demo uses the official Helm charts:

- `cnpg/cloudnative-pg` for the operator
- `cnpg/cluster` for the database clusters

It creates:

- a `kind` cluster
- MinIO in the `storage` namespace
- a primary CNPG cluster in `db-east`
- a replica CNPG cluster in `db-west`

The west cluster does not connect directly to the east cluster. It bootstraps from, and continues replaying WAL from, the same S3-compatible MinIO bucket path written by the east cluster.

Files:

- `primary-values.yaml`
- `standby-values.yaml`
- `scripts/deploy.sh`

Run:

```bash
./cnpg-standby-demo/scripts/deploy.sh
```
