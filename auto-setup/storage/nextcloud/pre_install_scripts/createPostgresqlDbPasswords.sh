#!/bin/bash -x
set -euo pipefail

# Create and export passwords variables for later mustache substitution
export nextcloudPostgresqlPassword=$(pwgen -1s 12)
