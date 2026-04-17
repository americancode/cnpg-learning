# Alpine Backup Image

This directory builds an `alpine:latest` based image with:

- Azure CLI: `az`
- MinIO client: `mc`
- PostgreSQL client: `pg_dump`

Alpine currently packages `minio-client` and PostgreSQL clients directly. Azure CLI is installed into a Python virtualenv at build time because it is not packaged in Alpine's main/community repositories.

The image only contains the tools. The Kubernetes Job manifest contains the backup orchestration inline.

## Build Image

Build and push the tool image to a registry your cluster can pull from:

```sh
docker build -t registry.example.com/backup-tools:latest .
docker push registry.example.com/backup-tools:latest
```

Then update the `image` field in [backup-job.yaml](backup-job.yaml).

## Azure Destination

Set `AZURE_TARGET_TYPE` to `blob` or `file`.

For Azure Blob Storage:

```yaml
AZURE_TARGET_TYPE: blob
AZURE_BLOB_CONTAINER: database-and-minio-backups
AZURE_CREATE_DESTINATION: "true"
```

For Azure Files:

```yaml
AZURE_TARGET_TYPE: file
AZURE_FILE_SHARE: database-and-minio-backups
AZURE_CREATE_DESTINATION: "true"
```

Then use one of these auth styles:

- `AZURE_STORAGE_CONNECTION_STRING`
- `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_KEY`
- `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_SAS_TOKEN`

`BACKUP_PREFIX` defaults to `backups`.

If you use a SAS scoped to an existing blob container or file share, set:

```yaml
AZURE_CREATE_DESTINATION: "false"
```

For Blob targets, the script uses `az storage blob upload`. For Azure Files targets, it uses `az storage file upload` and creates the destination directories inside the file share before uploading each artifact.

## MinIO Backups

Set these variables to enable MinIO backups:

```sh
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKETS="bucket-a bucket-b"
```

If `MINIO_BUCKETS` is omitted, the script tries to discover every bucket visible to the configured credentials.

Each bucket is uploaded to:

```text
<BACKUP_PREFIX>/minio/<bucket>/<timestamp>.tar.gz
```

## PostgreSQL Dumps

Use normal libpq variables for one database:

```sh
PGHOST=postgres
PGPORT=5432
PGUSER=postgres
PGPASSWORD=postgres
PGDATABASE=app
```

Use `PGDATABASES="app analytics"` to dump several databases from the same server, or set `DATABASE_URL` to dump one database using a full PostgreSQL URL.

Each dump uses pg_dump custom format and is uploaded to:

```text
<BACKUP_PREFIX>/postgres/<database>/<timestamp>.dump
```

Restore with:

```sh
pg_restore --clean --if-exists --dbname "$DATABASE_URL" backup.dump
```

## Kubernetes Job

[backup-job.yaml](backup-job.yaml) contains a `ConfigMap`, `Secret`, and `Job`. The Job uses `emptyDir` scratch storage with `sizeLimit: 100Gi` mounted at `/backup`; each run writes backup artifacts under `/backup/work/<timestamp>`. The data is deleted automatically when Kubernetes removes the Pod after `ttlSecondsAfterFinished: 86400`. Replace the placeholder secret values and image name before applying it:

```sh
kubectl apply -f backup-job.yaml
```

For production, prefer creating `backup-credentials` from your secret manager or an external secret controller instead of committing real credentials to this manifest.
