#!/bin/bash
set -euo pipefail

# Create new combined JSON metadata file
cd "${sharedGitHome}/kx.as.code/client"
${sharedGitHome}/kx.as.code/client/updateData.sh

# Copy it to runtime environment
/usr/bin/sudo cp -rf "${sharedGitHome}/kx.as.code/client/src/data" "${installationWorkspace}/kx-portal/client/src/"

# Restart KX-Portal
/usr/bin/sudo systemctl restart kx.as.code-portal.service

log_info "Task update KX-Portal config and restart service completed"