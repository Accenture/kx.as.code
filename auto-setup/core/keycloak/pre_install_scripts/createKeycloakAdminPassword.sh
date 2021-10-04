#!/bin/bash -x
set -euo pipefail

# Generate Keycloak Admin Password
export keycloakAdminPassword=$(managePassword "keycloak-admin-password")