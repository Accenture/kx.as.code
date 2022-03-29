#!/bin/bash -x
set -euo pipefail

# Generate Gitea Postgresql Password
export postgresqlPassword=$(managedPassword "gitea-postgresql-password")

# Generate Gitea Admin Password
export giteaAdminPassword=$(managedPassword "gitea-admin-password")

