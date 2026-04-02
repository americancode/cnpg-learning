#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

psql_exec "${SOURCE_CLUSTER}" app "TABLE demo_items;"
