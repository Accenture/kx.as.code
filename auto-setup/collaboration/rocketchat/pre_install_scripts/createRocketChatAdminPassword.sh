#!/bin/bash
set -euo pipefail

# Create RocketChat admin password for use in Helm Chart
export rocketchatAdminPassword=$(managedApiKey "rocketchat-admin-password" "rocketchat")
