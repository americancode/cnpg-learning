#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_context
kubectl apply -f "${ROOT_DIR}/manifests/namespaces.yaml"
