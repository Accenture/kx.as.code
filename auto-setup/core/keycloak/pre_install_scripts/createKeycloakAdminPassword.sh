#!/bin/bash -x
set -euo pipefail

# Generate Keycloak Admin Password
export keycloakAdminPassword=$(managedPassword "keycloak-admin-password")
