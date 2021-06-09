#!/bin/bash -x
set -euo pipefail

# Wait until API is available before continuing
timeout -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' https://'${componentName}'.'${baseDomain}'/api/v2.0/projects)" != "200" ]]; do \
echo "Waiting for https://'${componentName}'.'${baseDomain}'/api/v2.0/projects"; sleep 5; done'

# Create public kx-as-code project in Habor via API
export kxHarborProjectId=$(curl -s -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects | jq -r '.[] | select(.name=="kx-as-code") | .project_id')
if [[ -z ${kxHarborProjectId} ]]; then
    curl -u 'admin:'${vmPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/projects" -H "accept: application/json" -H "Content-Type: application/json" -d'{
    "project_name": "kx-as-code",
    "cve_whitelist": {
      "items": [
      {
        "cve_id": ""
      }
      ],
      "project_id": 0,
      "id": 0,
      "expires_at": 0
      },
      "metadata": {
        "enable_content_trust": "false",
        "auto_scan": "true",
        "severity": "low",
        "reuse_sys_cve_whitelist": "true",
        "public": "true",
        "prevent_vul": "false"
      }
    }'
else
    log_info "Harbor Docker Registry KX-AS-CODE project already exists. Skipping creation"
fi

# Create public devops project in Habor via API
export devopsHarborProjectId=$(curl -s -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects | jq -r '.[] | select(.name=="devops") | .project_id')
if [[ -z ${devopsHarborProjectId} ]]; then
    curl -u 'admin:'${vmPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/projects" -H "accept: application/json" -H "Content-Type: application/json" -d'{
    "project_name": "devops",
    "cve_whitelist": {
      "items": [
      {
        "cve_id": ""
      }
      ],
      "project_id": 0,
      "id": 0,
      "expires_at": 0
      },
      "metadata": {
        "enable_content_trust": "false",
        "auto_scan": "true",
        "severity": "low",
        "reuse_sys_cve_whitelist": "true",
        "public": "true",
        "prevent_vul": "false"
      }
    }'
else
    log_info "Harbor Docker Registry KX-AS-CODE project already exists. Skipping creation"
fi
