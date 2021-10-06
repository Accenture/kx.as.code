#!/bin/bash -x
set -euo pipefail

# Create and export password variable for later mustache substitution
export nextcloudPostgresqlPassword=$(managedPassword "nextcloud-postgresql-password")