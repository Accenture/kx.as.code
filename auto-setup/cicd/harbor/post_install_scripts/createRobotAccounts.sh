#!/bin/bash
set -euo pipefail

# Wait until API is available before continuing
checkUrlHealth "https://${componentName}.${baseDomain}/api/v2.0/projects" "200"

# Get Harbor Project Ids
export kxHarborProjectId=$(harborGetProjectId "kx-as-code")
export devopsHarborProjectId=$(harborGetProjectId "devops")

# Create robot account for KX.AS.CODE project
harborCreateRobotAccount "${kxHarborProjectId}" "kx-cicd-user" "KX.AS.CODE CICD User"

# Create robot account for DEVOPS project
harborCreateRobotAccount "${devopsHarborProjectId}" "devops-cicd-user" "DEVOPS CICD User"
