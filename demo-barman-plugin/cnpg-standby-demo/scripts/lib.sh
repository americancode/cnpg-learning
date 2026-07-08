#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-cnpg-standby-demo}"
KIND_CONTEXT="kind-${CLUSTER_NAME}"
PRIMARY_NAMESPACE="${PRIMARY_NAMESPACE:-db-east}"
STANDBY_NAMESPACE="${STANDBY_NAMESPACE:-db-west}"
STORAGE_NAMESPACE="${STORAGE_NAMESPACE:-storage}"
CNPG_VERSION="${CNPG_VERSION:-0.27.0}"
CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.20.0}"
PODMAN_MACHINE_NAME="${PODMAN_MACHINE_NAME:-podman-machine-default}"
PODMAN_MACHINE_CPUS="${PODMAN_MACHINE_CPUS:-6}"
PODMAN_MACHINE_MEMORY_MB="${PODMAN_MACHINE_MEMORY_MB:-8192}"
PODMAN_MACHINE_DISK_GB="${PODMAN_MACHINE_DISK_GB:-100}"

ensure_context() {
  kubectl config use-context "${KIND_CONTEXT}" >/dev/null
}

wait_cluster_ready() {
  kubectl -n "$1" wait --for=condition=Ready "cluster/$2" --timeout="${3:-20m}"
}

primary_pod() {
  kubectl -n "$1" get pods -l "cnpg.io/cluster=$2,role=primary" -o jsonpath='{.items[0].metadata.name}'
}
