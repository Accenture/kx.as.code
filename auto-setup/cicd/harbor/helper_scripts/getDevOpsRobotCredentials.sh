#!/bin/bash -x
set -euo pipefail

# Get Registry Robot Credentials for DEVOPS project
export devopsRobotUser=$(cat /usr/share/kx.as.code/.config/.devops-harbor-robot.cred | jq -r '.name')
export devopsRobotToken=$(cat /usr/share/kx.as.code/.config/.devops-harbor-robot.cred | jq -r '.secret')
