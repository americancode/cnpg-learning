#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/init-cluster.sh"
"${SCRIPT_DIR}/install-platform.sh"
"${SCRIPT_DIR}/setup-namespaces.sh"
"${SCRIPT_DIR}/setup-storage.sh"
"${SCRIPT_DIR}/deploy-primary.sh"
"${SCRIPT_DIR}/create-base-backup.sh"
"${SCRIPT_DIR}/deploy-standby.sh"
"${SCRIPT_DIR}/verify-replication.sh"
