#!/bin/bash
set -euo pipefail

# Create Create Harbor Admin Password
export harborAdminPassword=$(managedApiKey "harbor-admin-password")
