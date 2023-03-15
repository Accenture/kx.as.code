#!/bin/bash
set -euo pipefail

# Stop KX-Portal
/usr/bin/sudo systemctl stop kx.as.code-portal.service

# Delete old KX-Portal runtime
rm -rf "${installationWorkspace}/kx-portal"

# Create new combined JSON metadata file
cd "${sharedGitHome}/kx.as.code/client"
${sharedGitHome}/kx.as.code/client/updateData.sh

# Trigger KX-Portal re-build/re-install
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"core","name":"kx-portal","action":"install","retries":"0"}'

# Call running KX-Portal to check status and pre-compile site
checkUrlHealth "http://localhost:3000" "200"

log_info "Task rebuild KX-Portal and restart completed"