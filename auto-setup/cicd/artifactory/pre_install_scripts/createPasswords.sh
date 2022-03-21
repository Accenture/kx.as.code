#!/bin/bash
set -euox pipefail

# Create Artifactory Admin and Postgresql Passwords
export adminPassword=$(managedPassword "artifactory-admin-password")
export postgresqlPassword=$(managedPassword "artifactory-postgresql-password")