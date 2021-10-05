#!/bin/bash -x
set -euo pipefail

# Create Artifactory Admin and Postgresql Passwords
export harborAdminPassword=$(managedApiKey "harbor-admin-password")
