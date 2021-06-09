#!/bin/bash -x
set -euo pipefail

# Wait until API is available before continuing
timeout -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' https://'${componentName}'.'${baseDomain}'/api/v2.0/projects)" != "200" ]]; do \
                            echo "Waiting for https://'${componentName}'.'${baseDomain}'/api/v2.0/projects"; sleep 5; done'
# Get Harbor Project Ids
. ${installComponentDirectory}/helper_scripts/getProjectIds.sh

# Create robot account for KX.AS.CODE project
export kxRobotAccount=$(curl -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects/${kxHarborProjectId}/robots | jq -r '.[] | select(.name=="robot$kx-cicd-user") | .name')
if [[ -z ${kxRobotAccount} ]]; then
    curl -s -u 'admin:'${vmPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/projects/${kxHarborProjectId}/robots" -H "accept: application/json" -H "Content-Type: application/json" -d'{
    "access": [
      {
        "action": "push",
        "resource": "/project/'${kxHarborProjectId}'/repository"
      },
      {
        "action": "pull",
        "resource": "/project/'${kxHarborProjectId}'/repository"
      },
      {
        "action": "read",
        "resource": "/project/'${kxHarborProjectId}'/helm-chart"
      },
      {
        "action": "create",
        "resource": "/project/'${kxHarborProjectId}'/helm-chart"
      }
    ],
    "name": "kx-cicd-user",
    "expires_at": -1,
    "description": "KX.AS.CODE CICD User"
  }' | sudo tee /usr/share/kx.as.code/.config/.kx-harbor-robot.cred
else
    log_info "Harbor robot account already exists for KX.AS.CODE project. Skipping creation"
fi

# Create robot account for DEVOPS project
export devopsRobotAccount=$(curl -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects/${devopsHarborProjectId}/robots | jq -r '.[] | select(.name=="robot$devops-cicd-user") | .name')
if [[ -z ${devopsRobotAccount} ]]; then
    curl -s -u 'admin:'${vmPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/projects/${devopsHarborProjectId}/robots" -H "accept: application/json" -H "Content-Type: application/json" -d'{
  "access": [
    {
      "action": "push",
      "resource": "/project/'${devopsHarborProjectId}'/repository"
    },
    {
      "action": "pull",
      "resource": "/project/'${devopsHarborProjectId}'/repository"
    },
    {
      "action": "read",
      "resource": "/project/'${devopsHarborProjectId}'/helm-chart"
    },
    {
      "action": "create",
      "resource": "/project/'${devopsHarborProjectId}'/helm-chart"
    }
  ],
  "name": "devops-cicd-user",
  "expires_at": -1,
  "description": "DEVOPS CICD User"
}' | sudo tee /usr/share/kx.as.code/.config/.devops-harbor-robot.cred
else
    log_info "Harbor robot account already exists for DEVOPS project. Skipping creation"
fi

# Get created robots
log_debug $(curl -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects/${kxHarborProjectId}/robots)
log_debug $(curl -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects/${devopsHarborProjectId}/robots)
