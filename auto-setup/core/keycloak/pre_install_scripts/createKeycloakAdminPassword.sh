#!/bin/bash

# Generate Keycloak Admin Password
export keycloakAdminPassword=$(managedPassword "keycloak-admin-password" "keycloak")
