#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "${ROOT_DIR}/manifests/minio.yaml"
kubectl -n migration-db rollout status deployment/minio --timeout=10m

kubectl -n migration-db delete pod minio-mc --ignore-not-found=true

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: minio-mc
  namespace: migration-db
spec:
  restartPolicy: Never
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  volumes:
    - name: tmp
      emptyDir: {}
  containers:
    - name: minio-mc
      image: quay.io/minio/mc:RELEASE.2025-02-21T16-00-46Z
      command:
        - sh
        - -ec
        - mc mb --ignore-existing local/crunchy-cnpg-migration
      env:
        - name: MC_HOST_local
          value: http://minioadmin:minioadmin123@minio.migration-db.svc.cluster.local:9000
        - name: HOME
          value: /tmp
      volumeMounts:
        - name: tmp
          mountPath: /tmp
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
EOF

kubectl -n migration-db wait --for=condition=Ready pod/minio-mc --timeout=5m
kubectl -n migration-db logs pod/minio-mc
kubectl -n migration-db wait --for=jsonpath='{.status.phase}'=Succeeded pod/minio-mc --timeout=5m
kubectl -n migration-db delete pod minio-mc --ignore-not-found=true
