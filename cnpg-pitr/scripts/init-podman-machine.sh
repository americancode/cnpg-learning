#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

PODMAN_MACHINE_NAME="${PODMAN_MACHINE_NAME:-podman-machine-default}"
PODMAN_MACHINE_CPUS="${PODMAN_MACHINE_CPUS:-6}"
PODMAN_MACHINE_MEMORY_MB="${PODMAN_MACHINE_MEMORY_MB:-8192}"
PODMAN_MACHINE_DISK_GB="${PODMAN_MACHINE_DISK_GB:-100}"

if ! podman machine inspect "${PODMAN_MACHINE_NAME}" >/dev/null 2>&1; then
  podman machine init \
    --cpus "${PODMAN_MACHINE_CPUS}" \
    --memory "${PODMAN_MACHINE_MEMORY_MB}" \
    --disk-size "${PODMAN_MACHINE_DISK_GB}" \
    "${PODMAN_MACHINE_NAME}"
fi

podman machine start "${PODMAN_MACHINE_NAME}"
