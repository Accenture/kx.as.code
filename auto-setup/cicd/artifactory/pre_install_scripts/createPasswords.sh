#!/bin/bash
set -euox pipefail

# Create Artifactory Admin and Postgresql Passwords
export adminPassword=$(managedPassword "artifactory-admin-password")
export postgresqlPassword=$(managedApiKey "artifactory-postgresql-password")