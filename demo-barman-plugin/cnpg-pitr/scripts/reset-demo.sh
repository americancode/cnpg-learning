#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

kubectl delete namespace "${DEMO_NS}" --ignore-not-found=true

while kubectl get namespace "${DEMO_NS}" >/dev/null 2>&1; do
  sleep 2
done
