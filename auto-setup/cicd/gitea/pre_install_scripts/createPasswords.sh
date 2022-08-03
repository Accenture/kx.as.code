#!/bin/bash
set -euo pipefail

# Generate Gitea Postgresql Password
export postgresqlPassword=$(managedPassword "gitea-postgresql-password" "${componentName}")

# Generate Gitea Admin Password
export giteaAdminPassword=$(managedPassword "gitea-admin-password" "${componentName}")

