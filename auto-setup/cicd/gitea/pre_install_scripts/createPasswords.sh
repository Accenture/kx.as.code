#!/bin/bash

# Generate Gitea Postgresql Password
export postgresqlPassword=$(managedPassword "gitea-postgresql-password" "gitea")

# Generate Gitea Admin Password
export giteaAdminPassword=$(managedPassword "gitea-admin-password" "gitea")

