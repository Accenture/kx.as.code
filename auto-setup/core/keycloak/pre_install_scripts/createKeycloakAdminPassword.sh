#!/bin/bash
set -euo pipefail

# Generate Keycloak Admin Password
export keycloakAdminPassword=$(managedPassword "keycloak-admin-password" "keycloak")
