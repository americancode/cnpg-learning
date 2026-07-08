#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if ! podman machine inspect "${PODMAN_MACHINE_NAME}" >/dev/null 2>&1; then
  podman machine init \
    --cpus "${PODMAN_MACHINE_CPUS}" \
    --memory "${PODMAN_MACHINE_MEMORY_MB}" \
    --disk-size "${PODMAN_MACHINE_DISK_GB}" \
    "${PODMAN_MACHINE_NAME}"
fi

podman machine start "${PODMAN_MACHINE_NAME}"
