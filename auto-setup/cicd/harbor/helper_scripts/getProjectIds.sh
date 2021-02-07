#!/bin/bash

# Get project ids
export kxHarborProjectId=$(curl -s -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects | jq -r '.[] | select(.name=="kx-as-code") | .project_id')
export devopsHarborProjectId=$(curl -s -u 'admin:'${vmPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects | jq -r '.[] | select(.name=="devops") | .project_id')
