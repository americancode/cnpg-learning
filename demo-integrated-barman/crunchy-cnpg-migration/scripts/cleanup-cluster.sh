#!/usr/bin/env bash

set -euo pipefail

for ns in demo-db migration-db postgres-operator cnpg-system cert-manager; do
  kubectl delete namespace "${ns}" --ignore-not-found=true
done
